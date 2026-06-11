/**
 * Report Service — generates analytics and summary reports
 */

const { db } = require("../config/firebase");
const { calculateFarmSummary } = require("../utils/calculator");

/**
 * Generate a full farm summary report for a user
 * Supports optional date range filtering via startDate / endDate (ISO strings)
 */
const generateFarmReport = async (userId, role, startDate, endDate) => {
  // Base queries filtered by user
  let salesQuery = db.collection("sales");
  if (role !== "Admin") salesQuery = salesQuery.where("userId", "==", userId);
  const salesSnap = await salesQuery.get();
  let sales = salesSnap.docs.map((doc) => {
    const data = doc.data();
    return {
      id: doc.id,
      ...data,
      profit: data.profit || 0,
      sellingPrice: data.sellingPrice || 0,
      totalCost: data.totalCost || 0,
      date: data.date || "",
    };
  });

  let expQuery = db.collection("expenses");
  if (role !== "Admin") expQuery = expQuery.where("userId", "==", userId);
  const expSnap = await expQuery.get();
  let expenses = expSnap.docs.map((doc) => {
    const data = doc.data();
    return {
      id: doc.id,
      ...data,
      amount: data.amount || 0,
      date: data.date || "",
    };
  });

  // Date range filtering (in memory to avoid composite indexes)
  if (startDate) {
    const startDateStr = startDate.split("T")[0]; // Normalize to YYYY-MM-DD
    sales = sales.filter((s) => {
      const sDate = (s.date || "").split("T")[0];
      return sDate >= startDateStr;
    });
    expenses = expenses.filter((e) => {
      const eDate = (e.date || "").split("T")[0];
      return eDate >= startDateStr;
    });
  }
  if (endDate) {
    const endDateStr = endDate.split("T")[0]; // Normalize to YYYY-MM-DD
    sales = sales.filter((s) => {
      const sDate = (s.date || "").split("T")[0];
      return sDate <= endDateStr;
    });
    expenses = expenses.filter((e) => {
      const eDate = (e.date || "").split("T")[0];
      return eDate <= endDateStr;
    });
  }

  // Animal counts
  let animalQuery = db.collection("animals");
  if (role !== "Admin") animalQuery = animalQuery.where("userId", "==", userId);
  const animalSnap = await animalQuery.get();
  const totalAnimals = animalSnap.size;

  // Summary calculations
  const summary = calculateFarmSummary(sales, expenses);

  // Expense breakdown by type
  const expenseByType = {};
  expenses.forEach(({ type, amount }) => {
    expenseByType[type] = (expenseByType[type] || 0) + (amount || 0);
  });

  // Monthly trend (last 6 months)
  const monthlyTrend = buildMonthlyTrend(sales, expenses);

  // Item 5: Loss sales with full detail — where profit is negative
  const lossSales = sales
    .filter((s) => (s.profit || 0) < 0)
    .map((s) => ({
      id: s.id,
      animalType: s.animalType || "Unknown",
      animalBreed: s.animalBreed || "Unknown",
      sellingPrice: s.sellingPrice || 0,
      totalCost: s.totalCost || 0,
      profit: s.profit || 0,
      date: s.date || "",
      notes: s.notes || "",
      breakdown: s.breakdown || {
        purchaseCost: 0,
        feedCost: 0,
        healthCost: 0,
        otherCosts: 0,
      },
    }))
    .sort((a, b) => a.profit - b.profit); // worst losses first

  return {
    ...summary,
    totalAnimals,
    animalsSold: sales.length,
    expenseByType,
    monthlyTrend,
    recentSales: sales.slice(0, 5),
    lossSalesDetails: lossSales, // Item 5: full loss detail
  };
};

/**
 * Build monthly profit/expense data for the last 6 months
 */
const buildMonthlyTrend = (sales, expenses) => {
  const months = [];
  for (let i = 5; i >= 0; i--) {
    const d = new Date();
    d.setMonth(d.getMonth() - i);
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
    months.push({ month: key, revenue: 0, expenses: 0, profit: 0 });
  }

  sales.forEach((s) => {
    const dateStr = s.date ? String(s.date) : "";
    const key = dateStr.substring(0, 7);
    const entry = months.find((m) => m.month === key);
    if (entry) {
      entry.revenue += s.sellingPrice || 0;
      entry.profit += s.profit || 0;
    }
  });

  expenses.forEach((e) => {
    const dateStr = e.date ? String(e.date) : "";
    const key = dateStr.substring(0, 7);
    const entry = months.find((m) => m.month === key);
    if (entry) {
      entry.expenses += e.amount || 0;
    }
  });

  return months;
};

/**
 * Get comprehensive dashboard stats for all filter categories (Item 7)
 */
const getDashboardStats = async (userId, role) => {
  // ── Animals ──────────────────────────────────────────────────────
  let animalQuery = db.collection("animals");
  if (role !== "Admin") animalQuery = animalQuery.where("userId", "==", userId);
  const animalSnap = await animalQuery.get();
  const allAnimals = animalSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

  const activeAnimals = allAnimals.filter((a) => a.status === "active");
  const soldAnimals = allAnimals.filter((a) => a.status === "sold");
  const deceasedAnimals = allAnimals.filter((a) => a.status === "deceased");

  // Count animals by type
  const animalsByType = {};
  activeAnimals.forEach((a) => {
    animalsByType[a.type] = (animalsByType[a.type] || 0) + 1;
  });

  // ── Expenses ──────────────────────────────────────────────────────
  const now = new Date();
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
  // Extract just the date part for comparison (YYYY-MM-DD)
  const monthStartStr = monthStart.toISOString().split("T")[0];

  let expQuery = db.collection("expenses");
  if (role !== "Admin") expQuery = expQuery.where("userId", "==", userId);
  const expSnap = await expQuery.get();
  const allExpenses = expSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

  const monthlyExpenses = allExpenses
    .filter((e) => {
      const expDate = (e.date || "").split("T")[0]; // Extract date part only
      return expDate >= monthStartStr;
    })
    .reduce((sum, e) => sum + (e.amount || 0), 0);
  const allTimeExpenses = allExpenses.reduce(
    (sum, e) => sum + (e.amount || 0),
    0,
  );

  const expensesByCategory = {};
  allExpenses.forEach(({ type, amount }) => {
    expensesByCategory[type] = (expensesByCategory[type] || 0) + (amount || 0);
  });

  // ── Sales ─────────────────────────────────────────────────────────
  let salesQuery = db.collection("sales");
  if (role !== "Admin") salesQuery = salesQuery.where("userId", "==", userId);
  const salesSnap = await salesQuery.get();
  const allSales = salesSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

  // Ensure profit field exists (default to 0 if missing)
  const salesWithProfit = allSales.map((s) => ({
    ...s,
    profit: s.profit || 0,
    sellingPrice: s.sellingPrice || 0,
    totalCost: s.totalCost || 0,
  }));

  const totalRevenue = salesWithProfit.reduce(
    (sum, s) => sum + s.sellingPrice,
    0,
  );
  const totalProfit =
    salesWithProfit.reduce((sum, s) => sum + s.profit, 0) - allTimeExpenses;
  const profitableSales = salesWithProfit.filter((s) => s.profit > 0).length;
  const lossSalesCount = salesWithProfit.filter((s) => s.profit <= 0).length;
  const totalROI =
    salesWithProfit.length > 0
      ? (
          ((totalRevenue -
            salesWithProfit.reduce((sum, s) => sum + s.totalCost, 0)) /
            Math.max(
              salesWithProfit.reduce((sum, s) => sum + s.totalCost, 0),
              1,
            )) *
          100
        ).toFixed(1)
      : "0.0";

  // ── Feed ─────────────────────────────────────────────────────────
  let feedQuery = db.collection("feed");
  if (role !== "Admin") feedQuery = feedQuery.where("userId", "==", userId);
  const feedSnap = await feedQuery.get();
  const allFeed = feedSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

  const totalFeedCost = allFeed.reduce((sum, f) => sum + (f.cost || 0), 0);
  const monthlyFeedCost = allFeed
    .filter((f) => {
      const feedDate = (f.date || "").split("T")[0]; // Extract date part only
      return feedDate >= monthStartStr;
    })
    .reduce((sum, f) => sum + (f.cost || 0), 0);

  // ── Health ────────────────────────────────────────────────────────
  let healthQuery = db.collection("health");
  if (role !== "Admin") healthQuery = healthQuery.where("userId", "==", userId);
  const healthSnap = await healthQuery.get();
  const allHealth = healthSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

  const totalHealthCost = allHealth.reduce((sum, h) => sum + (h.cost || 0), 0);
  const sevenDaysLater = new Date(
    Date.now() + 7 * 24 * 60 * 60 * 1000,
  ).toISOString();
  const nowStr = now.toISOString();
  const upcomingVaccinations = allHealth.filter((h) => {
    const checkupDate = (h.nextCheckupDate || "").split("T")[0];
    const nowDate = nowStr.split("T")[0];
    const sevenDaysStr = sevenDaysLater.split("T")[0];
    return (
      h.nextCheckupDate && checkupDate >= nowDate && checkupDate <= sevenDaysStr
    );
  }).length;

  return {
    // Summary (main dashboard)
    totalActiveAnimals: activeAnimals.length,
    monthlyExpenses,
    totalProfit,
    totalRevenue,
    totalSales: allSales.length,

    // Animals category
    totalAnimals: allAnimals.length,
    soldAnimalsCount: soldAnimals.length,
    deceasedAnimalsCount: deceasedAnimals.length,
    animalsByType,

    // Expenses category
    allTimeExpenses,
    expensesByCategory,
    expenseRecordsCount: allExpenses.length,

    // Sales category
    profitableSales,
    lossSalesCount,
    totalROI,

    // Feed category
    totalFeedCost,
    monthlyFeedCost,
    feedRecordsCount: allFeed.length,

    // Health category
    totalHealthCost,
    upcomingVaccinations,
    healthRecordsCount: allHealth.length,
  };
};

module.exports = { generateFarmReport, getDashboardStats };
