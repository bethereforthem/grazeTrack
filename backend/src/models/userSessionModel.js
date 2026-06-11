/**
 * User Session Model
 * Tracks user app sessions (separate from admin sessions)
 * Collection: user_sessions
 */

const UserSessionModel = {
  sessionId: "", // Unique session identifier
  userId: "", // Reference to user
  loginAt: null, // Login timestamp
  logoutAt: null, // Logout timestamp (optional)
  ipAddress: "", // Client IP address

  // Device information
  deviceInfo: {
    platform: "", // iOS, Android, Web
    appVersion: "", // App version number
    deviceId: "", // Unique device identifier
    osVersion: "", // OS version
    deviceModel: "", // Device model/name
  },

  // Session status
  isActive: true, // Is session still active
  lastActivityAt: null, // Last activity timestamp
  sessionDuration: 0, // Session duration in seconds (if ended)

  // Session metadata
  features: [], // Features used in session
  actionsCount: 0, // Number of actions taken
  dataUsed: 0, // Data transferred in KB
};

module.exports = UserSessionModel;
