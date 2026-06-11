/**
 * Admin Authentication Service
 * Handles admin login, logout, and token management
 */

const bcrypt = require("bcryptjs");
const { generateToken, verifyToken } = require("../config/jwt");
const { db } = require("../config/firebase");
const Encryption = require("../utils/encryption");
const AdminLogger = require("../utils/adminLogger");

class AdminAuthService {
  /**
   * Authenticate admin user
   * @param {String} email - Admin email
   * @param {String} password - Admin password
   * @param {String} ipAddress - Client IP
   * @param {String} userAgent - Client user agent
   * @returns {Object} Token, admin data, and session info
   */
  static async authenticateAdmin(email, password, ipAddress, userAgent) {
    try {
      console.log(
        "[AUTH DEBUG] Attempting login for email:",
        email.toLowerCase(),
      );

      // Find admin by email
      const adminSnapshot = await db
        .collection("admin_users")
        .where("email", "==", email.toLowerCase())
        .limit(1)
        .get();

      if (adminSnapshot.empty) {
        console.log(
          "[AUTH DEBUG] No admin found with email:",
          email.toLowerCase(),
        );
        AdminLogger.logAuthAttempt({
          email: email,
          ipAddress: ipAddress,
          success: false,
          method: "EMAIL_PASSWORD",
          reason: "Email not found",
        });

        throw new Error("Invalid credentials");
      }

      const adminDoc = adminSnapshot.docs[0];
      const adminData = adminDoc.data();
      const adminId = adminDoc.id;
      console.log("[AUTH DEBUG] Admin found:", {
        adminId,
        email: adminData.email,
        status: adminData.status,
        adminLevel: adminData.adminLevel,
      });

      // Check if admin account is active
      console.log("[AUTH DEBUG] Checking status:", adminData.status);
      if (!adminData.status || adminData.status !== "ACTIVE") {
        console.log(
          "[AUTH DEBUG] Account not active - status:",
          adminData.status,
        );
        AdminLogger.logAuthAttempt({
          userId: adminId,
          ipAddress: ipAddress,
          success: false,
          method: "EMAIL_PASSWORD",
          reason: `Account is ${adminData.status || "INACTIVE"}`,
        });

        throw new Error(`Admin account is ${adminData.status || "INACTIVE"}`);
      }

      // Verify password
      console.log("[AUTH DEBUG] Verifying password for admin:", adminId);
      const isPasswordValid = await bcrypt.compare(
        password,
        adminData.password,
      );
      console.log("[AUTH DEBUG] Password valid:", isPasswordValid);
      if (!isPasswordValid) {
        AdminLogger.logAuthAttempt({
          userId: adminId,
          ipAddress: ipAddress,
          success: false,
          method: "EMAIL_PASSWORD",
          reason: "Invalid password",
        });

        throw new Error("Invalid credentials");
      }

      // Save session FIRST so we get its Firestore document ID,
      // then embed that ID inside the JWT. This lets the middleware do a
      // direct doc(sessionId).get() lookup — no composite index required.
      const sessionExpiryTime = new Date();
      sessionExpiryTime.setDate(sessionExpiryTime.getDate() + 7);

      const sessionData = {
        adminId: adminId,
        ipAddress: ipAddress,
        userAgent: userAgent,
        isActive: true,
        createdAt: new Date(),
        lastActivityAt: new Date(),
        expiresAt: sessionExpiryTime,
        loginMethod: "PASSWORD",
        deviceInfo: this._parseUserAgent(userAgent),
        mfaVerified: false,
        riskLevel: "LOW",
      };

      // Step 1: Save session → get its Firestore document ID
      const sessionDocRef = await db
        .collection("admin_sessions")
        .add(sessionData);

      // Step 2: Create JWT with sessionId embedded so middleware can
      //         look it up directly without any Firestore query index
      const adminSecret =
        process.env.ADMIN_JWT_SECRET || process.env.JWT_SECRET;
      const token = generateToken(
        adminId,
        adminData.adminLevel,
        adminSecret,
        process.env.ADMIN_TOKEN_EXPIRY || "7d",
        { sessionId: sessionDocRef.id },
      );

      // Step 3: Store token hash on the session document
      await db.collection("admin_sessions").doc(sessionDocRef.id).update({
        tokenHash: Encryption.hash(token),
      });

      // Update last login timestamp
      await db.collection("admin_users").doc(adminId).update({
        lastLoginAt: new Date(),
      });

      // Log successful auth
      AdminLogger.logAuthAttempt({
        userId: adminId,
        ipAddress: ipAddress,
        success: true,
        method: "EMAIL_PASSWORD",
      });

      return {
        success: true,
        token: token,
        sessionId: sessionDocRef.id,
        admin: {
          id: adminId,
          email: adminData.email,
          adminLevel: adminData.adminLevel,
          permissionSet: adminData.permissionSet || [],
          metadata: adminData.metadata || {},
        },
        expiresIn: "7d",
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "ADMIN_AUTH_ERROR",
        message: error.message,
        context: { email },
      });

      throw error;
    }
  }

  /**
   * Logout admin user
   * @param {String} adminId - Admin ID
   * @param {String} sessionId - Session ID
   */
  static async logoutAdmin(adminId, sessionId) {
    try {
      // Deactivate session
      await db.collection("admin_sessions").doc(sessionId).update({
        isActive: false,
        logoutAt: new Date(),
      });

      AdminLogger.logActivity({
        type: "ADMIN_LOGOUT",
        userId: adminId,
        action: "LOGOUT",
        resourceType: "SESSION",
        resourceId: sessionId,
        status: "SUCCESS",
        message: `Admin logged out. Session: ${sessionId}`,
      });

      return {
        success: true,
        message: "Logout successful",
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "LOGOUT_ERROR",
        message: error.message,
        userId: adminId,
      });

      throw error;
    }
  }

  /**
   * Create new admin user
   * @param {Object} adminData - Admin details
   * @param {String} createdByAdminId - Super admin ID
   */
  static async createAdmin(adminData, createdByAdminId) {
    try {
      // Validate required fields
      if (!adminData.email || !adminData.password) {
        throw new Error("Email and password are required");
      }

      // Check if email already exists
      const existingAdmin = await db
        .collection("admin_users")
        .where("email", "==", adminData.email.toLowerCase())
        .get();

      if (!existingAdmin.empty) {
        throw new Error("Admin email already exists");
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(adminData.password, 12);

      // Create admin document
      const newAdminData = {
        email: adminData.email.toLowerCase(),
        password: hashedPassword,
        adminLevel: adminData.adminLevel || "ADMIN",
        permissionSet: adminData.permissionSet || [],
        status: "ACTIVE",
        createdAt: new Date(),
        createdBy: createdByAdminId,
        updatedAt: new Date(),
        lastLoginAt: null,
        isPasswordChanged: false,
        twoFactorEnabled: false,
        metadata: {
          department: adminData.department || "",
          notes: adminData.notes || "",
        },
      };

      const docRef = await db.collection("admin_users").add(newAdminData);

      AdminLogger.logActivity({
        type: "ADMIN_CREATION",
        userId: createdByAdminId,
        action: "CREATE",
        resourceType: "ADMIN_USER",
        resourceId: docRef.id,
        status: "SUCCESS",
        message: `New admin created: ${adminData.email}`,
      });

      return {
        success: true,
        message: "Admin user created successfully",
        adminId: docRef.id,
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "CREATE_ADMIN_ERROR",
        message: error.message,
        userId: createdByAdminId,
      });

      throw error;
    }
  }

  /**
   * Refresh admin token
   * @param {String} adminId - Admin ID
   * @param {String} sessionId - Session ID
   */
  static async refreshToken(adminId, sessionId) {
    try {
      // Verify session exists and is active
      const sessionDoc = await db
        .collection("admin_sessions")
        .doc(sessionId)
        .get();
      if (!sessionDoc.exists) {
        throw new Error("Session not found");
      }

      const sessionData = sessionDoc.data();
      if (!sessionData.isActive) {
        throw new Error("Session is not active");
      }

      // Get admin data
      const adminDoc = await db.collection("admin_users").doc(adminId).get();
      if (!adminDoc.exists) {
        throw new Error("Admin not found");
      }

      // Generate new token
      const newToken = generateToken(
        {
          userId: adminId,
          role: adminDoc.data().adminLevel,
        },
        process.env.ADMIN_JWT_SECRET || "admin-secret-key",
        process.env.ADMIN_TOKEN_EXPIRY || "7d",
      );

      // Update session with new token
      const newExpiryTime = new Date();
      newExpiryTime.setDate(newExpiryTime.getDate() + 7);

      await db
        .collection("admin_sessions")
        .doc(sessionId)
        .update({
          tokenHash: Encryption.hash(newToken),
          expiresAt: newExpiryTime,
          lastActivityAt: new Date(),
        });

      return {
        success: true,
        token: newToken,
        expiresIn: "7d",
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "TOKEN_REFRESH_ERROR",
        message: error.message,
        userId: adminId,
      });

      throw error;
    }
  }

  /**
   * Parse user agent string
   * @private
   */
  static _parseUserAgent(userAgent) {
    const ua = userAgent || "";
    const result = {
      platform: "Unknown",
      browser: "Unknown",
      version: "",
    };

    if (ua.includes("Windows")) result.platform = "Windows";
    if (ua.includes("Mac")) result.platform = "macOS";
    if (ua.includes("Linux")) result.platform = "Linux";
    if (ua.includes("iPhone")) result.platform = "iOS";
    if (ua.includes("Android")) result.platform = "Android";

    if (ua.includes("Chrome")) result.browser = "Chrome";
    if (ua.includes("Firefox")) result.browser = "Firefox";
    if (ua.includes("Safari") && !ua.includes("Chrome"))
      result.browser = "Safari";
    if (ua.includes("Edge")) result.browser = "Edge";

    return result;
  }
}

module.exports = AdminAuthService;
