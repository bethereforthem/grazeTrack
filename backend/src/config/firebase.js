// Firebase Admin SDK initialization
// This connects your Node.js server to Firebase

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin (only once)
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: `${serviceAccount.project_id}.appspot.com`,
  });
}

// Export Firestore database and Storage
const db = admin.firestore();
const storage = admin.storage();
const messaging = admin.messaging();

module.exports = { admin, db, storage, messaging };
