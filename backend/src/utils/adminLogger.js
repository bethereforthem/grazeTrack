/**
 * Admin Logger Utility
 * Centralized logging for admin activities with structured logging
 */

const fs = require("fs");
const path = require("path");

/**
 * Create logs directory if it doesn't exist
 */
const logsDir = path.join(__dirname, "../../logs");
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

class AdminLogger {
  /**
   * Log activity to console and file
   * @param {Object} logData - Log data object
   */
  static logActivity(logData) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level: logData.level || "INFO",
      type: logData.type,
      userId: logData.userId,
      action: logData.action,
      resourceType: logData.resourceType,
      resourceId: logData.resourceId,
      status: logData.status,
      message: logData.message,
      metadata: logData.metadata || {},
    };

    // Console logging
    console.log(
      `[${logEntry.timestamp}] [${logEntry.level}] ${logEntry.type}: ${logEntry.message}`,
    );

    // File logging
    this._writeToFile("admin-activity.log", logEntry);
  }

  /**
   * Log security events
   * @param {Object} securityData - Security event data
   */
  static logSecurityEvent(securityData) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level: securityData.severity || "WARNING",
      eventType: securityData.eventType,
      userId: securityData.userId,
      ipAddress: securityData.ipAddress,
      description: securityData.description,
      action: securityData.action,
      metadata: securityData.metadata || {},
    };

    // Console warning for security events
    console.warn(
      `[${logEntry.timestamp}] [SECURITY] ${logEntry.eventType}: ${logEntry.description}`,
    );

    // File logging
    this._writeToFile("security-events.log", logEntry);
  }

  /**
   * Log authentication attempts
   * @param {Object} authData - Authentication data
   */
  static logAuthAttempt(authData) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level: authData.success ? "INFO" : "WARNING",
      eventType: "AUTH_ATTEMPT",
      userId: authData.userId || authData.email,
      ipAddress: authData.ipAddress,
      success: authData.success,
      method: authData.method,
      reason: authData.reason,
      metadata: authData.metadata || {},
    };

    console.log(
      `[${logEntry.timestamp}] [AUTH] ${authData.success ? "SUCCESS" : "FAILED"}: ${authData.userId || authData.email}`,
    );
    this._writeToFile("auth-attempts.log", logEntry);
  }

  /**
   * Log database operations
   * @param {Object} dbData - Database operation data
   */
  static logDatabaseOperation(dbData) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level: "DEBUG",
      eventType: "DB_OPERATION",
      operation: dbData.operation,
      collection: dbData.collection,
      documentId: dbData.documentId,
      status: dbData.status,
      executionTime: dbData.executionTime,
      metadata: dbData.metadata || {},
    };

    this._writeToFile("database-operations.log", logEntry);
  }

  /**
   * Log API calls
   * @param {Object} apiData - API call data
   */
  static logAPICall(apiData) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level: apiData.statusCode >= 400 ? "WARNING" : "INFO",
      eventType: "API_CALL",
      method: apiData.method,
      endpoint: apiData.endpoint,
      statusCode: apiData.statusCode,
      responseTime: apiData.responseTime,
      userId: apiData.userId,
      ipAddress: apiData.ipAddress,
      metadata: apiData.metadata || {},
    };

    this._writeToFile("api-calls.log", logEntry);
  }

  /**
   * Log errors
   * @param {Object} errorData - Error data
   */
  static logError(errorData) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level: "ERROR",
      eventType: "APPLICATION_ERROR",
      errorType: errorData.errorType,
      message: errorData.message,
      stack: errorData.stack,
      context: errorData.context || {},
      userId: errorData.userId,
    };

    console.error(`[${logEntry.timestamp}] [ERROR] ${errorData.message}`);
    this._writeToFile("errors.log", logEntry);
  }

  /**
   * Write log entry to file
   * @private
   */
  static _writeToFile(filename, logEntry) {
    try {
      const logPath = path.join(logsDir, filename);
      const logLine = JSON.stringify(logEntry) + "\n";
      fs.appendFileSync(logPath, logLine);
    } catch (error) {
      console.error("Failed to write to log file:", error.message);
    }
  }

  /**
   * Get log file contents (for admin export)
   * @param {String} filename - Log filename
   * @param {Number} lines - Number of recent lines to fetch
   */
  static getLogFile(filename, lines = 100) {
    try {
      const logPath = path.join(logsDir, filename);
      if (!fs.existsSync(logPath)) {
        return [];
      }

      const content = fs.readFileSync(logPath, "utf-8");
      const logLines = content
        .trim()
        .split("\n")
        .filter((line) => line);
      return logLines.slice(-lines).map((line) => {
        try {
          return JSON.parse(line);
        } catch {
          return { raw: line };
        }
      });
    } catch (error) {
      console.error("Failed to read log file:", error.message);
      return [];
    }
  }

  /**
   * Export logs for admin download
   * @param {String} startDate - Start date (ISO format)
   * @param {String} endDate - End date (ISO format)
   */
  static exportLogs(startDate, endDate) {
    try {
      const files = fs.readdirSync(logsDir);
      const logs = [];

      files.forEach((file) => {
        const filePath = path.join(logsDir, file);
        const content = fs.readFileSync(filePath, "utf-8");
        const lines = content
          .trim()
          .split("\n")
          .filter((line) => line);

        lines.forEach((line) => {
          try {
            const entry = JSON.parse(line);
            if (entry.timestamp >= startDate && entry.timestamp <= endDate) {
              logs.push(entry);
            }
          } catch {
            // Skip invalid JSON lines
          }
        });
      });

      return logs.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
    } catch (error) {
      console.error("Failed to export logs:", error.message);
      return [];
    }
  }
}

module.exports = AdminLogger;
