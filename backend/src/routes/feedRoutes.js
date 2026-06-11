const express = require("express");
const router = express.Router();
const {
  getAllFeed,
  getFeedByAnimal,
  getFeed,
  createFeed,
  updateFeed,
  deleteFeed,
} = require("../controllers/feedController");
const { protect } = require("../middleware/authMiddleware");

router.use(protect);

// GET all feed records, POST create a new one
router.route("/").get(getAllFeed).post(createFeed);

// GET feed records for a specific animal
router.get("/animal/:animalId", getFeedByAnimal);

// GET / PUT / DELETE a single feed record
router.route("/:id").get(getFeed).put(updateFeed).delete(deleteFeed);

module.exports = router;
