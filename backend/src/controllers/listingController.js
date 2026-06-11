const listingService = require("../services/listingService");

// GET /api/v1/listings  — public marketplace browse
const getListings = async (req, res, next) => {
  try {
    const { type, minPrice, maxPrice, location, search, sellerId } = req.query;
    const listings = await listingService.getAllListings({
      type, minPrice, maxPrice, location, search, sellerId,
    });
    res.json({ success: true, count: listings.length, data: listings });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/listings/mine  — seller's own listings
const getMyListings = async (req, res, next) => {
  try {
    const listings = await listingService.getMyListings(req.user.id);
    res.json({ success: true, count: listings.length, data: listings });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/listings/:id
const getListing = async (req, res, next) => {
  try {
    const listing = await listingService.getListingById(req.params.id);
    res.json({ success: true, data: listing });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/listings
const createListing = async (req, res, next) => {
  try {
    const listing = await listingService.createListing(
      req.body,
      req.user.id,
      req.user.name,
      req.user.phone,
      req.user.profileImage // pass farmer's photo to listing
    );
    res.status(201).json({ success: true, data: listing });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/listings/:id
const updateListing = async (req, res, next) => {
  try {
    const listing = await listingService.updateListing(
      req.params.id,
      req.body,
      req.user.id
    );
    res.json({ success: true, data: listing });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/listings/:id
const deleteListing = async (req, res, next) => {
  try {
    await listingService.deleteListing(req.params.id, req.user.id, req.user.role);
    res.json({ success: true, message: "Listing deleted" });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getListings,
  getMyListings,
  getListing,
  createListing,
  updateListing,
  deleteListing,
};
