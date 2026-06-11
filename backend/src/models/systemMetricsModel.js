/**
 * System Metrics Model
 * Stores system-wide metrics and health information
 * Collection: system_metrics
 */

const SystemMetricsModel = {
  metricId: "", // Unique metric identifier
  timestamp: null, // ISO timestamp

  // User metrics
  userMetrics: {
    totalUsers: 0, // Total registered users
    activeUsers: 0, // Users who logged in today
    newRegistrationsToday: 0, // New users registered today
    newRegistrationsWeek: 0, // New users this week
    newRegistrationsMonth: 0, // New users this month

    // Account status
    suspendedUsers: 0, // Currently suspended accounts
    bannedUsers: 0, // Currently banned accounts
    activeSessionCount: 0, // Active user sessions
  },

  // System health
  systemHealth: {
    databaseStatus: "HEALTHY", // HEALTHY, WARNING, ERROR
    apiResponseTime: 0, // Average response time in ms
    errorRate: 0, // Percentage of failed requests
    uptime: 100, // System uptime percentage
    lastCheck: null, // Last health check timestamp
  },

  // Activity metrics
  activityMetrics: {
    loginCount: 0, // Total logins in period
    logoutCount: 0, // Total logouts in period
    apiCallsCount: 0, // Total API calls
    failedApiCalls: 0, // Failed API calls
    suspendCount: 0, // Users suspended in period
    banCount: 0, // Users banned in period
  },
};

module.exports = SystemMetricsModel;
