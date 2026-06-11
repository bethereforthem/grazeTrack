/**
 * Report data structure for Firestore
 * Collection: reports/{reportId}
 */
const ReportModel = {
  userId: "",             // Who generated this report
  period: "",             // e.g., "2024-01", "2024-Q1", "2024"
  totalRevenue: 0,        // Total money received from sales
  totalCosts: 0,          // Total costs (feed + health + expenses)
  totalProfit: 0,         // Revenue minus costs
  totalAnimals: 0,        // Total animals in the period
  animalsSold: 0,         // Number of animals sold
  profitableAnimals: 0,   // Animals sold at a profit
  lossAnimals: 0,         // Animals sold at a loss
  overallROI: 0,          // Overall return on investment %
  topExpenseType: "",     // Which category costs most (feed/medicine/labor)
  generatedAt: "",        // ISO timestamp when report was generated
};

module.exports = ReportModel;
