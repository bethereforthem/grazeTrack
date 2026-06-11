const express = require("express");
const router = express.Router();
const {
  getAnimals,
  getAnimal,
  createAnimal,
  updateAnimal,
  deleteAnimal,
} = require("../controllers/animalController");
const { protect } = require("../middleware/authMiddleware");
const { authorize } = require("../middleware/roleMiddleware");

// All routes below require login
router.use(protect);

router
  .route("/")
  .get(getAnimals) // GET all animals
  .post(createAnimal); // POST create animal

router
  .route("/:id")
  .get(getAnimal) // GET one animal
  .put(updateAnimal) // PUT update animal
  .delete(authorize("Admin"), deleteAnimal); // DELETE - Admin only

module.exports = router;
