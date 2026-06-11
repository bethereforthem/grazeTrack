const { db } = require("../config/firebase");
const notificationService = require("./notificationService");

/**
 * Place a new order (buyer action)
 */
const createOrder = async (data, buyerId, buyerName, buyerPhone) => {
  // Fetch the listing
  const listingRef = db.collection("listings").doc(data.listingId);
  const listingDoc = await listingRef.get();
  if (!listingDoc.exists) {
    const error = new Error("Listing not found");
    error.statusCode = 404;
    throw error;
  }
  const listing = listingDoc.data();
  if (listing.status !== "available") {
    const error = new Error("This animal is no longer available");
    error.statusCode = 400;
    throw error;
  }
  if (listing.sellerId === buyerId) {
    const error = new Error("You cannot order your own listing");
    error.statusCode = 400;
    throw error;
  }

  const ref = db.collection("orders").doc();
  const order = {
    listingId: data.listingId,
    buyerId,
    buyerName,
    buyerPhone: buyerPhone || data.buyerPhone || "",
    buyerAddress: data.buyerAddress || "",
    sellerId: listing.sellerId,
    sellerName: listing.sellerName,
    animalType: listing.animalType,
    breed: listing.breed,
    quantity: data.quantity || 1,
    totalAmount: listing.price * (data.quantity || 1),
    pricePerUnit: listing.price,
    notes: data.notes || "",
    status: "Pending",         // Pending → Approved → Completed | Rejected
    paymentStatus: "Unpaid",   // Unpaid | Paid
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  await ref.set(order);

  // Notify seller
  await notificationService.notifyUser(listing.sellerId, {
    title: "New Order Received",
    body: `${buyerName} placed an order for your ${listing.animalType} listing.`,
    data: { type: "new_order", orderId: ref.id },
  });

  return { id: ref.id, ...order };
};

/**
 * Get all orders — Admin sees all; buyer sees their orders; seller sees orders on their listings
 */
const getOrders = async (userId, role, perspective = "buyer") => {
  let snapshot;
  if (role === "Admin") {
    snapshot = await db.collection("orders").get();
  } else if (perspective === "seller") {
    snapshot = await db
      .collection("orders")
      .where("sellerId", "==", userId)
      .get();
  } else {
    snapshot = await db
      .collection("orders")
      .where("buyerId", "==", userId)
      .get();
  }
  const orders = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return orders.sort((a, b) =>
    (b.createdAt || "").localeCompare(a.createdAt || "")
  );
};

/**
 * Get single order
 */
const getOrderById = async (orderId, userId, role) => {
  const doc = await db.collection("orders").doc(orderId).get();
  if (!doc.exists) {
    const error = new Error("Order not found");
    error.statusCode = 404;
    throw error;
  }
  const order = { id: doc.id, ...doc.data() };
  if (
    role !== "Admin" &&
    order.buyerId !== userId &&
    order.sellerId !== userId
  ) {
    const error = new Error("Not authorized to view this order");
    error.statusCode = 403;
    throw error;
  }
  return order;
};

/**
 * Update order status (Admin/Seller action)
 * Allowed transitions: Pending → Approved, Pending → Rejected, Approved → Completed
 */
const updateOrderStatus = async (orderId, newStatus, userId, role) => {
  const ref = db.collection("orders").doc(orderId);
  const doc = await ref.get();
  if (!doc.exists) {
    const error = new Error("Order not found");
    error.statusCode = 404;
    throw error;
  }
  const order = doc.data();

  // Only Admin or seller can update status
  if (role !== "Admin" && order.sellerId !== userId) {
    const error = new Error("Not authorized to update this order");
    error.statusCode = 403;
    throw error;
  }

  const validTransitions = {
    Pending: ["Approved", "Rejected"],
    Approved: ["Completed"],
    Rejected: [],
    Completed: [],
  };

  if (!validTransitions[order.status]?.includes(newStatus)) {
    const error = new Error(
      `Cannot transition from ${order.status} to ${newStatus}`
    );
    error.statusCode = 400;
    throw error;
  }

  // If completing, payment must be Paid
  if (newStatus === "Completed" && order.paymentStatus !== "Paid") {
    const error = new Error("Order cannot be completed before payment");
    error.statusCode = 400;
    throw error;
  }

  await ref.update({ status: newStatus, updatedAt: new Date().toISOString() });

  // If Approved → mark listing as temporarily reserved
  // Notify buyer
  const messages = {
    Approved: { title: "Order Approved!", body: "Your order has been approved. Please proceed with payment." },
    Rejected: { title: "Order Rejected", body: "Unfortunately your order has been rejected by the seller." },
    Completed: { title: "Order Completed!", body: "Your order is now complete. Enjoy your purchase!" },
  };
  const msg = messages[newStatus];
  if (msg) {
    await notificationService.notifyUser(order.buyerId, {
      ...msg,
      data: { type: "order_status", orderId, status: newStatus },
    });
  }

  // If completed, mark listing as sold
  if (newStatus === "Completed") {
    await db.collection("listings").doc(order.listingId).update({
      status: "sold",
      updatedAt: new Date().toISOString(),
    });
  }

  const updated = await ref.get();
  return { id: updated.id, ...updated.data() };
};

/**
 * Get all orders for admin dashboard
 */
const getAllOrdersAdmin = async () => {
  const snapshot = await db.collection("orders").get();
  const orders = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return orders.sort((a, b) =>
    (b.createdAt || "").localeCompare(a.createdAt || "")
  );
};

module.exports = {
  createOrder,
  getOrders,
  getOrderById,
  updateOrderStatus,
  getAllOrdersAdmin,
};
