const { db } = require("../config/firebase");

/**
 * Get all available listings (public marketplace)
 * Supports filtering by type, minPrice, maxPrice, location
 */
const getAllListings = async (filters = {}) => {
  let query = db.collection("listings").where("status", "==", "available");

  if (filters.type) {
    query = query.where("animalType", "==", filters.type);
  }

  const snapshot = await query.get();
  let listings = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

  // In-memory filtering for price and location (avoids composite index)
  if (filters.minPrice) {
    listings = listings.filter((l) => l.price >= Number(filters.minPrice));
  }
  if (filters.maxPrice) {
    listings = listings.filter((l) => l.price <= Number(filters.maxPrice));
  }
  if (filters.location) {
    const loc = filters.location.toLowerCase();
    listings = listings.filter((l) =>
      (l.farmLocation || "").toLowerCase().includes(loc)
    );
  }
  if (filters.search) {
    const s = filters.search.toLowerCase();
    listings = listings.filter(
      (l) =>
        (l.animalType || "").toLowerCase().includes(s) ||
        (l.breed || "").toLowerCase().includes(s) ||
        (l.description || "").toLowerCase().includes(s) ||
        (l.sellerName || "").toLowerCase().includes(s)
    );
  }

  // Filter by sellerId — used by farmer profile screens
  if (filters.sellerId) {
    listings = listings.filter((l) => l.sellerId === filters.sellerId);
  }

  return listings.sort((a, b) =>
    (b.createdAt || "").localeCompare(a.createdAt || "")
  );
};

/**
 * Get listings belonging to a specific seller
 */
const getMyListings = async (userId) => {
  const snapshot = await db
    .collection("listings")
    .where("sellerId", "==", userId)
    .get();
  const listings = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return listings.sort((a, b) =>
    (b.createdAt || "").localeCompare(a.createdAt || "")
  );
};

/**
 * Get single listing by ID
 */
const getListingById = async (listingId) => {
  const doc = await db.collection("listings").doc(listingId).get();
  if (!doc.exists) {
    const error = new Error("Listing not found");
    error.statusCode = 404;
    throw error;
  }
  return { id: doc.id, ...doc.data() };
};

/**
 * Create a new marketplace listing
 */
const createListing = async (data, userId, userName, userPhone, userPhoto) => {
  const ref = db.collection("listings").doc();
  const listing = {
    sellerId: userId,
    sellerName: userName,
    sellerPhone: userPhone || data.contactPhone || "",
    sellerProfileImage: userPhoto || data.sellerProfileImage || "", // farmer's profile photo
    animalType: data.animalType,
    breed: data.breed || "",
    age: data.age || 0,
    weight: data.weight ? Number(data.weight) : null, // weight in kg
    price: Number(data.price),
    description: data.description || "",
    images: data.images || [],
    farmLocation: data.farmLocation || "",
    contactPhone: data.contactPhone || userPhone || "",
    contactEmail: data.contactEmail || "",
    quantity: data.quantity || 1,
    verified: false, // verification badge — set to true manually by Admin
    status: "available",
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  await ref.set(listing);
  return { id: ref.id, ...listing };
};

/**
 * Update a listing (seller only)
 */
const updateListing = async (listingId, updates, userId) => {
  const ref = db.collection("listings").doc(listingId);
  const doc = await ref.get();
  if (!doc.exists) {
    const error = new Error("Listing not found");
    error.statusCode = 404;
    throw error;
  }
  if (doc.data().sellerId !== userId) {
    const error = new Error("Not authorized to update this listing");
    error.statusCode = 403;
    throw error;
  }
  const allowed = [
    "animalType", "breed", "age", "weight", "price", "description",
    "images", "farmLocation", "contactPhone", "contactEmail",
    "quantity", "status", "sellerProfileImage", "verified",
  ];
  const safeUpdates = {};
  allowed.forEach((k) => { if (updates[k] !== undefined) safeUpdates[k] = updates[k]; });
  await ref.update({ ...safeUpdates, updatedAt: new Date().toISOString() });
  const updated = await ref.get();
  return { id: updated.id, ...updated.data() };
};

/**
 * Delete a listing (seller or Admin)
 */
const deleteListing = async (listingId, userId, role) => {
  const ref = db.collection("listings").doc(listingId);
  const doc = await ref.get();
  if (!doc.exists) {
    const error = new Error("Listing not found");
    error.statusCode = 404;
    throw error;
  }
  if (doc.data().sellerId !== userId && role !== "Admin") {
    const error = new Error("Not authorized to delete this listing");
    error.statusCode = 403;
    throw error;
  }
  await ref.delete();
};

/**
 * Mark listing as sold
 */
const markListingAsSold = async (listingId) => {
  await db.collection("listings").doc(listingId).update({
    status: "sold",
    updatedAt: new Date().toISOString(),
  });
};

module.exports = {
  getAllListings,
  getMyListings,
  getListingById,
  createListing,
  updateListing,
  deleteListing,
  markListingAsSold,
};
