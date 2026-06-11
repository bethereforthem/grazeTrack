/**
 * Admin Analytics Controller
 * Handles analytics and monitoring operations
 */

const AnalyticsService = require("../services/analyticsService");
const AdminLogger = require("../utils/adminLogger");

/**
 * Get dashboard overview
 * GET /api/v1/admin/analytics/overview
 */
exports.getDashboardOverview = async (req, res) => {
  try {
    const result = await AnalyticsService.getDashboardOverview();

    res.status(200).json({
      success: true,
      message: "Dashboard overview retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "DASHBOARD_OVERVIEW_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to retrieve dashboard overview",
    });
  }
};

/**
 * Get user statistics
 * GET /api/v1/admin/analytics/users
 */
exports.getUserStatistics = async (req, res) => {
  try {
    const { period = "month" } = req.query;

    const result = await AnalyticsService.getUserStatistics(period);

    res.status(200).json({
      success: true,
      message: "User statistics retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "USER_STATS_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to retrieve user statistics",
    });
  }
};

/**
 * Get system health
 * GET /api/v1/admin/analytics/health
 */
exports.getSystemHealth = async (req, res) => {
  try {
    const result = await AnalyticsService.getSystemHealth();

    res.status(200).json({
      success: true,
      message: "System health retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "HEALTH_CHECK_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to retrieve system health",
    });
  }
};

/**
 * Get login activity statistics
 * GET /api/v1/admin/analytics/login-activity
 */
exports.getLoginActivityStats = async (req, res) => {
  try {
    const { period = "week" } = req.query;

    const result = await AnalyticsService.getLoginActivityStats(period);

    res.status(200).json({
      success: true,
      message: "Login activity statistics retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "LOGIN_STATS_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to retrieve login activity statistics",
    });
  }
};

/**
 * Get suspicious activities
 * GET /api/v1/admin/analytics/suspicious
 */
exports.getSuspiciousActivities = async (req, res) => {
  try {
    const { limit = 20 } = req.query;

    const result = await AnalyticsService.getSuspiciousActivities(
      parseInt(limit) || 20,
    );

    res.status(200).json({
      success: true,
      message: "Suspicious activities retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "SUSPICIOUS_ACTIVITIES_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to retrieve suspicious activities",
    });
  }
};

/**
 * Get feature usage statistics
 * GET /api/v1/admin/analytics/features
 */
exports.getFeatureUsage = async (req, res) => {
  try {
    const { period = "month" } = req.query;

    const result = await AnalyticsService.getFeatureUsage(period);

    res.status(200).json({
      success: true,
      message: "Feature usage statistics retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "FEATURE_USAGE_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to retrieve feature usage statistics",
    });
  }
};

/**
 * Get active admin sessions
 * GET /api/v1/admin/analytics/active-sessions
 */
exports.getActiveSessions = async (req, res) => {
  try {
    const result = await AnalyticsService.getActiveSessions();
    res.status(200).json({
      success: true,
      message: "Active sessions retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "GET_ACTIVE_SESSIONS_ERROR",
      message: error.message,
      userId: req.admin.id,
    });
    res.status(500).json({
      success: false,
      message: "Failed to retrieve active sessions",
    });
  }
};

/**
 * Get combined dashboard data
 * GET /api/v1/admin/analytics/dashboard
 * Uses Promise.allSettled so one failing sub-service never breaks the whole dashboard.
 */
exports.getDashboardData = async (req, res) => {
  try {
    const [overviewRes, userStatsRes, healthRes, loginStatsRes, suspiciousRes] =
      await Promise.allSettled([
        AnalyticsService.getDashboardOverview(),
        AnalyticsService.getUserStatistics("month"),
        AnalyticsService.getSystemHealth(),
        AnalyticsService.getLoginActivityStats("week"),
        AnalyticsService.getSuspiciousActivities(10),
      ]);

    const val = (result, fallback = {}) =>
      result.status === "fulfilled" ? result.value : fallback;

    res.status(200).json({
      success: true,
      message: "Dashboard data retrieved successfully",
      data: {
        overview:              val(overviewRes).overview      || {},
        userStatistics:        val(userStatsRes).statistics   || {},
        systemHealth:          val(healthRes).health          || {},
        loginActivity:         val(loginStatsRes).statistics  || {},
        suspiciousActivities:  val(suspiciousRes).activities  || [],
        suspiciousSummary:     val(suspiciousRes).summary     || { total: 0 },
      },
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "DASHBOARD_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to retrieve dashboard data",
    });
  }
};
