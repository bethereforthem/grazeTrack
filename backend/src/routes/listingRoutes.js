const express = require("express");
const router = express.Router();
const {
  getListings,
  getMyListings,
  getListing,
  createListing,
  updateListing,
  deleteListing,
} = require("../controllers/listingController");
const { protect } = require("../middleware/authMiddleware");

// Public — browse marketplace (still needs auth for buyer tracking)
router.use(protect);

router.get("/", getListings);          // GET all available listings
router.get("/mine", getMyListings);    // GET my own listings
router.post("/", createListing);       // POST create listing

router
  .route("/:id")
  .get(getListing)      // GET single listing
  .put(updateListing)   // PUT update listing
  .delete(deleteListing); // DELETE listing

module.exports = router;
