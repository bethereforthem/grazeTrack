/**
 * Sales Controller — handles animal sale requests and profit tracking
 */

const salesService = require("../services/salesService");
const { db } = require("../config/firebase");

// GET /api/v1/sales
const getAllSales = async (req, res, next) => {
  try {
    let query = db.collection("sales");
    if (req.user.role !== "Admin") {
      query = query.where("userId", "==", req.user.id);
    }
    const snapshot = await query.get();
    const sales = snapshot.docs
      .map((doc) => ({ id: doc.id, ...doc.data() }))
      .sort((a, b) => (b.date || "").localeCompare(a.date || ""));
    res.json({ success: true, count: sales.length, data: sales });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/sales/:id
const getSale = async (req, res, next) => {
  try {
    const doc = await db.collection("sales").doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ success: false, message: "Sale not found" });
    }
    res.json({ success: true, data: { id: doc.id, ...doc.data() } });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/sales  — records a sale and auto-calculates profit
const recordSale = async (req, res, next) => {
  try {
    const sale = await salesService.recordSale(req.body, req.user.id);
    res.status(201).json({ success: true, data: sale });
  } catch (error) {
    next(error);
  }
};

module.exports = { getAllSales, getSale, recordSale };
