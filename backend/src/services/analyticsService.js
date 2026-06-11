/**
 * Analytics Service
 * Generates analytics and system metrics
 */

const { db } = require("../config/firebase");
const AdminLogger = require("../utils/adminLogger");

class AnalyticsService {
  /**
   * Get dashboard overview metrics
   */
  static async getDashboardOverview() {
    try {
      // Get user counts
      const userSnapshot = await db.collection("users").count().get();
      const totalUsers = userSnapshot.data().count;

      const activeUsersSnapshot = await db
        .collection("users")
        .where("isActive", "==", true)
        .count()
        .get();
      const activeUsers = activeUsersSnapshot.data().count;

      const suspendedUsersSnapshot = await db
        .collection("users")
        .where("isActive", "==", false)
        .count()
        .get();
      const suspendedUsers = suspendedUsersSnapshot.data().count;

      // Get active sessions
      const activeSessionsSnapshot = await db
        .collection("user_sessions")
        .where("isActive", "==", true)
        .count()
        .get();
      const activeSessions = activeSessionsSnapshot.data().count;

      // Get new registrations today.
      // createdAt is stored as an ISO string ("2026-05-13T10:00:00.000Z"),
      // so we compare using an ISO string — not a Date object — to avoid type mismatch.
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const todayISO = today.toISOString();
      const newTodaySnapshot = await db
        .collection("users")
        .where("createdAt", ">=", todayISO)
        .count()
        .get();
      const newToday = newTodaySnapshot.data().count;

      // Get recent activities
      const recentActivitiesSnapshot = await db
        .collection("activity_logs")
        .orderBy("timestamp", "desc")
        .limit(10)
        .get();

      const recentActivities = [];
      recentActivitiesSnapshot.forEach((doc) => {
        recentActivities.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      return {
        success: true,
        overview: {
          totalUsers: totalUsers,
          activeUsers: activeUsers,
          suspendedUsers: suspendedUsers,
          activeSessions: activeSessions,
          newRegistrationsToday: newToday,
          activeUsersPercentage:
            totalUsers > 0 ? Math.round((activeUsers / totalUsers) * 100) : 0,
          recentActivities: recentActivities,
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "DASHBOARD_OVERVIEW_ERROR",
        message: error.message,
      });
      throw error;
    }
  }

  /**
   * Get user statistics
   */
  static async getUserStatistics(period = "month") {
    try {
      const now = new Date();
      let startDate = new Date();

      if (period === "week") {
        startDate.setDate(now.getDate() - 7);
      } else if (period === "month") {
        startDate.setMonth(now.getMonth() - 1);
      } else if (period === "year") {
        startDate.setFullYear(now.getFullYear() - 1);
      }

      // New registrations in period — ISO string comparison matches stored format
      const startDateISO = startDate.toISOString();
      const newUsersSnapshot = await db
        .collection("users")
        .where("createdAt", ">=", startDateISO)
        .count()
        .get();
      const newUsers = newUsersSnapshot.data().count;

      // Users by role
      const roleStats = {};
      const roles = ["Admin", "Farmer"];

      for (const role of roles) {
        const snapshot = await db
          .collection("users")
          .where("role", "==", role)
          .count()
          .get();
        roleStats[role] = snapshot.data().count;
      }

      // Active vs Inactive
      const activeSnapshot = await db
        .collection("users")
        .where("isActive", "==", true)
        .count()
        .get();
      const active = activeSnapshot.data().count;

      const inactiveSnapshot = await db
        .collection("users")
        .where("isActive", "==", false)
        .count()
        .get();
      const inactive = inactiveSnapshot.data().count;

      return {
        success: true,
        period: period,
        statistics: {
          newRegistrations: newUsers,
          usersByRole: roleStats,
          activeUsers: active,
          inactiveUsers: inactive,
          totalUsers: active + inactive,
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "USER_STATISTICS_ERROR",
        message: error.message,
      });
      throw error;
    }
  }

  /**
   * Get system health metrics
   */
  static async getSystemHealth() {
    // Measure actual API response time from the moment this function is called
    const startTime = Date.now();
    try {
      // Verify the database is reachable — if this throws, the whole function fails
      await db.collection("users").limit(1).get();
      const dbStatus = "HEALTHY";
      const responseTime = Date.now() - startTime;

      // Count activity logs from the last hour.
      // Use a SINGLE inequality filter (timestamp >=) then filter status in memory
      // to avoid requiring a composite Firestore index.
      const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
      let totalLogs = 0;
      let failedLogs = 0;
      try {
        const recentSnap = await db
          .collection("activity_logs")
          .where("timestamp", ">=", oneHourAgo)
          .get();
        recentSnap.forEach((doc) => {
          totalLogs++;
          if (doc.data().status === "FAILED") failedLogs++;
        });
      } catch (_) {
        // activity_logs collection may not have documents yet — treat as zero
      }

      const errorRate =
        totalLogs > 0 ? ((failedLogs / totalLogs) * 100).toFixed(2) + "%" : "0.00%";

      // Real Node.js process uptime — not a hardcoded number
      const uptimeSecs = process.uptime();
      const uptimeStr =
        uptimeSecs > 3600
          ? `${(uptimeSecs / 3600).toFixed(1)}h`
          : `${Math.round(uptimeSecs / 60)}m`;

      return {
        success: true,
        health: {
          databaseStatus: dbStatus,
          apiResponseTime: responseTime,
          errorRate,
          uptime: uptimeStr,
          lastCheck: new Date().toISOString(),
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "SYSTEM_HEALTH_ERROR",
        message: error.message,
      });
      throw error;
    }
  }

  /**
   * Get login activity statistics.
   * Combines three data sources to build a complete picture:
   *   1. activity_logs  — regular user logins tracked since logging was added
   *   2. admin_sessions — every admin login (historical, always available)
   *   3. user_sessions  — user app sessions created on login
   * Filtering is done in memory to avoid composite Firestore indexes.
   */
  static async getLoginActivityStats(period = "week") {
    try {
      const now = new Date();
      let startDate = new Date();
      if (period === "week") startDate.setDate(now.getDate() - 7);
      else if (period === "month") startDate.setMonth(now.getMonth() - 1);

      const stats = {
        totalLogins: 0,
        successfulLogins: 0,
        failedLogins: 0,
        uniqueUsers: new Set(),
        loginsPerDay: {},
        // Track which (userId+date) pairs have been counted to avoid double-counting
        // when a user session and an activity_log both exist for the same login.
        counted: new Set(),
      };

      function parseTs(ts) {
        if (!ts) return null;
        if (ts._seconds !== undefined) return new Date(ts._seconds * 1000);
        if (ts.toDate) return ts.toDate();
        return new Date(ts);
      }

      function recordLogin(userId, ts, status) {
        if (!ts || ts < startDate) return;
        const dateKey = ts.toISOString().split("T")[0];
        const dedupeKey = `${userId}-${dateKey}-${status}`;
        if (stats.counted.has(dedupeKey)) return;
        stats.counted.add(dedupeKey);
        stats.totalLogins++;
        stats.uniqueUsers.add(userId);
        if (status === "SUCCESS") stats.successfulLogins++;
        else stats.failedLogins++;
        stats.loginsPerDay[dateKey] = (stats.loginsPerDay[dateKey] || 0) + 1;
      }

      // Source 1: activity_logs (regular user logins + failed attempts)
      try {
        const snap = await db
          .collection("activity_logs")
          .where("actionType", "==", "LOGIN")
          .get();
        snap.forEach((doc) => {
          const d = doc.data();
          recordLogin(d.userId, parseTs(d.timestamp), d.status || "SUCCESS");
        });
      } catch (_) {}

      // Source 2: admin_sessions (admin logins — always SUCCESS, always present)
      try {
        const snap = await db.collection("admin_sessions").get();
        snap.forEach((doc) => {
          const d = doc.data();
          recordLogin(d.adminId, parseTs(d.createdAt), "SUCCESS");
        });
      } catch (_) {}

      // Source 3: user_sessions (app sessions — always SUCCESS)
      try {
        const snap = await db.collection("user_sessions").get();
        snap.forEach((doc) => {
          const d = doc.data();
          recordLogin(d.userId, parseTs(d.loginAt), "SUCCESS");
        });
      } catch (_) {}

      return {
        success: true,
        period,
        statistics: {
          totalLogins: stats.totalLogins,
          successfulLogins: stats.successfulLogins,
          failedLogins: stats.failedLogins,
          uniqueUsers: stats.uniqueUsers.size,
          loginsPerDay: stats.loginsPerDay,
          successRate:
            stats.totalLogins > 0
              ? Math.round((stats.successfulLogins / stats.totalLogins) * 100)
              : 0,
        },
      };
    } catch (error) {
      AdminLogger.logError({ errorType: "LOGIN_STATS_ERROR", message: error.message });
      throw error;
    }
  }

  /**
   * Get suspicious activities
   * No composite index needed — filtering and sorting done in memory.
   */
  static async getSuspiciousActivities(limit = 20) {
    try {
      // Fetch without compound where+orderBy to avoid composite index requirement
      const snapshot = await db
        .collection("suspicious_activities")
        .limit(limit * 3)
        .get();

      const activities = [];
      snapshot.forEach((doc) => {
        const data = doc.data();
        // Filter unresolved in memory
        if (data.isResolved !== true) {
          activities.push({ id: doc.id, ...data });
        }
      });

      // Sort by timestamp descending in memory
      activities.sort((a, b) => {
        const aS = a.timestamp?._seconds ?? a.timestamp?.seconds ?? 0;
        const bS = b.timestamp?._seconds ?? b.timestamp?.seconds ?? 0;
        return bS - aS;
      });

      const limited = activities.slice(0, limit);

      const bySeverity = { CRITICAL: 0, HIGH: 0, MEDIUM: 0, LOW: 0 };
      limited.forEach((a) => {
        if (bySeverity.hasOwnProperty(a.severity)) bySeverity[a.severity]++;
      });

      return {
        success: true,
        activities: limited,
        summary: { total: limited.length, bySeverity },
      };
    } catch (error) {
      // Return empty gracefully if collection doesn't exist yet
      AdminLogger.logError({
        errorType: "SUSPICIOUS_ACTIVITIES_ERROR",
        message: error.message,
      });
      return {
        success: true,
        activities: [],
        summary: { total: 0, bySeverity: { CRITICAL: 0, HIGH: 0, MEDIUM: 0, LOW: 0 } },
      };
    }
  }

  /**
   * Get active admin sessions with admin email info
   */
  static async getActiveSessions() {
    try {
      const snapshot = await db
        .collection("admin_sessions")
        .where("isActive", "==", true)
        .get();

      const sessions = [];
      const adminIdSet = new Set();

      snapshot.forEach((doc) => {
        const data = doc.data();
        adminIdSet.add(data.adminId);
        sessions.push({ sessionId: doc.id, ...data });
      });

      // Batch-fetch admin emails for all unique adminIds
      const adminEmails = {};
      for (const adminId of adminIdSet) {
        try {
          const adminDoc = await db.collection("admin_users").doc(adminId).get();
          if (adminDoc.exists) {
            adminEmails[adminId] = {
              email: adminDoc.data().email,
              adminLevel: adminDoc.data().adminLevel,
            };
          }
        } catch (_) {}
      }

      const enriched = sessions.map((s) => ({
        sessionId: s.sessionId,
        adminId: s.adminId,
        email: adminEmails[s.adminId]?.email || s.adminId,
        adminLevel: adminEmails[s.adminId]?.adminLevel || "ADMIN",
        ipAddress: s.ipAddress || "—",
        deviceInfo: s.deviceInfo || {},
        loginAt: s.createdAt,
        lastActivityAt: s.lastActivityAt,
        expiresAt: s.expiresAt,
      }));

      // Sort by most recently active first
      enriched.sort((a, b) => {
        const aT = a.lastActivityAt?._seconds ?? a.lastActivityAt?.seconds ?? 0;
        const bT = b.lastActivityAt?._seconds ?? b.lastActivityAt?.seconds ?? 0;
        return bT - aT;
      });

      return { success: true, sessions: enriched, total: enriched.length };
    } catch (error) {
      AdminLogger.logError({
        errorType: "GET_ACTIVE_SESSIONS_ERROR",
        message: error.message,
      });
      return { success: true, sessions: [], total: 0 };
    }
  }

  /**
   * Get feature usage by counting documents in each core feature collection.
   * This is more reliable than reading user_sessions.features (which is always empty)
   * and immediately reflects real app usage without any date-format dependency.
   */
  static async getFeatureUsage(period = "month") {
    try {
      const featureCollections = [
        { key: "Animals",            collection: "animals"     },
        { key: "Health Records",     collection: "health"      },
        { key: "Feed Management",    collection: "feed"        },
        { key: "Expenses",           collection: "expenses"    },
        { key: "Sales",              collection: "sales"       },
        { key: "Marketplace",        collection: "listings"    },
        { key: "Orders",             collection: "orders"      },
      ];

      const featureUsage = {};
      let totalRecords = 0;

      for (const { key, collection } of featureCollections) {
        try {
          const snap = await db.collection(collection).count().get();
          const count = snap.data().count;
          featureUsage[key] = count;
          totalRecords += count;
        } catch (_) {
          featureUsage[key] = 0;
        }
      }

      return {
        success: true,
        period,
        statistics: {
          totalSessions: totalRecords,
          featuresUsed: Object.values(featureUsage).filter((v) => v > 0).length,
          featureUsage,
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "FEATURE_USAGE_ERROR",
        message: error.message,
      });
      throw error;
    }
  }
}

module.exports = AnalyticsService;
