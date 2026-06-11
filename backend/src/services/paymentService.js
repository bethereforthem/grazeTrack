const { db } = require("../config/firebase");
const notificationService = require("./notificationService");

/**
 * Initiate a MoMo payment for an order.
 * In production, replace the simulation block with actual MoMo API calls.
 */
const initiatePayment = async (orderId, phoneNumber, userId) => {
  // Validate order
  const orderRef = db.collection("orders").doc(orderId);
  const orderDoc = await orderRef.get();
  if (!orderDoc.exists) {
    const error = new Error("Order not found");
    error.statusCode = 404;
    throw error;
  }
  const order = orderDoc.data();

  if (order.buyerId !== userId) {
    const error = new Error("Not authorized to pay for this order");
    error.statusCode = 403;
    throw error;
  }
  if (order.status !== "Approved") {
    const error = new Error("Order must be approved before payment");
    error.statusCode = 400;
    throw error;
  }
  if (order.paymentStatus === "Paid") {
    const error = new Error("Order is already paid");
    error.statusCode = 400;
    throw error;
  }

  // Generate a payment reference
  const reference = `GT-${Date.now()}-${Math.floor(Math.random() * 10000)}`;

  const paymentRef = db.collection("payments").doc();
  const payment = {
    orderId,
    buyerId: userId,
    sellerId: order.sellerId,
    amount: order.totalAmount,
    phoneNumber,
    reference,
    provider: "MoMo",
    status: "Pending",  // Pending | Success | Failed
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  await paymentRef.set(payment);

  return {
    id: paymentRef.id,
    ...payment,
    // In production: include redirect URL or USSD prompt from MoMo API
    message: `A payment prompt has been sent to ${phoneNumber}. Enter your MoMo PIN to confirm.`,
    simulationNote: "In production, connect to the official MoMo API to send a real USSD push.",
  };
};

/**
 * Confirm payment (called after MoMo callback or manual confirmation in simulation).
 * In production, this endpoint is called by MoMo's webhook/callback.
 */
const confirmPayment = async (paymentId, userId, role) => {
  const paymentRef = db.collection("payments").doc(paymentId);
  const paymentDoc = await paymentRef.get();
  if (!paymentDoc.exists) {
    const error = new Error("Payment not found");
    error.statusCode = 404;
    throw error;
  }
  const payment = paymentDoc.data();

  // Only buyer, seller, or admin can confirm (in production, this is called by MoMo webhook)
  if (role !== "Admin" && payment.buyerId !== userId) {
    const error = new Error("Not authorized");
    error.statusCode = 403;
    throw error;
  }

  // Mark payment as successful
  await paymentRef.update({
    status: "Success",
    paidAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });

  // Update order's paymentStatus
  await db.collection("orders").doc(payment.orderId).update({
    paymentStatus: "Paid",
    paymentId,
    updatedAt: new Date().toISOString(),
  });

  // Notify buyer and seller
  await notificationService.notifyUser(payment.buyerId, {
    title: "Payment Successful!",
    body: `Your payment of GHS ${payment.amount} was received. Reference: ${payment.reference}`,
    data: { type: "payment_success", paymentId, orderId: payment.orderId },
  });
  await notificationService.notifyUser(payment.sellerId, {
    title: "Payment Received",
    body: `Payment of GHS ${payment.amount} received for your animal listing.`,
    data: { type: "payment_received", paymentId, orderId: payment.orderId },
  });

  const updated = await paymentRef.get();
  return { id: updated.id, ...updated.data() };
};

/**
 * Get payment by order ID
 */
const getPaymentByOrder = async (orderId, userId, role) => {
  const snapshot = await db
    .collection("payments")
    .where("orderId", "==", orderId)
    .get();
  if (snapshot.empty) {
    const error = new Error("Payment not found for this order");
    error.statusCode = 404;
    throw error;
  }
  const payment = { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
  if (role !== "Admin" && payment.buyerId !== userId && payment.sellerId !== userId) {
    const error = new Error("Not authorized");
    error.statusCode = 403;
    throw error;
  }
  return payment;
};

module.exports = { initiatePayment, confirmPayment, getPaymentByOrder };
