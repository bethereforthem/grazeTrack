/**
 * Admin Session Model
 * Stores admin user sessions with security tracking
 * Collection: admin_sessions
 */

const AdminSessionModel = {
  sessionId: "", // Unique session identifier
  adminId: "", // Reference to admin user
  tokenHash: "", // Hashed JWT token
  ipAddress: "", // Client IP address
  userAgent: "", // Device/browser information
  isActive: true, // Session status

  // Timestamps
  createdAt: null, // Session creation time
  lastActivityAt: null, // Last action timestamp
  expiresAt: null, // Token expiration time

  // Session metadata
  loginMethod: "PASSWORD", // PASSWORD, SSO, MFA
  deviceInfo: {
    platform: "", // Windows, Mac, Linux, etc.
    browser: "", // Chrome, Firefox, Safari, etc.
    deviceId: "", // Unique device identifier
  },

  // Security
  mfaVerified: false, // Two-factor authentication status
  riskLevel: "LOW", // LOW, MEDIUM, HIGH, CRITICAL
};

module.exports = AdminSessionModel;
