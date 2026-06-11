/**
 * Activity Log Service
 * Manages activity logs and audit trail operations
 */

const { db } = require("../config/firebase");
const AdminLogger = require("../utils/adminLogger");

class ActivityLogService {
  /**
   * Get activity logs with filters
   * @param {Object} options - Filter options
   */
  static async getActivityLogs(options = {}) {
    try {
      const {
        page = 1,
        limit = 50,
        userId = null,
        actionType = null,
        resourceType = null,
        status = null,
        startDate = null,
        endDate = null,
      } = options;

      let query = db.collection("activity_logs");

      // Apply filters
      if (userId) {
        query = query.where("userId", "==", userId);
      }

      if (actionType) {
        query = query.where("actionType", "==", actionType);
      }

      if (resourceType) {
        query = query.where("resourceType", "==", resourceType);
      }

      if (status) {
        query = query.where("status", "==", status);
      }

      // Get total count
      const countSnapshot = await query.count().get();
      const totalLogs = countSnapshot.data().count;

      // Apply date range and pagination
      const offset = (page - 1) * limit;
      let snapshotQuery = query
        .orderBy("timestamp", "desc")
        .offset(offset)
        .limit(limit);

      // Add date filters if provided
      if (startDate) {
        snapshotQuery = snapshotQuery.where(
          "timestamp",
          ">=",
          new Date(startDate),
        );
      }
      if (endDate) {
        snapshotQuery = snapshotQuery.where(
          "timestamp",
          "<=",
          new Date(endDate),
        );
      }

      const snapshot = await snapshotQuery.get();

      const logs = [];
      snapshot.forEach((doc) => {
        logs.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      return {
        success: true,
        logs: logs,
        pagination: {
          page: page,
          limit: limit,
          total: totalLogs,
          totalPages: Math.ceil(totalLogs / limit),
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "GET_ACTIVITY_LOGS_ERROR",
        message: error.message,
      });
      throw error;
    }
  }

  /**
   * Get single log entry
   * @param {String} logId - Log ID
   */
  static async getLogById(logId) {
    try {
      const logDoc = await db.collection("activity_logs").doc(logId).get();
      if (!logDoc.exists) {
        throw new Error("Log entry not found");
      }

      return {
        success: true,
        log: {
          id: logDoc.id,
          ...logDoc.data(),
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "GET_LOG_ERROR",
        message: error.message,
      });
      throw error;
    }
  }

  /**
   * Search activity logs with advanced filters
   * @param {Object} searchParams - Search parameters
   */
  static async searchLogs(searchParams) {
    try {
      const {
        query = "",
        actionType = null,
        userId = null,
        ipAddress = null,
        status = null,
        startDate = null,
        endDate = null,
        page = 1,
        limit = 50,
      } = searchParams;

      let collection = db.collection("activity_logs");
      let results = [];

      // Build query filters
      let q = collection;

      if (actionType) q = q.where("actionType", "==", actionType);
      if (userId) q = q.where("userId", "==", userId);
      if (status) q = q.where("status", "==", status);

      const snapshot = await q.orderBy("timestamp", "desc").get();

      // Post-filter in memory for IP address and date range
      snapshot.forEach((doc) => {
        const data = doc.data();

        // Filter by IP if provided
        if (ipAddress && data.ipAddress !== ipAddress) return;

        // Filter by date range
        if (startDate && new Date(data.timestamp) < new Date(startDate)) return;
        if (endDate && new Date(data.timestamp) > new Date(endDate)) return;

        // Filter by search query (full-text-like)
        if (query) {
          const searchableText =
            `${data.userId} ${data.actionType} ${data.resourceType} ${data.message || ""}`.toLowerCase();
          if (!searchableText.includes(query.toLowerCase())) return;
        }

        results.push({
          id: doc.id,
          ...data,
        });
      });

      // Apply pagination
      const offset = (page - 1) * limit;
      const paginatedResults = results.slice(offset, offset + limit);

      return {
        success: true,
        logs: paginatedResults,
        pagination: {
          page: page,
          limit: limit,
          total: results.length,
          totalPages: Math.ceil(results.length / limit),
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "SEARCH_LOGS_ERROR",
        message: error.message,
      });
      throw error;
    }
  }

  /**
   * Export logs as CSV or JSON
   * @param {Object} options - Export options
   */
  static async exportLogs(options = {}) {
    try {
      const {
        format = "json", // json or csv
        startDate = null,
        endDate = null,
        userId = null,
        actionType = null,
      } = options;

      let query = db.collection("activity_logs");

      if (userId) query = query.where("userId", "==", userId);
      if (actionType) query = query.where("actionType", "==", actionType);

      const snapshot = await query.orderBy("timestamp", "desc").get();

      let logs = [];
      snapshot.forEach((doc) => {
        const data = doc.data();

        if (startDate && new Date(data.timestamp) < new Date(startDate)) return;
        if (endDate && new Date(data.timestamp) > new Date(endDate)) return;

        logs.push({
          id: doc.id,
          ...data,
        });
      });

      if (format === "csv") {
        const csv = this._convertToCSV(logs);
        return {
          success: true,
          data: csv,
          filename: `activity-logs-${Date.now()}.csv`,
          contentType: "text/csv",
        };
      } else {
        const json = JSON.stringify(logs, null, 2);
        return {
          success: true,
          data: json,
          filename: `activity-logs-${Date.now()}.json`,
          contentType: "application/json",
        };
      }
    } catch (error) {
      AdminLogger.logError({
        errorType: "EXPORT_LOGS_ERROR",
        message: error.message,
      });
      throw error;
    }
  }

  /**
   * Convert logs to CSV format
   * @private
   */
  static _convertToCSV(logs) {
    if (logs.length === 0) return "No logs";

    const headers = [
      "ID",
      "Timestamp",
      "User ID",
      "Action",
      "Resource Type",
      "Resource ID",
      "Status",
      "IP Address",
      "User Agent",
    ];
    const rows = logs.map((log) => [
      log.id,
      log.timestamp,
      log.userId,
      log.actionType,
      log.resourceType,
      log.resourceId,
      log.status,
      log.ipAddress,
      log.userAgent || "",
    ]);

    const csv = [
      headers.join(","),
      ...rows.map((row) => row.map((cell) => `"${cell}"`).join(",")),
    ].join("\n");

    return csv;
  }

  /**
   * Get activity statistics
   * @param {String} period - time period (day, week, month)
   */
  static async getActivityStats(period = "week") {
    try {
      const now = new Date();
      let startDate = new Date();

      if (period === "day") {
        startDate.setDate(now.getDate() - 1);
      } else if (period === "week") {
        startDate.setDate(now.getDate() - 7);
      } else if (period === "month") {
        startDate.setMonth(now.getMonth() - 1);
      }

      const snapshot = await db
        .collection("activity_logs")
        .where("timestamp", ">=", startDate)
        .orderBy("timestamp", "desc")
        .get();

      // Aggregate statistics
      const stats = {
        totalActions: 0,
        actionsByType: {},
        actionsByResourceType: {},
        actionsByStatus: {},
        topUsers: {},
      };

      snapshot.forEach((doc) => {
        const data = doc.data();
        stats.totalActions++;

        // Count by action type
        stats.actionsByType[data.actionType] =
          (stats.actionsByType[data.actionType] || 0) + 1;

        // Count by resource type
        stats.actionsByResourceType[data.resourceType] =
          (stats.actionsByResourceType[data.resourceType] || 0) + 1;

        // Count by status
        stats.actionsByStatus[data.status] =
          (stats.actionsByStatus[data.status] || 0) + 1;

        // Top users
        if (!stats.topUsers[data.userId]) {
          stats.topUsers[data.userId] = 0;
        }
        stats.topUsers[data.userId]++;
      });

      // Get top 5 users
      const topUsers = Object.entries(stats.topUsers)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 5)
        .reduce((obj, [key, val]) => {
          obj[key] = val;
          return obj;
        }, {});

      return {
        success: true,
        period: period,
        stats: {
          ...stats,
          topUsers: topUsers,
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "GET_ACTIVITY_STATS_ERROR",
        message: error.message,
      });
      throw error;
    }
  }
}

module.exports = ActivityLogService;
