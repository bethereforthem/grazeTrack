/**
 * Admin User Management Routes
 * Handles all user management operations
 */

const express = require("express");
const router = express.Router();
const adminUserController = require("../controllers/adminUserController");
const { adminProtect } = require("../middleware/adminAuthMiddleware");
const {
  adminAuthorize,
  superAdminOnly,
} = require("../middleware/adminAuthorizeMiddleware");
const AdminValidator = require("../utils/adminValidator");
const { auditTrail } = require("../middleware/auditTrailMiddleware");

// Apply admin protection and audit trail to all routes
router.use(adminProtect);
router.use(auditTrail);

/**
 * Get all users
 * GET /api/v1/admin/users
 */
router.get(
  "/",
  adminAuthorize(["SUPER_ADMIN", "ADMIN"]),
  adminUserController.getAllUsers,
);

/**
 * Get user by ID
 * GET /api/v1/admin/users/:id
 */
router.get(
  "/:id",
  adminAuthorize(["SUPER_ADMIN", "ADMIN"]),
  adminUserController.getUserById,
);

/**
 * Create new user
 * POST /api/v1/admin/users
 */
router.post(
  "/",
  adminAuthorize(["SUPER_ADMIN", "ADMIN"]),
  AdminValidator.validateUserData(),
  AdminValidator.handleValidationErrors,
  adminUserController.createUser,
);

/**
 * Update user
 * PUT /api/v1/admin/users/:id
 */
router.put(
  "/:id",
  adminAuthorize(["SUPER_ADMIN", "ADMIN"]),
  adminUserController.updateUser,
);

/**
 * Suspend user
 * PUT /api/v1/admin/users/:id/suspend
 */
router.put(
  "/:id/suspend",
  adminAuthorize(["SUPER_ADMIN", "ADMIN"]),
  adminUserController.suspendUser,
);

/**
 * Reactivate user
 * PUT /api/v1/admin/users/:id/reactivate
 */
router.put(
  "/:id/reactivate",
  adminAuthorize(["SUPER_ADMIN", "ADMIN"]),
  adminUserController.reactivateUser,
);

/**
 * Delete user (SUPER_ADMIN only)
 * DELETE /api/v1/admin/users/:id
 */
router.delete("/:id", superAdminOnly, adminUserController.deleteUser);

/**
 * Get user activity summary
 * GET /api/v1/admin/users/:id/activity
 */
router.get(
  "/:id/activity",
  adminAuthorize(["SUPER_ADMIN", "ADMIN"]),
  adminUserController.getUserActivitySummary,
);

/**
 * Reset user password
 * POST /api/v1/admin/users/:id/reset-password
 */
router.post(
  "/:id/reset-password",
  adminAuthorize(["SUPER_ADMIN"]),
  adminUserController.resetUserPassword,
);

module.exports = router;
