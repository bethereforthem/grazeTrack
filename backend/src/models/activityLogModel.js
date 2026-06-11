/**
 * Activity Log Model
 * Stores complete audit trail of all admin actions and user activities
 * Collection: activity_logs
 */

const ActivityLogModel = {
  logId: "", // Unique identifier
  userId: "", // User who performed the action
  actionType: "", // CREATE, READ, UPDATE, DELETE, LOGIN, LOGOUT, SUSPEND, BAN
  resourceType: "", // USER, ANIMAL, ORDER, PAYMENT, etc.
  resourceId: "", // ID of the resource affected

  // Changes tracking
  changes: {
    before: {}, // Previous values
    after: {}, // New values
  },

  // Request information
  ipAddress: "", // Client IP address
  userAgent: "", // Browser/device info

  // Status and metadata
  status: "SUCCESS", // SUCCESS, FAILED, SUSPICIOUS
  errorMessage: "", // Error details if failed
  timestamp: null, // ISO timestamp
  sessionId: "", // Admin session ID

  // Additional context
  metadata: {
    severity: "LOW", // LOW, MEDIUM, HIGH, CRITICAL
    location: "", // Geo location if available
    notes: "", // Additional notes
  },
};

module.exports = ActivityLogModel;
