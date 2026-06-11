/**
 * Request Validation Middleware
 * Uses express-validator to validate incoming request data
 * Usage: add to route with body() validators, then call validateRequest
 */

const { validationResult } = require("express-validator");

/**
 * Checks if a request has validation errors
 * Add this after your validation rules in any route
 */
const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: "Validation failed",
      errors: errors.array().map((e) => ({ field: e.path, message: e.msg })),
    });
  }
  next();
};

module.exports = { validateRequest };
