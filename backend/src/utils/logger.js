/**
 * Simple Logger Utility for GrazeTrack
 * Formats log messages with timestamp and level
 */

const logger = {
  /**
   * Log general information
   * @param {string} message
   */
  info: (message) => {
    console.log(`[${new Date().toISOString()}] [INFO]  ${message}`);
  },

  /**
   * Log error messages
   * @param {string} message
   */
  error: (message) => {
    console.error(`[${new Date().toISOString()}] [ERROR] ${message}`);
  },

  /**
   * Log warning messages
   * @param {string} message
   */
  warn: (message) => {
    console.warn(`[${new Date().toISOString()}] [WARN]  ${message}`);
  },

  /**
   * Log debug messages (only in development)
   * @param {string} message
   */
  debug: (message) => {
    if (process.env.NODE_ENV === "development") {
      console.log(`[${new Date().toISOString()}] [DEBUG] ${message}`);
    }
  },
};

module.exports = logger;
