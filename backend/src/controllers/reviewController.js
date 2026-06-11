const reviewService = require("../services/reviewService");

// POST /api/v1/reviews
const createReview = async (req, res, next) => {
  try {
    const review = await reviewService.createReview(
      req.body,
      req.user.id,
      req.user.name
    );
    res.status(201).json({ success: true, data: review });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/reviews/seller/:sellerId
const getSellerReviews = async (req, res, next) => {
  try {
    const reviews = await reviewService.getSellerReviews(req.params.sellerId);
    res.json({ success: true, count: reviews.length, data: reviews });
  } catch (error) {
    next(error);
  }
};

module.exports = { createReview, getSellerReviews };
