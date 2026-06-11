/**
 * Auth Service — business logic for user authentication
 * Used by authController.js
 */

const { db } = require("../config/firebase");
const { generateToken } = require("../config/jwt");
const bcrypt = require("bcryptjs");

/**
 * Register a new user
 */
const registerUser = async ({ name, email, password, role = "Farmer" }) => {
  // Validate role
  const allowedRoles = ["Admin", "Farmer", "Manager"];
  if (!allowedRoles.includes(role)) {
    const err = new Error("Invalid role. Allowed: Admin, Farmer, Manager");
    err.statusCode = 400;
    throw err;
  }

  // Check for existing email
  const existing = await db.collection("users").where("email", "==", email).get();
  if (!existing.empty) {
    const err = new Error("Email already registered");
    err.statusCode = 400;
    throw err;
  }

  // Hash password
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(password, salt);

  // Create user in Firestore
  const userRef = db.collection("users").doc();
  const now = new Date().toISOString();
  const newUser = {
    name,
    email,
    password: hashedPassword,
    role,
    phone: "",
    profilePhotoUrl: "",
    isActive: true,
    createdAt: now,
    updatedAt: now,
  };
  await userRef.set(newUser);

  const token = generateToken(userRef.id, role);
  return {
    token,
    user: { id: userRef.id, name, email, role },
  };
};

/**
 * Login a user with email + password
 */
const loginUser = async ({ email, password }) => {
  const snapshot = await db.collection("users").where("email", "==", email).get();
  if (snapshot.empty) {
    const err = new Error("Invalid credentials");
    err.statusCode = 401;
    throw err;
  }

  const userDoc = snapshot.docs[0];
  const userData = userDoc.data();

  if (!userData.isActive) {
    const err = new Error("Account is deactivated. Contact admin.");
    err.statusCode = 403;
    throw err;
  }

  const isMatch = await bcrypt.compare(password, userData.password);
  if (!isMatch) {
    const err = new Error("Invalid credentials");
    err.statusCode = 401;
    throw err;
  }

  const token = generateToken(userDoc.id, userData.role);
  return {
    token,
    user: {
      id: userDoc.id,
      name: userData.name,
      email: userData.email,
      role: userData.role,
    },
  };
};

module.exports = { registerUser, loginUser };
