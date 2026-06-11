/**
 * Profit/Loss Calculator for GrazeTrack
 *
 * Formula:
 *   Total Cost = purchase cost + all feed costs + all health/medicine costs + other expenses
 *   Profit     = selling price - total cost
 *   ROI        = (profit / total cost) × 100
 */

/**
 * Calculate profit or loss for a single animal sale
 * @param {number} sellingPrice - How much the animal was sold for
 * @param {number} purchaseCost - How much the animal cost to buy
 * @param {number} feedCost - Total feed costs for this animal
 * @param {number} healthCost - Total medicine/vet costs
 * @param {number} otherCosts - Any other costs
 */
const calculateAnimalProfit = (
  sellingPrice,
  purchaseCost,
  feedCost = 0,
  healthCost = 0,
  otherCosts = 0,
) => {
  const totalCost = purchaseCost + feedCost + healthCost + otherCosts;
  const profit = sellingPrice - totalCost;
  const roi = totalCost > 0 ? ((profit / totalCost) * 100).toFixed(2) : 0;
  const isProfit = profit >= 0;

  return {
    sellingPrice,
    totalCost,
    profit,
    roi: parseFloat(roi),
    isProfit,
    breakdown: { purchaseCost, feedCost, healthCost, otherCosts },
  };
};

/**
 * Calculate total farm profitability summary
 * @param {Array} sales - Array of sale records with profit values
 * @param {Array} expenses - Array of general expense records
 */
const calculateFarmSummary = (sales, expenses) => {
  const totalRevenue = sales.reduce((sum, s) => sum + (s.sellingPrice || 0), 0);
  const totalSaleCosts = sales.reduce((sum, s) => sum + (s.totalCost || 0), 0);
  const totalGeneralExpenses = expenses.reduce(
    (sum, e) => sum + (e.amount || 0),
    0,
  );
  const totalProfit =
    sales.reduce((sum, s) => sum + (s.profit || 0), 0) - totalGeneralExpenses;
  const profitableAnimals = sales.filter((s) => s.profit > 0).length;
  const lossAnimals = sales.filter((s) => s.profit <= 0).length;

  return {
    totalRevenue,
    totalCosts: totalSaleCosts + totalGeneralExpenses,
    totalProfit,
    profitableAnimals,
    lossAnimals,
    overallROI:
      totalSaleCosts > 0
        ? (((totalRevenue - totalSaleCosts) / totalSaleCosts) * 100).toFixed(2)
        : 0,
  };
};

module.exports = { calculateAnimalProfit, calculateFarmSummary };
