/**
 * Admin Authentication Middleware
 * Verifies admin JWT tokens and establishes admin session
 */

const { verifyToken } = require("../config/jwt");
const { db } = require("../config/firebase");
const AdminLogger = require("../utils/adminLogger");

/**
 * Admin Protect Middleware
 * Ensures user is authenticated as admin
 * Usage: router.get('/admin/users', adminProtect, controller)
 */
const adminProtect = async (req, res, next) => {
  try {
    // Check if Authorization header exists
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      AdminLogger.logSecurityEvent({
        eventType: "UNAUTHORIZED_ACCESS_ATTEMPT",
        ipAddress: req.ip,
        description: "Missing authorization header",
        severity: "HIGH",
      });

      return res.status(401).json({
        success: false,
        message: "Not authorized. No admin token provided.",
      });
    }

    // Extract token from "Bearer <token>"
    const token = authHeader.split(" ")[1];

    // Verify the token
    const decoded = verifyToken(token, process.env.ADMIN_JWT_SECRET);

    // Get admin user from Firebase
    const adminDoc = await db
      .collection("admin_users")
      .doc(decoded.userId)
      .get();
    if (!adminDoc.exists) {
      AdminLogger.logSecurityEvent({
        eventType: "INVALID_ADMIN_SESSION",
        userId: decoded.userId,
        ipAddress: req.ip,
        description: "Admin user not found",
        severity: "HIGH",
      });

      return res.status(401).json({
        success: false,
        message: "Admin user not found",
      });
    }

    const adminData = adminDoc.data();

    // Check if admin account is active
    if (adminData.status !== "ACTIVE") {
      AdminLogger.logSecurityEvent({
        eventType: "INACTIVE_ADMIN_LOGIN_ATTEMPT",
        userId: decoded.userId,
        ipAddress: req.ip,
        description: `Admin account is ${adminData.status}`,
        severity: "MEDIUM",
      });

      return res.status(403).json({
        success: false,
        message: `Admin account is ${adminData.status}`,
      });
    }

    // Direct document lookup using sessionId embedded in the JWT.
    // This requires NO Firestore composite index — just a single doc fetch.
    const sessionId = decoded.sessionId;
    if (!sessionId) {
      return res.status(401).json({
        success: false,
        message: "Invalid admin token: missing session reference",
      });
    }

    const sessionDoc = await db
      .collection("admin_sessions")
      .doc(sessionId)
      .get();

    if (!sessionDoc.exists) {
      return res.status(401).json({
        success: false,
        message: "Admin session not found",
      });
    }

    const sessionData = sessionDoc.data();

    // Check session is still active
    if (!sessionData.isActive) {
      return res.status(401).json({
        success: false,
        message: "Admin session has been terminated",
      });
    }

    // Check session expiry
    if (new Date() > new Date(sessionData.expiresAt)) {
      await db.collection("admin_sessions").doc(sessionId).update({
        isActive: false,
      });

      return res.status(401).json({
        success: false,
        message: "Admin session expired",
      });
    }

    // Update last activity (fire-and-forget — don't await so it doesn't slow requests)
    db.collection("admin_sessions").doc(sessionId).update({
      lastActivityAt: new Date().toISOString(),
    });

    // Attach admin to request object
    req.admin = {
      id: decoded.userId,
      adminLevel: adminData.adminLevel,
      permissionSet: adminData.permissionSet || [],
      sessionId: sessionId,
      email: adminData.email,
      ...adminData,
    };

    // Log successful admin access
    AdminLogger.logActivity({
      type: "ADMIN_ACCESS",
      userId: req.admin.id,
      action: "API_ACCESS",
      resourceType: "ADMIN",
      status: "SUCCESS",
      message: `Admin accessed API endpoint: ${req.method} ${req.originalUrl}`,
    });

    next();
  } catch (error) {
    AdminLogger.logError({
      errorType: "ADMIN_AUTH_ERROR",
      message: error.message,
      stack: error.stack,
    });

    res.status(401).json({
      success: false,
      message: "Admin token invalid or expired",
    });
  }
};

module.exports = { adminProtect };
