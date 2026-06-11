const jwt = require("jsonwebtoken");

/**
 * Generate a JWT token
 * @param {string} userId - Firebase user ID
 * @param {string} role - User role or admin level
 * @param {string} [secret] - Optional secret override (falls back to JWT_SECRET)
 * @param {string} [expiry] - Optional expiry override (falls back to JWT_EXPIRE)
 * @param {Object} [extraClaims] - Extra payload fields (e.g. { sessionId })
 */
const generateToken = (userId, role, secret, expiry, extraClaims = {}) => {
  return jwt.sign(
    { userId, role, ...extraClaims },
    secret || process.env.JWT_SECRET,
    { expiresIn: expiry || process.env.JWT_EXPIRE || "7d" },
  );
};

/**
 * Verify a JWT token
 * @param {string} token - The token from the request header
 * @param {string} [secret] - Optional secret override (falls back to JWT_SECRET)
 */
const verifyToken = (token, secret) => {
  return jwt.verify(token, secret || process.env.JWT_SECRET);
};

module.exports = { generateToken, verifyToken };
