const { verifyToken } = require("../config/jwt");
const { db } = require("../config/firebase");

/**
 * Protect middleware - checks if user is logged in
 * Add this to any route that requires authentication
 * Usage: router.get('/route', protect, controller)
 */
const protect = async (req, res, next) => {
  try {
    // Check if Authorization header exists
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Not authorized. No token provided.",
      });
    }

    // Extract token from "Bearer <token>"
    const token = authHeader.split(" ")[1];

    // Verify the token
    const decoded = verifyToken(token);

    // Get user from Firebase
    const userDoc = await db.collection("users").doc(decoded.userId).get();
    if (!userDoc.exists) {
      return res
        .status(401)
        .json({ success: false, message: "User not found" });
    }

    // Attach user to request object
    req.user = { id: decoded.userId, role: decoded.role, ...userDoc.data() };
    next(); // Continue to the actual route handler
  } catch (error) {
    res
      .status(401)
      .json({ success: false, message: "Token invalid or expired" });
  }
};

module.exports = { protect };
