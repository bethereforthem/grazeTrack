/**
 * User Controller — manages user profiles (Admin operations)
 */

const { db } = require("../config/firebase");
const bcrypt = require("bcryptjs");

// GET /api/v1/users  — Admin only
const getUsers = async (req, res, next) => {
  try {
    const snapshot = await db.collection("users").orderBy("createdAt", "desc").get();
    const users = snapshot.docs.map((doc) => {
      const data = doc.data();
      delete data.password; // Never return password
      return { id: doc.id, ...data };
    });
    res.json({ success: true, count: users.length, data: users });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/users/:id
const getUser = async (req, res, next) => {
  try {
    const doc = await db.collection("users").doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    const data = doc.data();
    delete data.password;
    res.json({ success: true, data: { id: doc.id, ...data } });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/users/:id  — Update profile (own profile or Admin)
const updateUser = async (req, res, next) => {
  try {
    const { name, phone, profilePhotoUrl } = req.body;

    // Only Admin can update other users
    if (req.params.id !== req.user.id && req.user.role !== "Admin") {
      return res.status(403).json({ success: false, message: "Not authorized" });
    }

    const updates = {
      ...(name && { name }),
      ...(phone && { phone }),
      ...(profilePhotoUrl && { profilePhotoUrl }),
      updatedAt: new Date().toISOString(),
    };

    await db.collection("users").doc(req.params.id).update(updates);
    const updated = await db.collection("users").doc(req.params.id).get();
    const data = updated.data();
    delete data.password;

    res.json({ success: true, data: { id: updated.id, ...data } });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/users/:id/password  — Change password
const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (req.params.id !== req.user.id) {
      return res.status(403).json({ success: false, message: "Not authorized" });
    }

    const doc = await db.collection("users").doc(req.params.id).get();
    const userData = doc.data();

    const isMatch = await bcrypt.compare(currentPassword, userData.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: "Current password is incorrect" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await db.collection("users").doc(req.params.id).update({
      password: hashedPassword,
      updatedAt: new Date().toISOString(),
    });

    res.json({ success: true, message: "Password changed successfully" });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/users/:id  — Admin only (deactivate user)
const deleteUser = async (req, res, next) => {
  try {
    await db.collection("users").doc(req.params.id).update({
      isActive: false,
      updatedAt: new Date().toISOString(),
    });
    res.json({ success: true, message: "User deactivated" });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/users/farmers  — list all active Farmers (any auth user can call this)
// Used by the in-app chat to let a user pick who to message
const getFarmers = async (req, res, next) => {
  try {
    const snapshot = await db
      .collection("users")
      .where("role", "==", "Farmer")
      .where("isActive", "==", true)
      .get();
    const farmers = snapshot.docs
      .map((doc) => {
        const d = doc.data();
        return {
          id: doc.id,
          name: d.name,
          profilePhotoUrl: d.profilePhotoUrl || "",
          phone: d.phone || "",
        };
      })
      // exclude the caller themselves
      .filter((f) => f.id !== req.user.id);
    res.json({ success: true, count: farmers.length, data: farmers });
  } catch (error) {
    next(error);
  }
};

module.exports = { getUsers, getUser, updateUser, changePassword, deleteUser, getFarmers };
