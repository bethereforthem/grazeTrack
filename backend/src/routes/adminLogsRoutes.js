/**
 * Admin Activity Logs Routes
 * Handles activity log operations
 */

const express = require("express");
const router = express.Router();
const adminLogsController = require("../controllers/adminLogsController");
const { adminProtect } = require("../middleware/adminAuthMiddleware");
const { adminAuthorize } = require("../middleware/adminAuthorizeMiddleware");
const AdminValidator = require("../utils/adminValidator");
const { auditTrail } = require("../middleware/auditTrailMiddleware");

// Apply admin protection and audit trail to all routes
router.use(adminProtect);
router.use(auditTrail);
router.use(adminAuthorize(["SUPER_ADMIN", "ADMIN", "MODERATOR"]));

/**
 * Get activity logs
 * GET /api/v1/admin/logs
 */
router.get(
  "/",
  AdminValidator.validateLogFilters(),
  AdminValidator.handleValidationErrors,
  adminLogsController.getActivityLogs,
);

/**
 * Get log by ID
 * GET /api/v1/admin/logs/:logId
 */
router.get("/:logId", adminLogsController.getLogById);

/**
 * Search logs
 * POST /api/v1/admin/logs/search
 */
router.post("/search", adminLogsController.searchLogs);

/**
 * Export logs
 * POST /api/v1/admin/logs/export
 */
router.post(
  "/export",
  adminAuthorize(["SUPER_ADMIN", "ADMIN"]),
  adminLogsController.exportLogs,
);

/**
 * Get activity statistics
 * GET /api/v1/admin/logs/statistics
 */
router.get("/statistics", adminLogsController.getActivityStats);

module.exports = router;
