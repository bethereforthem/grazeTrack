/**
 * Admin Authorization Middleware
 * Implements role-based access control for admin operations
 */

const AdminLogger = require("../utils/adminLogger");

/**
 * Admin Authorization Middleware
 * Checks if admin has required admin level/permissions
 *
 * Usage:
 * - router.delete('/users/:id', adminProtect, adminAuthorize('SUPER_ADMIN'), deleteUser)
 * - router.put('/users/:id/ban', adminProtect, adminAuthorize(['SUPER_ADMIN', 'ADMIN']), banUser)
 */
const adminAuthorize = (requiredLevels) => {
  // Allow single string or array of levels
  const allowedLevels = Array.isArray(requiredLevels)
    ? requiredLevels
    : [requiredLevels];

  return (req, res, next) => {
    try {
      // req.admin should be set by adminProtect middleware
      if (!req.admin) {
        return res.status(401).json({
          success: false,
          message: "Admin authentication required",
        });
      }

      // Check if admin has required level
      if (!allowedLevels.includes(req.admin.adminLevel)) {
        AdminLogger.logSecurityEvent({
          eventType: "UNAUTHORIZED_ADMIN_ACTION",
          userId: req.admin.id,
          ipAddress: req.ip,
          description: `Admin attempted unauthorized action: ${req.method} ${req.originalUrl}. Required: ${allowedLevels.join(", ")}, Has: ${req.admin.adminLevel}`,
          severity: "HIGH",
          action: "BLOCK",
        });

        return res.status(403).json({
          success: false,
          message: `Admin level '${req.admin.adminLevel}' is not authorized for this action. Required: ${allowedLevels.join(" or ")}`,
        });
      }

      // Log authorized action
      AdminLogger.logActivity({
        type: "ADMIN_AUTHORIZATION",
        userId: req.admin.id,
        action: "AUTHORIZED_ACTION",
        resourceType: "ADMIN",
        status: "SUCCESS",
        message: `Admin authorized for action: ${req.method} ${req.originalUrl}`,
      });

      next();
    } catch (error) {
      AdminLogger.logError({
        errorType: "ADMIN_AUTHORIZATION_ERROR",
        message: error.message,
        userId: req.admin?.id,
      });

      res.status(500).json({
        success: false,
        message: "Authorization check failed",
      });
    }
  };
};

/**
 * Check Admin Permissions
 * Verifies if admin has specific permission
 *
 * Usage:
 * router.post('/admin/users', adminProtect, checkAdminPermission('MANAGE_USERS'), createUser)
 */
const checkAdminPermission = (requiredPermission) => {
  return (req, res, next) => {
    try {
      if (!req.admin) {
        return res.status(401).json({
          success: false,
          message: "Admin authentication required",
        });
      }

      // SUPER_ADMIN has all permissions
      if (req.admin.adminLevel === "SUPER_ADMIN") {
        return next();
      }

      // Check specific permission
      if (
        !req.admin.permissionSet ||
        !req.admin.permissionSet.includes(requiredPermission)
      ) {
        AdminLogger.logSecurityEvent({
          eventType: "PERMISSION_DENIED",
          userId: req.admin.id,
          ipAddress: req.ip,
          description: `Admin lacks permission: ${requiredPermission}`,
          severity: "MEDIUM",
        });

        return res.status(403).json({
          success: false,
          message: `Permission denied. Required: ${requiredPermission}`,
        });
      }

      next();
    } catch (error) {
      AdminLogger.logError({
        errorType: "PERMISSION_CHECK_ERROR",
        message: error.message,
        userId: req.admin?.id,
      });

      res.status(500).json({
        success: false,
        message: "Permission check failed",
      });
    }
  };
};

/**
 * Verify Super Admin Only
 * Ensures only SUPER_ADMIN can access critical operations
 */
const superAdminOnly = (req, res, next) => {
  if (!req.admin) {
    return res.status(401).json({
      success: false,
      message: "Admin authentication required",
    });
  }

  if (req.admin.adminLevel !== "SUPER_ADMIN") {
    AdminLogger.logSecurityEvent({
      eventType: "SUPER_ADMIN_ACCESS_DENIED",
      userId: req.admin.id,
      ipAddress: req.ip,
      description: `Non-SUPER_ADMIN attempted critical operation: ${req.method} ${req.originalUrl}`,
      severity: "HIGH",
      action: "BLOCK",
    });

    return res.status(403).json({
      success: false,
      message: "This action requires SUPER_ADMIN access",
    });
  }

  next();
};

module.exports = {
  adminAuthorize,
  checkAdminPermission,
  superAdminOnly,
};
