const paymentService = require("../services/paymentService");

// POST /api/v1/payments/initiate
const initiatePayment = async (req, res, next) => {
  try {
    const { orderId, phoneNumber } = req.body;
    if (!orderId || !phoneNumber) {
      return res.status(400).json({
        success: false,
        message: "orderId and phoneNumber are required",
      });
    }
    const payment = await paymentService.initiatePayment(
      orderId,
      phoneNumber,
      req.user.id
    );
    res.status(201).json({ success: true, data: payment });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/payments/:id/confirm
const confirmPayment = async (req, res, next) => {
  try {
    const payment = await paymentService.confirmPayment(
      req.params.id,
      req.user.id,
      req.user.role
    );
    res.json({ success: true, data: payment });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/payments/order/:orderId
const getPaymentByOrder = async (req, res, next) => {
  try {
    const payment = await paymentService.getPaymentByOrder(
      req.params.orderId,
      req.user.id,
      req.user.role
    );
    res.json({ success: true, data: payment });
  } catch (error) {
    next(error);
  }
};

module.exports = { initiatePayment, confirmPayment, getPaymentByOrder };
