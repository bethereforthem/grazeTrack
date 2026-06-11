/**
 * Global error handler - catches all errors in the app
 * This runs when any controller calls next(error)
 */
const errorHandler = (err, req, res, next) => {
  console.error("Error:", err.message);

  // Default error
  let statusCode = err.statusCode || 500;
  let message = err.message || "Server Error";

  // Firebase not-found errors
  if (err.code === "not-found") {
    statusCode = 404;
    message = "Resource not found";
  }

  res.status(statusCode).json({
    success: false,
    message,
    // Only show stack trace in development
    stack: process.env.NODE_ENV === "development" ? err.stack : undefined,
  });
};

module.exports = errorHandler;
