#!/usr/bin/env node

/**
 * Create a SUPER_ADMIN User Script
 * Usage: node create-admin.js
 */

const bcrypt = require("bcryptjs");
const admin = require("firebase-admin");
const readline = require("readline");
const path = require("path");

// Initialize Firebase
const serviceAccount = require("./src/config/serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      process.env.FIREBASE_DATABASE_URL ||
      "https://your-project.firebaseio.com",
  });
}

const db = admin.firestore();

// Create readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

// Helper function to prompt user
function prompt(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer.trim());
    });
  });
}

// Main function
async function createSuperAdmin() {
  try {
    console.log(
      "\n╔════════════════════════════════════════════════════════════════╗",
    );
    console.log(
      "║         GrazeTrack SUPER_ADMIN Account Creation Wizard          ║",
    );
    console.log(
      "╚════════════════════════════════════════════════════════════════╝\n",
    );

    // Get user input
    const email = await prompt("📧 Enter admin email: ");
    if (!email || !email.includes("@")) {
      throw new Error("Invalid email format");
    }

    const password = await prompt(
      "🔐 Enter password (min 8 chars, uppercase, lowercase, digit, special): ",
    );
    if (password.length < 8) {
      throw new Error("Password must be at least 8 characters");
    }

    // Validate password strength
    if (!/[A-Z]/.test(password)) {
      throw new Error("Password must contain uppercase letter");
    }
    if (!/[a-z]/.test(password)) {
      throw new Error("Password must contain lowercase letter");
    }
    if (!/[0-9]/.test(password)) {
      throw new Error("Password must contain digit");
    }
    if (!/[!@#$%^&*]/.test(password)) {
      throw new Error("Password must contain special character (!@#$%^&*)");
    }

    const department =
      (await prompt("🏢 Enter department (optional, press Enter to skip): ")) ||
      "System";
    const notes =
      (await prompt("📝 Enter notes (optional, press Enter to skip): ")) ||
      "Initial super admin user";

    // Hash password
    console.log("\n🔄 Hashing password...");
    const hashedPassword = await bcrypt.hash(password, 12);

    // Check if user already exists
    const existingUser = await db
      .collection("admin_users")
      .where("email", "==", email)
      .get();

    if (!existingUser.empty) {
      throw new Error(`Admin user with email ${email} already exists`);
    }

    // Create admin document
    const adminData = {
      email: email.toLowerCase(),
      password: hashedPassword,
      adminLevel: "SUPER_ADMIN",
      permissionSet: [],
      status: "ACTIVE",
      createdAt: new Date(),
      createdBy: "system-script",
      updatedAt: new Date(),
      lastLoginAt: null,
      metadata: {
        department: department,
        notes: notes,
      },
    };

    console.log("✏️  Creating admin document...");
    const docRef = await db.collection("admin_users").add(adminData);

    console.log(
      "\n╔════════════════════════════════════════════════════════════════╗",
    );
    console.log(
      "║                   ✅ SUPER_ADMIN CREATED                        ║",
    );
    console.log(
      "╚════════════════════════════════════════════════════════════════╝\n",
    );

    console.log("📋 Account Details:");
    console.log(`   Email: ${email}`);
    console.log(`   Level: SUPER_ADMIN`);
    console.log(`   Status: ACTIVE`);
    console.log(`   Document ID: ${docRef.id}`);
    console.log(`   Department: ${department}`);
    console.log(`   Created: ${new Date().toLocaleString()}`);

    console.log("\n🚀 Next Steps:");
    console.log("   1. Start your backend server: npm start");
    console.log("   2. Navigate to admin dashboard: http://localhost:3001");
    console.log("   3. Login with your email and password");
    console.log("   4. Create additional admin accounts as needed\n");

    rl.close();
    process.exit(0);
  } catch (error) {
    console.error("\n❌ Error:", error.message);
    rl.close();
    process.exit(1);
  }
}

// Run script
createSuperAdmin();
