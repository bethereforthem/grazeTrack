/**
 * Suspicious Activity Model
 * Tracks potentially malicious or unusual activities
 * Collection: suspicious_activities
 */

const SuspiciousActivityModel = {
  activityId: "", // Unique identifier
  userId: "", // Affected user
  activityType: "", // Type of suspicious activity
  // MULTIPLE_FAILED_LOGINS
  // UNUSUAL_ACCESS_PATTERN
  // RAPID_API_CALLS
  // UNAUTHORIZED_ACCESS_ATTEMPT
  // DATA_EXFILTRATION_ATTEMPT

  // Severity and description
  severity: "LOW", // LOW, MEDIUM, HIGH, CRITICAL
  description: "", // Detailed description

  // Detection details
  detectionMethod: "", // How this was detected
  detectionScore: 0, // Risk score (0-100)

  // Timing
  timestamp: null, // When detected
  firstOccurrence: null, // First time this occurred
  occurrenceCount: 0, // How many times in period

  // Context
  ipAddress: "", // IP associated with activity
  deviceInfo: {}, // Device information

  // Resolution
  isResolved: false, // Has this been resolved?
  resolutionNotes: "", // Admin notes on resolution
  adminId: "", // Admin who resolved it
  resolvedAt: null, // Resolution timestamp
  resolutionAction: "", // Action taken (block, ban, etc.)
};

module.exports = SuspiciousActivityModel;
