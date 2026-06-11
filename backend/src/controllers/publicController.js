/**
 * Public Controller — no login required
 *
 * These endpoints are accessed by:
 *   1. The web public marketplace page (web/index.html)
 *   2. Anyone searching the app name in a browser
 *
 * Public users can ONLY browse — they cannot chat or access private data.
 */

const listingService = require("../services/listingService");

// GET /api/public/listings
// Returns all available listings — supports same filters as the private endpoint
const getPublicListings = async (req, res, next) => {
  try {
    const { type, minPrice, maxPrice, location, search, sellerId } = req.query;
    const listings = await listingService.getAllListings({
      type,
      minPrice,
      maxPrice,
      location,
      search,
      sellerId,
    });
    res.json({ success: true, count: listings.length, data: listings });
  } catch (error) {
    next(error);
  }
};

// GET /api/public/listings/:id
// Returns a single listing — public viewers can see full details and contact info
const getPublicListing = async (req, res, next) => {
  try {
    const listing = await listingService.getListingById(req.params.id);
    res.json({ success: true, data: listing });
  } catch (error) {
    next(error);
  }
};

// GET /api/public/farmers/:sellerId
// Returns a farmer's public profile: their info + all their active listings
const getFarmerProfile = async (req, res, next) => {
  try {
    const { sellerId } = req.params;
    const listings = await listingService.getAllListings({ sellerId });

    // Build a public profile from the first listing's seller data
    const profile =
      listings.length > 0
        ? {
            sellerId,
            sellerName: listings[0].sellerName,
            farmLocation: listings[0].farmLocation,
            contactPhone: listings[0].contactPhone,
            contactEmail: listings[0].contactEmail,
            sellerProfileImage: listings[0].sellerProfileImage || "",
            verified: listings[0].verified || false,
            totalListings: listings.length,
          }
        : { sellerId, sellerName: "Unknown Farmer", totalListings: 0 };

    res.json({ success: true, data: { profile, listings } });
  } catch (error) {
    next(error);
  }
};

module.exports = { getPublicListings, getPublicListing, getFarmerProfile };
