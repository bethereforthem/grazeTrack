const express = require("express");
const router = express.Router();
const {
  createOrder,
  getOrders,
  getAllOrdersAdmin,
  getOrder,
  updateOrderStatus,
} = require("../controllers/orderController");
const { protect } = require("../middleware/authMiddleware");
const { authorize } = require("../middleware/roleMiddleware");

router.use(protect);

router.route("/").get(getOrders).post(createOrder);
router.get("/admin", authorize("Admin", "Manager"), getAllOrdersAdmin);
router.get("/:id", getOrder);
router.put("/:id/status", updateOrderStatus);

module.exports = router;
