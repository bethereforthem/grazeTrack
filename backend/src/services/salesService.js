const { db } = require("../config/firebase");
const { calculateAnimalProfit } = require("../utils/calculator");

/**
 * Record a sale — automatically calculates profit/loss
 */
const recordSale = async (saleData, userId) => {
  const { animalId, sellingPrice, notes } = saleData;

  // 1. Get the animal's purchase cost
  const animalDoc = await db.collection("animals").doc(animalId).get();
  if (!animalDoc.exists) throw new Error("Animal not found");
  const animal = animalDoc.data();

  // 2. Sum all feed costs for this animal
  const feedSnapshot = await db
    .collection("feed")
    .where("animalId", "==", animalId)
    .get();
  const feedCost = feedSnapshot.docs.reduce(
    (sum, doc) => sum + (doc.data().cost || 0),
    0,
  );

  // 3. Sum all health/medicine costs for this animal
  const healthSnapshot = await db
    .collection("health")
    .where("animalId", "==", animalId)
    .get();
  const healthCost = healthSnapshot.docs.reduce(
    (sum, doc) => sum + (doc.data().cost || 0),
    0,
  );

  // 4. Calculate profit automatically
  const calculation = calculateAnimalProfit(
    sellingPrice,
    animal.purchaseCost,
    feedCost,
    healthCost,
  );

  // 5. Save sale record to Firestore
  const saleRef = db.collection("sales").doc();
  const saleRecord = {
    animalId,
    userId,
    animalType: animal.type,
    animalBreed: animal.breed,
    sellingPrice,
    ...calculation,
    notes,
    date: new Date().toISOString(),
  };
  await saleRef.set(saleRecord);

  // 6. Mark animal as sold
  await db.collection("animals").doc(animalId).update({
    status: "sold",
    soldAt: new Date().toISOString(),
    soldPrice: sellingPrice,
  });

  return { id: saleRef.id, ...saleRecord };
};

module.exports = { recordSale };
