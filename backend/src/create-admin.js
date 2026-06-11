/**
 * GrazeTrack - Create Super Admin CLI Script
 *
 * Usage: node src/create-admin.js
 *
 * This script bootstraps the first SUPER_ADMIN account in the system.
 * Run this once during initial deployment. Subsequent admins can be
 * created through the admin dashboard (SUPER_ADMIN only).
 *
 * Required environment variables (set in .env):
 *   FIREBASE_PROJECT_ID, GOOGLE_APPLICATION_CREDENTIALS or serviceAccountKey.json
 *   ADMIN_EMAIL, ADMIN_PASSWORD  (or enter interactively)
 */

require("dotenv").config();
const readline = require("readline");
const bcrypt = require("bcryptjs");

// ─── Prompt helper ────────────────────────────────────────────────────────────
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function prompt(question) {
  return new Promise((resolve) => rl.question(question, resolve));
}

function promptSecret(question) {
  return new Promise((resolve) => {
    process.stdout.write(question);
    // Hide input characters
    const stdin = process.openStdin();
    process.stdin.setRawMode(true);
    process.stdin.resume();
    process.stdin.setEncoding("utf8");
    let password = "";
    process.stdin.on("data", function (char) {
      char = char + "";
      switch (char) {
        case "\n":
        case "\r":
        case "":
          process.stdin.setRawMode(false);
          process.stdout.write("\n");
          resolve(password);
          break;
        case "":
          process.exit();
          break;
        case "": // backspace
          if (password.length > 0) {
            password = password.slice(0, -1);
            process.stdout.clearLine(0);
            process.stdout.cursorTo(0);
            process.stdout.write(question + "*".repeat(password.length));
          }
          break;
        default:
          password += char;
          process.stdout.write("*");
          break;
      }
    });
  });
}

// ─── Main ─────────────────────────────────────────────────────────────────────
async function main() {
  console.log("\n╔══════════════════════════════════════════════╗");
  console.log("║     GrazeTrack - Create Super Admin          ║");
  console.log("╚══════════════════════════════════════════════╝\n");

  // Initialize Firebase Admin SDK
  let db;
  try {
    const { db: firestore } = require("./config/firebase");
    db = firestore;
    console.log("✓ Firebase connected\n");
  } catch (err) {
    console.error("✗ Firebase initialization failed:", err.message);
    console.error(
      "  Make sure serviceAccountKey.json exists and FIREBASE_PROJECT_ID is set in .env",
    );
    process.exit(1);
  }

  // Collect admin details
  const email =
    process.env.ADMIN_EMAIL || (await prompt("Admin email address: "));

  if (!email || !email.includes("@")) {
    console.error("✗ Invalid email address");
    process.exit(1);
  }

  // Check if admin already exists
  const existing = await db
    .collection("admin_users")
    .where("email", "==", email.toLowerCase().trim())
    .get();

  if (!existing.empty) {
    console.log(`\n⚠  Admin with email "${email}" already exists.`);
    const existing_data = existing.docs[0].data();
    console.log(`   Level: ${existing_data.adminLevel}`);
    console.log(`   Status: ${existing_data.status}`);
    rl.close();
    process.exit(0);
  }

  let password = process.env.ADMIN_PASSWORD;
  if (!password) {
    try {
      password = await promptSecret("Admin password (min 8 chars): ");
    } catch {
      // Fallback for environments that don't support raw mode
      password = await prompt("Admin password (min 8 chars): ");
    }
  }

  if (!password || password.length < 8) {
    console.error("\n✗ Password must be at least 8 characters");
    process.exit(1);
  }

  const adminLevelInput = await prompt(
    "Admin level [SUPER_ADMIN/ADMIN] (default: SUPER_ADMIN): ",
  );
  const adminLevel =
    adminLevelInput.trim().toUpperCase() === "ADMIN" ? "ADMIN" : "SUPER_ADMIN";

  const department = await prompt("Department (optional, press Enter to skip): ");

  console.log("\n─── Creating admin account ───────────────────────");
  console.log(`  Email:  ${email.trim().toLowerCase()}`);
  console.log(`  Level:  ${adminLevel}`);
  if (department.trim()) console.log(`  Dept:   ${department.trim()}`);

  const confirm = await prompt("\nConfirm? [y/N]: ");
  if (confirm.trim().toLowerCase() !== "y") {
    console.log("Cancelled.");
    rl.close();
    process.exit(0);
  }

  // Hash password
  const hashedPassword = await bcrypt.hash(password, 12);

  const adminData = {
    email: email.trim().toLowerCase(),
    password: hashedPassword,
    adminLevel: adminLevel,
    permissionSet: getAllPermissions(adminLevel),
    status: "ACTIVE",
    createdAt: new Date(),
    createdBy: "CLI_BOOTSTRAP",
    updatedAt: new Date(),
    lastLoginAt: null,
    isPasswordChanged: false,
    twoFactorEnabled: false,
    metadata: {
      department: department.trim() || "",
      notes: "Created via CLI bootstrap script",
      createdFrom: "create-admin.js",
    },
  };

  const docRef = await db.collection("admin_users").add(adminData);

  console.log("\n✓ Admin account created successfully!");
  console.log(`  Admin ID: ${docRef.id}`);
  console.log(`  Email:    ${adminData.email}`);
  console.log(`  Level:    ${adminData.adminLevel}`);
  console.log(
    "\n  You can now log in at the admin dashboard with these credentials.\n",
  );

  rl.close();
  process.exit(0);
}

/**
 * Return full permission set for the given admin level
 */
function getAllPermissions(level) {
  const superAdminPermissions = [
    "MANAGE_USERS",
    "VIEW_USERS",
    "SUSPEND_USERS",
    "DELETE_USERS",
    "RESET_PASSWORDS",
    "VIEW_LOGS",
    "EXPORT_LOGS",
    "VIEW_ANALYTICS",
    "MANAGE_ADMINS",
    "VIEW_SECURITY",
    "SYSTEM_SETTINGS",
  ];

  const adminPermissions = [
    "MANAGE_USERS",
    "VIEW_USERS",
    "SUSPEND_USERS",
    "RESET_PASSWORDS",
    "VIEW_LOGS",
    "VIEW_ANALYTICS",
    "VIEW_SECURITY",
  ];

  return level === "SUPER_ADMIN" ? superAdminPermissions : adminPermissions;
}

main().catch((err) => {
  console.error("\n✗ Unexpected error:", err.message);
  process.exit(1);
});
