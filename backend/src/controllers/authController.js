const { db } = require("../config/firebase");
const { generateToken } = require("../config/jwt");
const bcrypt = require("bcryptjs");

// ── Helpers (fire-and-forget: never block the main request) ──────────────────

function getClientIp(req) {
  return (
    (req.headers["x-forwarded-for"] || "").split(",")[0].trim() ||
    req.socket?.remoteAddress ||
    req.ip ||
    "—"
  );
}

function detectPlatform(ua = "") {
  if (ua.includes("Android")) return "Android";
  if (ua.includes("iPhone") || ua.includes("iPad")) return "iOS";
  if (ua.includes("Mozilla") || ua.includes("Chrome") || ua.includes("Safari"))
    return "Web";
  return "Unknown";
}

async function logLoginActivity({ userId, email, status, ipAddress, userAgent }) {
  try {
    await db.collection("activity_logs").add({
      userId: userId || email,
      actionType: "LOGIN",
      resourceType: "AUTH",
      status,
      ipAddress,
      userAgent,
      timestamp: new Date(),
      message:
        status === "SUCCESS"
          ? `User logged in: ${email}`
          : `Failed login attempt for: ${email}`,
    });
  } catch (_) {}
}

async function createUserSession({ userId, email, ipAddress, userAgent }) {
  try {
    await db.collection("user_sessions").add({
      userId,
      email,
      loginAt: new Date(),
      isActive: true,
      lastActivityAt: new Date(),
      ipAddress,
      deviceInfo: {
        platform: detectPlatform(userAgent),
        userAgent,
      },
      features: [],
      actionsCount: 0,
    });
  } catch (_) {}
}

async function checkBruteForce({ email, ipAddress }) {
  try {
    const fifteenMinsAgo = new Date(Date.now() - 15 * 60 * 1000);

    // Three equality filters — no composite index required in Firestore
    const failSnap = await db
      .collection("activity_logs")
      .where("userId", "==", email)
      .where("actionType", "==", "LOGIN")
      .where("status", "==", "FAILED")
      .get();

    // Filter by time in memory to avoid inequality compound index
    const recentFails = failSnap.docs.filter((doc) => {
      const ts = doc.data().timestamp;
      const d = ts?.toDate ? ts.toDate() : new Date(ts);
      return d >= fifteenMinsAgo;
    });

    const failCount = recentFails.length;

    // Flag after 2 stored failures (this call is the 3rd attempt)
    if (failCount >= 2) {
      const severity = failCount >= 4 ? "HIGH" : "MEDIUM";
      await db.collection("suspicious_activities").add({
        eventType: "MULTIPLE_FAILED_LOGINS",
        type: "BRUTE_FORCE",
        userId: email,
        ipAddress,
        severity,
        description: `${failCount + 1} failed login attempts in 15 minutes for: ${email}`,
        timestamp: new Date(),
        isResolved: false,
        occurrenceCount: failCount + 1,
        detectionMethod: "FAILED_LOGIN_COUNTER",
      });
    }
  } catch (_) {}
}

/**
 * @desc    Register a new user
 * @route   POST /api/v1/auth/register
 * @access  Public
 */
const register = async (req, res, next) => {
  try {
    const { name, email, password, phone = "" } = req.body;
    const role = "Farmer"; // All public registrations are Farmers; Admin accounts are created via the admin portal only

    // Check if email already exists
    const existing = await db
      .collection("users")
      .where("email", "==", email)
      .get();
    if (!existing.empty) {
      return res
        .status(400)
        .json({ success: false, message: "Email already registered" });
    }

    // Hash the password (never store plain text passwords!)
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user in Firestore
    const userRef = db.collection("users").doc(); // Auto-generate ID
    const newUser = {
      name,
      email,
      password: hashedPassword,
      role,
      phone,
      isActive: true,
      createdAt: new Date().toISOString(),
    };
    await userRef.set(newUser);

    // Generate JWT token
    const token = generateToken(userRef.id, role);

    // Log registration to activity_logs for "New Today" / "This Month" dashboard counters
    logLoginActivity({
      userId: userRef.id,
      email,
      status: "SUCCESS",
      ipAddress: getClientIp(req),
      userAgent: req.get("user-agent") || "—",
    });

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      token,
      user: { id: userRef.id, name, email, role },
    });
  } catch (error) {
    next(error); // Pass error to global error handler
  }
};

/**
 * @desc    Login user
 * @route   POST /api/v1/auth/login
 * @access  Public
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const ipAddress = getClientIp(req);
    const userAgent = req.get("user-agent") || "—";

    // Find user by email
    const snapshot = await db
      .collection("users")
      .where("email", "==", email)
      .get();
    if (snapshot.empty) {
      // Log failed attempt and check for brute force — fire-and-forget
      logLoginActivity({ email, status: "FAILED", ipAddress, userAgent });
      checkBruteForce({ email, ipAddress });
      return res
        .status(401)
        .json({ success: false, message: "Invalid credentials" });
    }

    const userDoc = snapshot.docs[0];
    const userData = userDoc.data();

    // Compare password with hashed version
    const isMatch = await bcrypt.compare(password, userData.password);
    if (!isMatch) {
      logLoginActivity({ email, status: "FAILED", ipAddress, userAgent });
      checkBruteForce({ email, ipAddress });
      return res
        .status(401)
        .json({ success: false, message: "Invalid credentials" });
    }

    // Generate token
    const token = generateToken(userDoc.id, userData.role);

    // Log success and create session — fire-and-forget, never delay the response
    logLoginActivity({ userId: userDoc.id, email, status: "SUCCESS", ipAddress, userAgent });
    createUserSession({ userId: userDoc.id, email, ipAddress, userAgent });

    res.json({
      success: true,
      token,
      user: {
        id: userDoc.id,
        name: userData.name,
        email: userData.email,
        role: userData.role,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get logged-in user profile
 * @route   GET /api/v1/auth/me
 * @access  Private (requires token)
 */
const getMe = async (req, res) => {
  res.json({ success: true, user: req.user });
};

module.exports = { register, login, getMe };
