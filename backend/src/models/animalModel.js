/**
 * Animal data structure for Firestore
 * This documents what fields each animal document has
 */
const AnimalModel = {
  userId: "", // Who owns this animal
  name: "", // Optional name/tag
  type: "", // e.g., Cow, Goat, Sheep
  breed: "", // e.g., Friesian, Boer
  age: 0, // Age in months
  gender: "", // Male or Female
  weight: 0, // Weight in kg
  purchaseCost: 0, // How much it cost to buy
  status: "active", // active | sold | deceased
  photoUrl: "", // Firebase Storage URL
  notes: "",
  createdAt: "",
  updatedAt: "",
};

module.exports = AnimalModel;
