/**
 * Admin Authentication Routes
 * Handles admin login, logout, and session management
 */

const express = require("express");
const router = express.Router();
const adminAuthController = require("../controllers/adminAuthController");
const { adminProtect } = require("../middleware/adminAuthMiddleware");
const {
  adminAuthorize,
  superAdminOnly,
} = require("../middleware/adminAuthorizeMiddleware");
const AdminValidator = require("../utils/adminValidator");

/**
 * Public routes (no auth required)
 */
// Admin login
router.post(
  "/login",
  AdminValidator.validateAdminLogin(),
  AdminValidator.handleValidationErrors,
  adminAuthController.adminLogin,
);

/**
 * Protected routes (admin auth required)
 */
// Logout
router.post("/logout", adminProtect, adminAuthController.adminLogout);

// Refresh token
router.post("/refresh", adminProtect, adminAuthController.refreshToken);

// Verify session
router.get("/verify", adminProtect, adminAuthController.verifySession);

// Create new admin (SUPER_ADMIN only)
router.post(
  "/create-admin",
  adminProtect,
  superAdminOnly,
  adminAuthController.createAdmin,
);

module.exports = router;
