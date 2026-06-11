/**
 * Admin Input Validator
 * Validates all admin inputs to prevent injection attacks and invalid data
 */

const { body, param, query, validationResult } = require("express-validator");

class AdminValidator {
  /**
   * Validate email format
   */
  static validateEmail() {
    return body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Invalid email format");
  }

  /**
   * Validate password strength
   * At least 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char
   */
  static validatePasswordStrength() {
    return body("password")
      .isLength({ min: 8 })
      .withMessage("Password must be at least 8 characters")
      .matches(
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
      )
      .withMessage(
        "Password must contain uppercase, lowercase, number and special character",
      );
  }

  /**
   * Validate user ID format
   */
  static validateUserId() {
    return param("id")
      .matches(/^[a-zA-Z0-9_-]+$/)
      .withMessage("Invalid user ID format");
  }

  /**
   * Validate admin level
   */
  static validateAdminLevel() {
    return body("adminLevel")
      .isIn(["SUPER_ADMIN", "ADMIN", "MODERATOR"])
      .withMessage("Invalid admin level");
  }

  /**
   * Validate action type for logs
   */
  static validateActionType() {
    return query("actionType")
      .optional()
      .isIn([
        "CREATE",
        "READ",
        "UPDATE",
        "DELETE",
        "LOGIN",
        "LOGOUT",
        "SUSPEND",
        "BAN",
      ])
      .withMessage("Invalid action type");
  }

  /**
   * Validate date range
   */
  static validateDateRange() {
    return [
      query("startDate")
        .optional()
        .isISO8601()
        .withMessage("Invalid start date format"),
      query("endDate")
        .optional()
        .isISO8601()
        .withMessage("Invalid end date format"),
    ];
  }

  /**
   * Validate pagination parameters
   */
  static validatePagination() {
    return [
      query("page")
        .optional()
        .isInt({ min: 1 })
        .withMessage("Page must be a positive integer"),
      query("limit")
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage("Limit must be between 1 and 100"),
    ];
  }

  /**
   * Validate search query
   */
  static validateSearchQuery() {
    return query("q")
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage("Search query must be 1-100 characters");
  }

  /**
   * Validate user data for creation/update
   */
  static validateUserData() {
    return [
      body("name")
        .trim()
        .isLength({ min: 2, max: 100 })
        .withMessage("Name must be 2-100 characters"),
      body("email")
        .isEmail()
        .normalizeEmail()
        .withMessage("Invalid email format"),
      body("phone")
        .optional()
        .isMobilePhone()
        .withMessage("Invalid phone number"),
      body("role")
        .isIn(["Farmer", "Manager", "Admin"])
        .withMessage("Invalid user role"),
    ];
  }

  /**
   * Validate admin login
   */
  static validateAdminLogin() {
    return [
      body("email")
        .isEmail()
        .normalizeEmail()
        .withMessage("Invalid email format"),
      body("password").isLength({ min: 1 }).withMessage("Password is required"),
    ];
  }

  /**
   * Handle validation errors
   */
  static handleValidationErrors(req, res, next) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: "Validation error",
        errors: errors.array().map((err) => ({
          field: err.param,
          message: err.msg,
        })),
      });
    }
    next();
  }

  /**
   * Sanitize and validate logs filter
   */
  static validateLogFilters() {
    return [
      query("userId").optional().trim(),
      query("actionType")
        .optional()
        .isIn([
          "CREATE",
          "READ",
          "UPDATE",
          "DELETE",
          "LOGIN",
          "LOGOUT",
          "SUSPEND",
          "BAN",
        ]),
      query("resourceType").optional().trim(),
      query("status").optional().isIn(["SUCCESS", "FAILED", "SUSPICIOUS"]),
      ...this.validateDateRange(),
      ...this.validatePagination(),
    ];
  }
}

module.exports = AdminValidator;
