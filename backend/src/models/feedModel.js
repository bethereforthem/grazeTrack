/**
 * Feed/Feeding record data structure for Firestore
 * Collection: feed/{feedId}
 */
const FeedModel = {
  animalCategory: "", // e.g., Cow, Goat, Sheep, Pig, Chicken
  userId: "",         // Who recorded this feeding
  type: "",        // e.g., Hay, Grain, Silage, Grass, Pellets
  quantity: 0,     // Amount in kg or liters
  unit: "kg",      // Unit of measurement: kg | liters | bales
  cost: 0,         // Cost of this feeding session
  notes: "",       // Optional notes
  date: "",        // ISO timestamp of when feeding occurred
  createdAt: "",   // Record creation time
};

module.exports = FeedModel;
