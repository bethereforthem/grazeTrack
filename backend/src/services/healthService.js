/**
 * Health Service — business logic for animal health records
 * Item 10: When a health record has cost > 0, an expense is automatically
 * created in the expenses collection so it flows into financial reports.
 */

const { db } = require("../config/firebase");

/**
 * Get all health records (role-filtered)
 */
const getAllHealth = async (userId, role) => {
  let query = db.collection("health");
  if (role !== "Admin") {
    query = query.where("userId", "==", userId);
  }
  const snapshot = await query.get();
  const records = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return records.sort((a, b) => (b.date || "").localeCompare(a.date || ""));
};

/**
 * Get health records for a specific animal
 */
const getHealthByAnimal = async (animalId) => {
  const snapshot = await db
    .collection("health")
    .where("animalId", "==", animalId)
    .get();
  const records = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return records.sort((a, b) => (b.date || "").localeCompare(a.date || ""));
};

/**
 * Get a single health record by ID
 */
const getHealthById = async (healthId) => {
  const doc = await db.collection("health").doc(healthId).get();
  if (!doc.exists) {
    const err = new Error("Health record not found");
    err.statusCode = 404;
    throw err;
  }
  return { id: doc.id, ...doc.data() };
};

/**
 * Create a new health record.
 * Item 10: If cost > 0, automatically creates a matching expense record
 * so health spending is reflected in financial reports.
 */
const createHealth = async (healthData, userId) => {
  const ref = db.collection("health").doc();
  const record = {
    ...healthData,
    userId,
    createdAt: new Date().toISOString(),
  };
  await ref.set(record);

  // Auto-create expense for health cost
  if ((healthData.cost || 0) > 0) {
    const expRef = db.collection("expenses").doc();
    await expRef.set({
      userId,
      type: "Medicine",
      amount: healthData.cost,
      description: `Health: ${healthData.type || "Treatment"} — ${healthData.animalId || ""}`,
      date: healthData.date || new Date().toISOString(),
      linkedHealthId: ref.id, // track the source
      createdAt: new Date().toISOString(),
    });
  }

  return { id: ref.id, ...record };
};

/**
 * Update a health record.
 * Item 10: If cost changed, updates the linked expense record if one exists.
 */
const updateHealth = async (healthId, updates) => {
  const ref = db.collection("health").doc(healthId);
  await ref.update(updates);
  const updated = await ref.get();

  // Update linked expense if cost changed
  if (updates.cost !== undefined) {
    const expSnap = await db
      .collection("expenses")
      .where("linkedHealthId", "==", healthId)
      .get();
    if (!expSnap.empty) {
      await expSnap.docs[0].ref.update({
        amount: updates.cost,
        updatedAt: new Date().toISOString(),
      });
    }
  }

  return { id: updated.id, ...updated.data() };
};

/**
 * Delete a health record.
 * Also removes the linked expense if one exists.
 */
const deleteHealth = async (healthId) => {
  // Remove linked expense first
  const expSnap = await db
    .collection("expenses")
    .where("linkedHealthId", "==", healthId)
    .get();
  const batch = db.batch();
  expSnap.docs.forEach((d) => batch.delete(d.ref));
  batch.delete(db.collection("health").doc(healthId));
  await batch.commit();
};

/**
 * Get total health/medicine cost for an animal (used in profit calculation)
 */
const getTotalHealthCostForAnimal = async (animalId) => {
  const snapshot = await db
    .collection("health")
    .where("animalId", "==", animalId)
    .get();
  return snapshot.docs.reduce((sum, doc) => sum + (doc.data().cost || 0), 0);
};

/**
 * Get upcoming vaccinations (nextCheckupDate within next 7 days)
 */
const getUpcomingVaccinations = async (userId, role) => {
  const now = new Date().toISOString();
  const sevenDaysLater = new Date(
    Date.now() + 7 * 24 * 60 * 60 * 1000,
  ).toISOString();

  let query = db.collection("health");
  if (role !== "Admin") {
    query = query.where("userId", "==", userId);
  }
  const snapshot = await query.get();
  return snapshot.docs
    .map((doc) => ({ id: doc.id, ...doc.data() }))
    .filter(
      (r) =>
        r.nextCheckupDate &&
        r.nextCheckupDate >= now &&
        r.nextCheckupDate <= sevenDaysLater,
    );
};

module.exports = {
  getAllHealth,
  getHealthByAnimal,
  getHealthById,
  createHealth,
  updateHealth,
  deleteHealth,
  getTotalHealthCostForAnimal,
  getUpcomingVaccinations,
};
