/**
 * Admin Authentication Controller
 * Handles admin login, logout, and token management
 */

const AdminAuthService = require("../services/adminAuthService");
const AdminValidator = require("../utils/adminValidator");
const AdminLogger = require("../utils/adminLogger");

/**
 * Admin login
 * POST /api/v1/admin/auth/login
 */
exports.adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    const result = await AdminAuthService.authenticateAdmin(
      email,
      password,
      req.ip,
      req.get("user-agent"),
    );

    res.status(200).json({
      success: true,
      message: "Admin login successful",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "ADMIN_LOGIN_ERROR",
      message: error.message,
      context: { email: req.body.email },
    });

    res.status(401).json({
      success: false,
      message: error.message || "Login failed",
    });
  }
};

/**
 * Admin logout
 * POST /api/v1/admin/auth/logout
 */
exports.adminLogout = async (req, res) => {
  try {
    await AdminAuthService.logoutAdmin(req.admin.id, req.admin.sessionId);

    res.status(200).json({
      success: true,
      message: "Admin logout successful",
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "ADMIN_LOGOUT_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Logout failed",
    });
  }
};

/**
 * Refresh admin token
 * POST /api/v1/admin/auth/refresh
 */
exports.refreshToken = async (req, res) => {
  try {
    const result = await AdminAuthService.refreshToken(
      req.admin.id,
      req.admin.sessionId,
    );

    res.status(200).json({
      success: true,
      message: "Token refreshed successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "TOKEN_REFRESH_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(401).json({
      success: false,
      message: "Token refresh failed",
    });
  }
};

/**
 * Verify admin session
 * GET /api/v1/admin/auth/verify
 */
exports.verifySession = async (req, res) => {
  try {
    // If we reach here, the admin is already authenticated (adminProtect middleware)
    res.status(200).json({
      success: true,
      message: "Admin session is valid",
      admin: {
        id: req.admin.id,
        email: req.admin.email,
        adminLevel: req.admin.adminLevel,
        permissionSet: req.admin.permissionSet,
      },
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: "Session verification failed",
    });
  }
};

/**
 * Create new admin user (SUPER_ADMIN only)
 * POST /api/v1/admin/auth/create-admin
 */
exports.createAdmin = async (req, res) => {
  try {
    const { email, password, adminLevel, department, notes } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    const adminData = {
      email: email.toLowerCase(),
      password: password,
      adminLevel: adminLevel || "ADMIN",
      department: department || "",
      notes: notes || "",
    };

    const result = await AdminAuthService.createAdmin(adminData, req.admin.id);

    AdminLogger.logActivity({
      type: "ADMIN_CREATION",
      userId: req.admin.id,
      action: "CREATE",
      resourceType: "ADMIN_USER",
      resourceId: result.adminId,
      status: "SUCCESS",
      message: `New admin created by ${req.admin.email}`,
    });

    res.status(201).json({
      success: true,
      message: "Admin user created successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "CREATE_ADMIN_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(400).json({
      success: false,
      message: error.message || "Failed to create admin",
    });
  }
};
