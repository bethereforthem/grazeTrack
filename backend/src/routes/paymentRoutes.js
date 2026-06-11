const express = require("express");
const router = express.Router();
const {
  initiatePayment,
  confirmPayment,
  getPaymentByOrder,
} = require("../controllers/paymentController");
const { protect } = require("../middleware/authMiddleware");

router.use(protect);

router.post("/initiate", initiatePayment);
router.post("/:id/confirm", confirmPayment);
router.get("/order/:orderId", getPaymentByOrder);

module.exports = router;
