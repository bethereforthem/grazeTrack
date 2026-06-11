/**
 * GrazeTrack Express Application Setup
 * This file configures middleware, routes, and error handling
 */

require("dotenv").config();
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
const path = require("path");

const errorHandler = require("./middleware/errorHandler");

// Import all route files
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const animalRoutes = require("./routes/animalRoutes");
const feedRoutes = require("./routes/feedRoutes");
const healthRoutes = require("./routes/healthRoutes");
const expenseRoutes = require("./routes/expenseRoutes");
const salesRoutes = require("./routes/salesRoutes");
const reportRoutes = require("./routes/reportRoutes");

// Public routes (no auth — for web browser access)
const publicRoutes = require("./routes/publicRoutes");

// Marketplace & ordering routes
const listingRoutes = require("./routes/listingRoutes");
const orderRoutes = require("./routes/orderRoutes");
const paymentRoutes = require("./routes/paymentRoutes");
const reviewRoutes = require("./routes/reviewRoutes");
const chatRoutes = require("./routes/chatRoutes");
const notificationRoutes = require("./routes/notificationRoutes");

// Admin routes (System Admin Module)
const adminAuthRoutes = require("./routes/adminAuthRoutes");
const adminUserRoutes = require("./routes/adminUserRoutes");
const adminLogsRoutes = require("./routes/adminLogsRoutes");
const adminAnalyticsRoutes = require("./routes/adminAnalyticsRoutes");
const { auditTrail } = require("./middleware/auditTrailMiddleware");

// Swagger API docs
const { swaggerUi, swaggerSpec } = require("./docs/swagger");

const app = express();

// ─── Security Middleware ────────────────────────────────────────────────────
app.use(helmet()); // Sets secure HTTP headers

app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "*", // Allow frontend origin
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);

// ─── Logging ────────────────────────────────────────────────────────────────
if (process.env.NODE_ENV !== "test") {
  app.use(morgan("dev")); // Log requests to console
}

// ─── Body Parsing ────────────────────────────────────────────────────────────
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ─── API Documentation ───────────────────────────────────────────────────────
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// ─── Serve static files from /public (marketplace HTML page, etc.) ──────────
app.use(express.static(path.join(__dirname, "..", "public")));

// ─── Health Check ────────────────────────────────────────────────────────────
app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "GrazeTrack API is running",
    version: "1.0.0",
    docs: "/api-docs",
    marketplace: "/marketplace",
  });
});

// ─── Public Web Marketplace ──────────────────────────────────────────────────
// Visiting http://your-server/marketplace in any browser shows the public
// livestock marketplace — no login required.
app.get("/marketplace", (req, res) => {
  res.sendFile(path.join(__dirname, "..", "public", "marketplace.html"));
});

// ─── Audit Trail Middleware (logs all API actions) ────────────────────────────
app.use("/api", auditTrail);

// ─── API Routes ──────────────────────────────────────────────────────────────
app.use("/api/v1/auth", authRoutes);
app.use("/api/v1/users", userRoutes);
app.use("/api/v1/animals", animalRoutes);
app.use("/api/v1/feed", feedRoutes);
app.use("/api/v1/health", healthRoutes);
app.use("/api/v1/expenses", expenseRoutes);
app.use("/api/v1/sales", salesRoutes);
app.use("/api/v1/reports", reportRoutes);

// ─── Public Routes (no login needed — for web marketplace) ───────────────────
app.use("/api/public", publicRoutes);

// ─── Marketplace & Ordering Routes ───────────────────────────────────────────
app.use("/api/v1/listings", listingRoutes);
app.use("/api/v1/orders", orderRoutes);
app.use("/api/v1/payments", paymentRoutes);
app.use("/api/v1/reviews", reviewRoutes);
app.use("/api/v1/chat", chatRoutes);
app.use("/api/v1/notifications", notificationRoutes);

// ─── Admin Routes (System Admin Module) ───────────────────────────────────────
app.use("/api/v1/admin/auth", adminAuthRoutes);
app.use("/api/v1/admin/users", adminUserRoutes);
app.use("/api/v1/admin/logs", adminLogsRoutes);
app.use("/api/v1/admin/analytics", adminAnalyticsRoutes);

// ─── 404 Handler ─────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ success: false, message: "Route not found" });
});

// ─── Global Error Handler (must be last) ─────────────────────────────────────
app.use(errorHandler);

module.exports = app;
