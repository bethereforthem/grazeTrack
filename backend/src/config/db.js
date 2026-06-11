/**
 * Database configuration wrapper
 * Re-exports the Firestore database instance from Firebase config
 * This abstraction allows swapping databases in the future if needed
 */

const { db } = require("./firebase");

module.exports = { db };
