const { db } = require("../config/firebase");

/**
 * Submit a review for a seller (only buyers who completed an order can review)
 */
const createReview = async (data, reviewerId, reviewerName) => {
  // Check the reviewer has a completed order with this seller
  const ordersSnap = await db
    .collection("orders")
    .where("buyerId", "==", reviewerId)
    .where("sellerId", "==", data.sellerId)
    .where("status", "==", "Completed")
    .get();

  if (ordersSnap.empty) {
    const error = new Error(
      "You can only review sellers after completing an order with them"
    );
    error.statusCode = 403;
    throw error;
  }

  // Prevent duplicate reviews for the same seller
  const existingSnap = await db
    .collection("reviews")
    .where("reviewerId", "==", reviewerId)
    .where("sellerId", "==", data.sellerId)
    .get();

  if (!existingSnap.empty) {
    const error = new Error("You have already reviewed this seller");
    error.statusCode = 400;
    throw error;
  }

  const ref = db.collection("reviews").doc();
  const review = {
    sellerId: data.sellerId,
    reviewerId,
    reviewerName,
    rating: Math.min(5, Math.max(1, Number(data.rating))), // 1-5
    comment: data.comment || "",
    createdAt: new Date().toISOString(),
  };
  await ref.set(review);

  // Update seller's average rating
  await _updateSellerRating(data.sellerId);

  return { id: ref.id, ...review };
};

/**
 * Get all reviews for a seller
 */
const getSellerReviews = async (sellerId) => {
  const snapshot = await db
    .collection("reviews")
    .where("sellerId", "==", sellerId)
    .get();
  const reviews = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return reviews.sort((a, b) =>
    (b.createdAt || "").localeCompare(a.createdAt || "")
  );
};

/**
 * Recalculate and store seller average rating in users collection
 */
const _updateSellerRating = async (sellerId) => {
  const snapshot = await db
    .collection("reviews")
    .where("sellerId", "==", sellerId)
    .get();
  if (snapshot.empty) return;
  const reviews = snapshot.docs.map((doc) => doc.data());
  const avg =
    reviews.reduce((sum, r) => sum + (r.rating || 0), 0) / reviews.length;
  await db.collection("users").doc(sellerId).update({
    averageRating: Math.round(avg * 10) / 10,
    totalReviews: reviews.length,
  });
};

module.exports = { createReview, getSellerReviews };
