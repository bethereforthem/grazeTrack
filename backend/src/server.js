/**
 * GrazeTrack Server Entry Point
 * Run this file to start the API server: node src/server.js
 */

require("dotenv").config();
const app = require("./app");
const logger = require("./utils/logger");

const PORT = process.env.PORT || 5000;
const NODE_ENV = process.env.NODE_ENV || "development";

// Start the server
const server = app.listen(PORT, "0.0.0.0", () => {
  logger.info(`====================================`);
  logger.info(` GrazeTrack API Server Started`);
  logger.info(` Mode   : ${NODE_ENV}`);
  logger.info(` Port   : ${PORT}`);
  logger.info(` Docs   : http://localhost:${PORT}/api-docs`);
  logger.info(`====================================`);
});

// Handle unhandled promise rejections (e.g., DB connection failures)
process.on("unhandledRejection", (err) => {
  logger.error(`Unhandled Promise Rejection: ${err.message}`);
  // Close server gracefully before exiting
  server.close(() => {
    process.exit(1);
  });
});

// Handle uncaught exceptions
process.on("uncaughtException", (err) => {
  logger.error(`Uncaught Exception: ${err.message}`);
  process.exit(1);
});

module.exports = server;
