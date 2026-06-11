const express = require("express");
const router = express.Router();
const {
  getAllHealth,
  getHealthByAnimal,
  getUpcomingVaccinations,
  getHealth,
  createHealth,
  updateHealth,
  deleteHealth,
} = require("../controllers/healthController");
const { protect } = require("../middleware/authMiddleware");

router.use(protect);

// GET all health records, POST create a new one
router.route("/").get(getAllHealth).post(createHealth);

// GET upcoming vaccinations (within 7 days)
router.get("/upcoming", getUpcomingVaccinations);

// GET health records for a specific animal
router.get("/animal/:animalId", getHealthByAnimal);

// GET / PUT / DELETE a single health record
router.route("/:id").get(getHealth).put(updateHealth).delete(deleteHealth);

module.exports = router;
