const { db } = require("../config/firebase");

/**
 * Get all animals — optionally filtered by userId for non-admin roles
 */
const getAllAnimals = async (userId, role) => {
  let query = db.collection("animals");

  // Farmers/Managers only see their own animals; Admin sees all
  if (role !== "Admin") {
    query = query.where("userId", "==", userId);
  }

  const snapshot = await query.get();
  const animals = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  // Sort in memory — avoids Firestore composite index requirement
  return animals.sort((a, b) => (b.createdAt || "").localeCompare(a.createdAt || ""));
};

/**
 * Get a single animal by ID
 */
const getAnimalById = async (animalId) => {
  const doc = await db.collection("animals").doc(animalId).get();
  if (!doc.exists) {
    const error = new Error("Animal not found");
    error.statusCode = 404;
    throw error;
  }
  return { id: doc.id, ...doc.data() };
};

/**
 * Create a new animal record
 */
const createAnimal = async (animalData, userId) => {
  const ref = db.collection("animals").doc();
  const animal = {
    ...animalData,
    userId,
    status: "active",
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  await ref.set(animal);
  return { id: ref.id, ...animal };
};

/**
 * Update an existing animal
 */
const updateAnimal = async (animalId, updates) => {
  const ref = db.collection("animals").doc(animalId);
  await ref.update({ ...updates, updatedAt: new Date().toISOString() });
  const updated = await ref.get();
  return { id: updated.id, ...updated.data() };
};

/**
 * Delete an animal record
 */
const deleteAnimal = async (animalId) => {
  await db.collection("animals").doc(animalId).delete();
};

module.exports = {
  getAllAnimals,
  getAnimalById,
  createAnimal,
  updateAnimal,
  deleteAnimal,
};
