/**
 * Admin Analytics Routes
 * Handles analytics and monitoring operations
 */

const express = require("express");
const router = express.Router();
const adminAnalyticsController = require("../controllers/adminAnalyticsController");
const { adminProtect } = require("../middleware/adminAuthMiddleware");
const { adminAuthorize } = require("../middleware/adminAuthorizeMiddleware");
const { auditTrail } = require("../middleware/auditTrailMiddleware");

// Apply admin protection and audit trail to all routes
router.use(adminProtect);
router.use(auditTrail);
router.use(adminAuthorize(["SUPER_ADMIN", "ADMIN", "MODERATOR"]));

/**
 * Get dashboard overview
 * GET /api/v1/admin/analytics/overview
 */
router.get("/overview", adminAnalyticsController.getDashboardOverview);

/**
 * Get user statistics
 * GET /api/v1/admin/analytics/users
 */
router.get("/users", adminAnalyticsController.getUserStatistics);

/**
 * Get system health
 * GET /api/v1/admin/analytics/health
 */
router.get("/health", adminAnalyticsController.getSystemHealth);

/**
 * Get login activity statistics
 * GET /api/v1/admin/analytics/login-activity
 */
router.get("/login-activity", adminAnalyticsController.getLoginActivityStats);

/**
 * Get suspicious activities
 * GET /api/v1/admin/analytics/suspicious
 */
router.get("/suspicious", adminAnalyticsController.getSuspiciousActivities);

/**
 * Get feature usage statistics
 * GET /api/v1/admin/analytics/features
 */
router.get("/features", adminAnalyticsController.getFeatureUsage);

/**
 * Get active admin sessions
 * GET /api/v1/admin/analytics/active-sessions
 */
router.get("/active-sessions", adminAnalyticsController.getActiveSessions);

/**
 * Get combined dashboard data
 * GET /api/v1/admin/dashboard
 */
router.get("/dashboard", adminAnalyticsController.getDashboardData);

module.exports = router;
