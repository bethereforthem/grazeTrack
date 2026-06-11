const orderService = require("../services/orderService");

// POST /api/v1/orders
const createOrder = async (req, res, next) => {
  try {
    const order = await orderService.createOrder(
      req.body,
      req.user.id,
      req.user.name,
      req.user.phone
    );
    res.status(201).json({ success: true, data: order });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/orders  — buyer's orders by default
const getOrders = async (req, res, next) => {
  try {
    const perspective = req.query.perspective || "buyer"; // "buyer" | "seller"
    const orders = await orderService.getOrders(
      req.user.id,
      req.user.role,
      perspective
    );
    res.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/orders/admin  — Admin sees all orders
const getAllOrdersAdmin = async (req, res, next) => {
  try {
    const orders = await orderService.getAllOrdersAdmin();
    res.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/orders/:id
const getOrder = async (req, res, next) => {
  try {
    const order = await orderService.getOrderById(
      req.params.id,
      req.user.id,
      req.user.role
    );
    res.json({ success: true, data: order });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/orders/:id/status
const updateOrderStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    if (!status) {
      return res.status(400).json({ success: false, message: "status is required" });
    }
    const order = await orderService.updateOrderStatus(
      req.params.id,
      status,
      req.user.id,
      req.user.role
    );
    res.json({ success: true, data: order });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createOrder,
  getOrders,
  getAllOrdersAdmin,
  getOrder,
  updateOrderStatus,
};
