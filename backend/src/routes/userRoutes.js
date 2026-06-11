const express = require("express");
const router = express.Router();
const {
  getUsers,
  getUser,
  updateUser,
  changePassword,
  deleteUser,
  getFarmers,
} = require("../controllers/userController");
const { protect } = require("../middleware/authMiddleware");
const { authorize } = require("../middleware/roleMiddleware");

// All routes require authentication
router.use(protect);

// GET all users — Admin only
router.get("/", authorize("Admin"), getUsers);

// GET all active farmers — any logged-in user (used by in-app chat)
router.get("/farmers", getFarmers);

// GET / UPDATE / DELETE single user
router
  .route("/:id")
  .get(getUser)
  .put(updateUser)
  .delete(authorize("Admin"), deleteUser);

// Change password — own account only
router.put("/:id/password", changePassword);

module.exports = router;
