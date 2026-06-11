/**
 * Admin Activity Log Controller
 * Handles activity log operations
 */

const ActivityLogService = require("../services/activityLogService");
const AdminLogger = require("../utils/adminLogger");

/**
 * Get activity logs
 * GET /api/v1/admin/logs
 */
exports.getActivityLogs = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 50,
      userId,
      actionType,
      resourceType,
      status,
      startDate,
      endDate,
    } = req.query;

    const options = {
      page: parseInt(page) || 1,
      limit: Math.min(parseInt(limit) || 50, 100), // Max 100 per page
      userId: userId || null,
      actionType: actionType || null,
      resourceType: resourceType || null,
      status: status || null,
      startDate: startDate || null,
      endDate: endDate || null,
    };

    const result = await ActivityLogService.getActivityLogs(options);

    res.status(200).json({
      success: true,
      message: "Activity logs retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "GET_LOGS_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to retrieve activity logs",
    });
  }
};

/**
 * Get single log entry
 * GET /api/v1/admin/logs/:logId
 */
exports.getLogById = async (req, res) => {
  try {
    const { logId } = req.params;

    const result = await ActivityLogService.getLogById(logId);

    res.status(200).json({
      success: true,
      message: "Log entry retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "GET_LOG_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(error.message.includes("not found") ? 404 : 500).json({
      success: false,
      message: error.message || "Failed to retrieve log entry",
    });
  }
};

/**
 * Search activity logs
 * POST /api/v1/admin/logs/search
 */
exports.searchLogs = async (req, res) => {
  try {
    const {
      query = "",
      actionType,
      userId,
      ipAddress,
      status,
      startDate,
      endDate,
      page = 1,
      limit = 50,
    } = req.body;

    const searchParams = {
      query: query,
      actionType: actionType || null,
      userId: userId || null,
      ipAddress: ipAddress || null,
      status: status || null,
      startDate: startDate || null,
      endDate: endDate || null,
      page: parseInt(page) || 1,
      limit: Math.min(parseInt(limit) || 50, 100),
    };

    const result = await ActivityLogService.searchLogs(searchParams);

    res.status(200).json({
      success: true,
      message: "Logs searched successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "SEARCH_LOGS_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to search logs",
    });
  }
};

/**
 * Export activity logs
 * POST /api/v1/admin/logs/export
 */
exports.exportLogs = async (req, res) => {
  try {
    const {
      format = "json", // json or csv
      startDate,
      endDate,
      userId,
      actionType,
    } = req.body;

    const options = {
      format: format,
      startDate: startDate || null,
      endDate: endDate || null,
      userId: userId || null,
      actionType: actionType || null,
    };

    const result = await ActivityLogService.exportLogs(options);

    // Log the export action
    AdminLogger.logActivity({
      type: "LOGS_EXPORT",
      userId: req.admin.id,
      action: "EXPORT",
      resourceType: "ACTIVITY_LOG",
      status: "SUCCESS",
      message: `Admin exported activity logs in ${format} format`,
    });

    // Set response headers
    res.setHeader(
      "Content-Disposition",
      `attachment; filename="${result.filename}"`,
    );
    res.setHeader("Content-Type", result.contentType);

    res.status(200).send(result.data);
  } catch (error) {
    AdminLogger.logError({
      errorType: "EXPORT_LOGS_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to export logs",
    });
  }
};

/**
 * Get activity statistics
 * GET /api/v1/admin/logs/statistics
 */
exports.getActivityStats = async (req, res) => {
  try {
    const { period = "week" } = req.query;

    const result = await ActivityLogService.getActivityStats(period);

    res.status(200).json({
      success: true,
      message: "Activity statistics retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "ACTIVITY_STATS_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to retrieve activity statistics",
    });
  }
};
