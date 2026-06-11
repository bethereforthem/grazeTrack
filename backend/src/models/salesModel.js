/**
 * Sale record data structure for Firestore
 * Collection: sales/{saleId}
 */
const SalesModel = {
  animalId: "",      // Reference to animals/{animalId}
  userId: "",        // Who recorded the sale
  animalType: "",    // Cached for reporting (e.g., Cow, Goat)
  animalBreed: "",   // Cached for reporting
  sellingPrice: 0,   // How much the animal was sold for
  totalCost: 0,      // Purchase + feed + health costs combined
  profit: 0,         // sellingPrice - totalCost (negative = loss)
  roi: 0,            // Return on investment as percentage
  isProfit: true,    // Quick boolean flag
  breakdown: {       // Cost breakdown for transparency
    purchaseCost: 0,
    feedCost: 0,
    healthCost: 0,
    otherCosts: 0,
  },
  buyerName: "",     // Optional buyer name
  notes: "",         // Optional notes
  date: "",          // ISO timestamp of sale
  createdAt: "",
};

module.exports = SalesModel;
