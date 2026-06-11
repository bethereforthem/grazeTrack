/**
 * Audit Trail Middleware
 * Automatically logs all admin actions for complete audit trail
 * Add this middleware to all admin routes for automatic logging
 */

const { db } = require("../config/firebase");
const AdminLogger = require("../utils/adminLogger");

/**
 * Audit Trail Middleware
 * Captures request details and logs after response
 * Usage: router.use('/admin', auditTrail) - applies to all routes under /admin
 */
const auditTrail = (req, res, next) => {
  // Capture request details
  const requestDetails = {
    method: req.method,
    endpoint: req.originalUrl,
    ipAddress: req.ip,
    userAgent: req.get("user-agent"),
    timestamp: new Date().toISOString(),
    adminId: req.admin?.id,
  };

  // Capture original response methods
  const originalSend = res.send;
  const originalJson = res.json;

  // Track response details
  let responseBody = null;
  let statusCode = null;

  // Override send method
  res.send = function (data) {
    responseBody = data;
    return originalSend.call(this, data);
  };

  // Override json method
  res.json = function (data) {
    responseBody = data;
    return originalJson.call(this, data);
  };

  // Hook into response finish event
  res.on("finish", async () => {
    try {
      statusCode = res.statusCode;

      // Only log if admin is involved
      if (req.admin && (req.method !== "GET" || req.path.includes("/admin"))) {
        const actionType = mapHttpMethodToActionType(req.method);
        const resourceType = extractResourceType(req.originalUrl);
        const resourceId = extractResourceId(req.originalUrl);

        // Create audit log entry
        const logEntry = {
          logId: generateLogId(),
          userId: req.admin.id,
          actionType: actionType,
          resourceType: resourceType,
          resourceId: resourceId,
          changes: {
            before: null, // Would need to capture before making changes
            after: req.body || null,
          },
          ipAddress: requestDetails.ipAddress,
          userAgent: requestDetails.userAgent,
          status: statusCode < 400 ? "SUCCESS" : "FAILED",
          errorMessage:
            statusCode >= 400 ? extractErrorMessage(responseBody) : null,
          timestamp: new Date(),
          sessionId: req.admin.sessionId,
          metadata: {
            severity: calculateSeverity(actionType, statusCode),
            responseTime: res.get("X-Response-Time") || "N/A",
          },
        };

        // Save to Firestore
        await db.collection("activity_logs").add(logEntry);

        // Log to admin logger
        AdminLogger.logActivity({
          type: "AUDIT_TRAIL",
          userId: req.admin.id,
          action: actionType,
          resourceType: resourceType,
          resourceId: resourceId,
          status: logEntry.status,
          message: `${req.method} ${req.originalUrl} - Status: ${statusCode}`,
        });
      }
    } catch (error) {
      AdminLogger.logError({
        errorType: "AUDIT_TRAIL_ERROR",
        message: `Failed to log audit trail: ${error.message}`,
        userId: req.admin?.id,
      });
    }
  });

  next();
};

/**
 * Map HTTP methods to action types
 */
function mapHttpMethodToActionType(method) {
  const methodMap = {
    GET: "READ",
    POST: "CREATE",
    PUT: "UPDATE",
    PATCH: "UPDATE",
    DELETE: "DELETE",
  };
  return methodMap[method] || "READ";
}

/**
 * Extract resource type from URL
 * e.g., /api/v1/admin/users -> USER
 */
function extractResourceType(url) {
  const parts = url.split("/");
  const resourcePart = parts[parts.length - 1] || parts[parts.length - 2];

  const typeMap = {
    users: "USER",
    logs: "LOG",
    sessions: "SESSION",
    monitoring: "MONITORING",
    analytics: "ANALYTICS",
    dashboard: "DASHBOARD",
  };

  return typeMap[resourcePart] || "ADMIN";
}

/**
 * Extract resource ID from URL
 * e.g., /api/v1/admin/users/user123 -> user123
 */
function extractResourceId(url) {
  const parts = url.split("/");
  // Get second to last part if it looks like an ID
  const possibleId = parts[parts.length - 1];
  return possibleId && !possibleId.includes("?") ? possibleId : null;
}

/**
 * Extract error message from response
 */
function extractErrorMessage(body) {
  if (typeof body === "string") {
    return body;
  }
  if (body && body.message) {
    return body.message;
  }
  return "Unknown error";
}

/**
 * Calculate severity level based on action and status
 */
function calculateSeverity(actionType, statusCode) {
  // Delete operations are always high severity
  if (actionType === "DELETE") {
    return statusCode >= 400 ? "CRITICAL" : "HIGH";
  }

  // Failed operations are medium
  if (statusCode >= 400) {
    return "MEDIUM";
  }

  // Create/update operations are low severity
  if (actionType === "CREATE" || actionType === "UPDATE") {
    return "LOW";
  }

  return "LOW";
}

/**
 * Generate unique log ID
 */
function generateLogId() {
  return `log_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

module.exports = { auditTrail };
