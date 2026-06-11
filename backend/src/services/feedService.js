/**
 * Feed Service — business logic for feeding records
 */

const { db } = require("../config/firebase");

/**
 * Get all feed records for the current user (or all if Admin)
 */
const getAllFeed = async (userId, role) => {
  let query = db.collection("feed");
  if (role !== "Admin") {
    query = query.where("userId", "==", userId);
  }
  const snapshot = await query.get();
  const records = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return records.sort((a, b) => (b.date || "").localeCompare(a.date || ""));
};

/**
 * Get all feed records for a specific animal
 */
const getFeedByAnimal = async (animalId) => {
  const snapshot = await db
    .collection("feed")
    .where("animalId", "==", animalId)
    .get();
  const records = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return records.sort((a, b) => (b.date || "").localeCompare(a.date || ""));
};

/**
 * Get a single feed record by ID
 */
const getFeedById = async (feedId) => {
  const doc = await db.collection("feed").doc(feedId).get();
  if (!doc.exists) {
    const err = new Error("Feed record not found");
    err.statusCode = 404;
    throw err;
  }
  return { id: doc.id, ...doc.data() };
};

/**
 * Create a new feed record
 */
const createFeed = async (feedData, userId) => {
  const ref = db.collection("feed").doc();
  const record = {
    ...feedData,
    userId,
    createdAt: new Date().toISOString(),
  };
  await ref.set(record);
  return { id: ref.id, ...record };
};

/**
 * Update a feed record
 */
const updateFeed = async (feedId, updates) => {
  const ref = db.collection("feed").doc(feedId);
  await ref.update(updates);
  const updated = await ref.get();
  return { id: updated.id, ...updated.data() };
};

/**
 * Delete a feed record
 */
const deleteFeed = async (feedId) => {
  await db.collection("feed").doc(feedId).delete();
};

/**
 * Get total feed cost for a specific animal (used in profit calculation)
 */
const getTotalFeedCostForAnimal = async (animalId) => {
  const snapshot = await db.collection("feed").where("animalId", "==", animalId).get();
  return snapshot.docs.reduce((sum, doc) => sum + (doc.data().cost || 0), 0);
};

module.exports = {
  getAllFeed,
  getFeedByAnimal,
  getFeedById,
  createFeed,
  updateFeed,
  deleteFeed,
  getTotalFeedCostForAnimal,
};
