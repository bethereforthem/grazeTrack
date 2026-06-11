/**
 * Public Routes — no authentication middleware applied here
 *
 * Route prefix: /api/public
 *
 * These are safe to call from any browser without a login token.
 * They only expose listing/farmer data that sellers have made public.
 */

const express = require("express");
const router = express.Router();
const {
  getPublicListings,
  getPublicListing,
  getFarmerProfile,
} = require("../controllers/publicController");

// Browse all available listings (with optional filters)
// Example: GET /api/public/listings?type=Cow&location=Kumasi
router.get("/listings", getPublicListings);

// View a single listing by its ID
router.get("/listings/:id", getPublicListing);

// View a farmer's public profile and their active listings
router.get("/farmers/:sellerId", getFarmerProfile);

module.exports = router;
