/**
 * Unit Tests — Profit/Loss Calculator
 * Run with: npm test
 */

const { calculateAnimalProfit, calculateFarmSummary } = require("../../src/utils/calculator");

describe("calculateAnimalProfit", () => {
  test("calculates a profit correctly", () => {
    const result = calculateAnimalProfit(2000, 1000, 200, 50, 0);
    expect(result.profit).toBe(750);
    expect(result.totalCost).toBe(1250);
    expect(result.isProfit).toBe(true);
    expect(parseFloat(result.roi)).toBeCloseTo(60, 1);
  });

  test("calculates a loss correctly", () => {
    const result = calculateAnimalProfit(800, 1000, 200, 50, 0);
    expect(result.profit).toBe(-450);
    expect(result.isProfit).toBe(false);
  });

  test("handles zero costs gracefully", () => {
    const result = calculateAnimalProfit(500, 500, 0, 0, 0);
    expect(result.profit).toBe(0);
    expect(result.roi).toBe(0);
  });

  test("returns detailed breakdown", () => {
    const result = calculateAnimalProfit(2000, 1000, 200, 100, 50);
    expect(result.breakdown.purchaseCost).toBe(1000);
    expect(result.breakdown.feedCost).toBe(200);
    expect(result.breakdown.healthCost).toBe(100);
    expect(result.breakdown.otherCosts).toBe(50);
  });
});

describe("calculateFarmSummary", () => {
  const mockSales = [
    { sellingPrice: 2000, totalCost: 1500, profit: 500 },
    { sellingPrice: 1000, totalCost: 1200, profit: -200 },
    { sellingPrice: 3000, totalCost: 2000, profit: 1000 },
  ];

  const mockExpenses = [
    { amount: 100 },
    { amount: 200 },
  ];

  test("calculates total revenue correctly", () => {
    const result = calculateFarmSummary(mockSales, []);
    expect(result.totalRevenue).toBe(6000);
  });

  test("counts profitable and loss animals", () => {
    const result = calculateFarmSummary(mockSales, []);
    expect(result.profitableAnimals).toBe(2);
    expect(result.lossAnimals).toBe(1);
  });

  test("subtracts general expenses from total profit", () => {
    const result = calculateFarmSummary(mockSales, mockExpenses);
    // Profit from sales = 500 - 200 + 1000 = 1300, minus expenses 300 = 1000
    expect(result.totalProfit).toBe(1000);
  });
});
