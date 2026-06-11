/**
 * User Management Service
 * Handles all user management operations for admins
 */

const bcrypt = require("bcryptjs");
const { db } = require("../config/firebase");
const AdminLogger = require("../utils/adminLogger");

class UserManagementService {
  /**
   * Get all users with filters and pagination
   * @param {Object} options - Filter and pagination options
   */
  static async getAllUsers(options = {}) {
    try {
      const {
        page = 1,
        limit = 20,
        search = "",
        status = null,
        role = null,
        sortBy = "createdAt",
        sortOrder = "desc",
      } = options;

      let query = db.collection("users");

      // Apply filters
      if (status) {
        query = query.where("isActive", "==", status === "ACTIVE");
      }

      if (role) {
        query = query.where("role", "==", role);
      }

      // Get total count
      const countSnapshot = await query.count().get();
      const totalUsers = countSnapshot.data().count;

      // Apply sorting and pagination
      const offset = (page - 1) * limit;
      const snapshot = await query
        .orderBy(sortBy, sortOrder)
        .offset(offset)
        .limit(limit)
        .get();

      const users = [];
      snapshot.forEach((doc) => {
        const userData = doc.data();

        // Filter by search if provided
        if (search && !this._matchesSearch(userData, search)) {
          return;
        }

        users.push({
          id: doc.id,
          name: userData.name,
          email: userData.email,
          role: userData.role,
          phone: userData.phone,
          isActive: userData.isActive,
          createdAt: userData.createdAt,
          updatedAt: userData.updatedAt,
          lastLoginAt: userData.lastLoginAt || null,
        });
      });

      return {
        success: true,
        users: users,
        pagination: {
          page: page,
          limit: limit,
          total: totalUsers,
          totalPages: Math.ceil(totalUsers / limit),
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "GET_USERS_ERROR",
        message: error.message,
      });
      throw error;
    }
  }

  /**
   * Get single user by ID
   * @param {String} userId - User ID
   */
  static async getUserById(userId) {
    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const userData = userDoc.data();
      return {
        success: true,
        user: {
          id: userId,
          name: userData.name,
          email: userData.email,
          role: userData.role,
          phone: userData.phone,
          profilePhotoUrl: userData.profilePhotoUrl,
          isActive: userData.isActive,
          createdAt: userData.createdAt,
          updatedAt: userData.updatedAt,
          lastLoginAt: userData.lastLoginAt || null,
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "GET_USER_ERROR",
        message: error.message,
      });
      throw error;
    }
  }

  /**
   * Create new user
   * @param {Object} userData - User data
   * @param {String} adminId - Admin creating user
   */
  static async createUser(userData, adminId) {
    try {
      if (!userData.email || !userData.password) {
        throw new Error("Email and password are required");
      }

      // Check if email exists
      const existingUser = await db
        .collection("users")
        .where("email", "==", userData.email.toLowerCase())
        .get();

      if (!existingUser.empty) {
        throw new Error("User email already exists");
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(userData.password, 12);

      const newUserData = {
        name: userData.name || "",
        email: userData.email.toLowerCase(),
        password: hashedPassword,
        role: userData.role || "Farmer",
        phone: userData.phone || "",
        profilePhotoUrl: "",
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      const docRef = await db.collection("users").add(newUserData);

      AdminLogger.logActivity({
        type: "USER_CREATION",
        userId: adminId,
        action: "CREATE",
        resourceType: "USER",
        resourceId: docRef.id,
        status: "SUCCESS",
        message: `New user created: ${userData.email}`,
      });

      return {
        success: true,
        message: "User created successfully",
        userId: docRef.id,
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "CREATE_USER_ERROR",
        message: error.message,
        userId: adminId,
      });
      throw error;
    }
  }

  /**
   * Update user details
   * @param {String} userId - User ID
   * @param {Object} updateData - Data to update
   * @param {String} adminId - Admin making changes
   */
  static async updateUser(userId, updateData, adminId) {
    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const oldData = userDoc.data();

      // Prepare update data (don't allow certain fields)
      const allowedFields = ["name", "phone", "role"];
      const update = {};
      allowedFields.forEach((field) => {
        if (updateData.hasOwnProperty(field)) {
          update[field] = updateData[field];
        }
      });

      update.updatedAt = new Date();

      await db.collection("users").doc(userId).update(update);

      AdminLogger.logActivity({
        type: "USER_UPDATE",
        userId: adminId,
        action: "UPDATE",
        resourceType: "USER",
        resourceId: userId,
        changes: {
          before: oldData,
          after: { ...oldData, ...update },
        },
        status: "SUCCESS",
        message: `User updated: ${oldData.email}`,
      });

      return {
        success: true,
        message: "User updated successfully",
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "UPDATE_USER_ERROR",
        message: error.message,
        userId: adminId,
      });
      throw error;
    }
  }

  /**
   * Suspend user account
   * @param {String} userId - User ID
   * @param {String} adminId - Admin suspending
   * @param {String} reason - Reason for suspension
   */
  static async suspendUser(userId, adminId, reason = "") {
    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const userData = userDoc.data();
      if (!userData.isActive) {
        throw new Error("User is already suspended or inactive");
      }

      await db.collection("users").doc(userId).update({
        isActive: false,
        suspendedAt: new Date(),
        suspendedBy: adminId,
        suspensionReason: reason,
        updatedAt: new Date(),
      });

      AdminLogger.logActivity({
        type: "USER_SUSPENSION",
        userId: adminId,
        action: "SUSPEND",
        resourceType: "USER",
        resourceId: userId,
        status: "SUCCESS",
        message: `User suspended: ${userData.email}. Reason: ${reason}`,
        metadata: {
          severity: "HIGH",
        },
      });

      return {
        success: true,
        message: "User suspended successfully",
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "SUSPEND_USER_ERROR",
        message: error.message,
        userId: adminId,
      });
      throw error;
    }
  }

  /**
   * Reactivate suspended user
   * @param {String} userId - User ID
   * @param {String} adminId - Admin reactivating
   */
  static async reactivateUser(userId, adminId) {
    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const userData = userDoc.data();
      if (userData.isActive) {
        throw new Error("User is already active");
      }

      await db.collection("users").doc(userId).update({
        isActive: true,
        suspendedAt: null,
        suspendedBy: null,
        suspensionReason: null,
        updatedAt: new Date(),
      });

      AdminLogger.logActivity({
        type: "USER_REACTIVATION",
        userId: adminId,
        action: "UPDATE",
        resourceType: "USER",
        resourceId: userId,
        status: "SUCCESS",
        message: `User reactivated: ${userData.email}`,
        metadata: {
          severity: "MEDIUM",
        },
      });

      return {
        success: true,
        message: "User reactivated successfully",
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "REACTIVATE_USER_ERROR",
        message: error.message,
        userId: adminId,
      });
      throw error;
    }
  }

  /**
   * Delete user account
   * @param {String} userId - User ID
   * @param {String} adminId - Admin deleting
   */
  static async deleteUser(userId, adminId) {
    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const userData = userDoc.data();
      await db.collection("users").doc(userId).delete();

      AdminLogger.logActivity({
        type: "USER_DELETION",
        userId: adminId,
        action: "DELETE",
        resourceType: "USER",
        resourceId: userId,
        status: "SUCCESS",
        message: `User deleted: ${userData.email}`,
        metadata: {
          severity: "CRITICAL",
        },
      });

      return {
        success: true,
        message: "User deleted successfully",
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "DELETE_USER_ERROR",
        message: error.message,
        userId: adminId,
      });
      throw error;
    }
  }

  /**
   * Reset user password
   * @param {String} userId - User ID
   * @param {String} newPassword - New password
   * @param {String} adminId - Admin resetting password
   */
  static async resetUserPassword(userId, newPassword, adminId) {
    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const hashedPassword = await bcrypt.hash(newPassword, 12);

      await db.collection("users").doc(userId).update({
        password: hashedPassword,
        updatedAt: new Date(),
      });

      AdminLogger.logActivity({
        type: "PASSWORD_RESET",
        userId: adminId,
        action: "UPDATE",
        resourceType: "USER",
        resourceId: userId,
        status: "SUCCESS",
        message: `Password reset for user: ${userDoc.data().email}`,
        metadata: {
          severity: "MEDIUM",
        },
      });

      return {
        success: true,
        message: "Password reset successfully",
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "RESET_PASSWORD_ERROR",
        message: error.message,
        userId: adminId,
      });
      throw error;
    }
  }

  /**
   * Get user activity summary (animals, health records, sales, etc.)
   * @param {String} userId - User ID
   */
  static async getUserActivitySummary(userId) {
    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const userData = userDoc.data();

      // Fetch counts in parallel for performance
      const [
        animalsSnap,
        healthSnap,
        feedSnap,
        expensesSnap,
        salesSnap,
        listingsSnap,
        ordersSnap,
        logsSnap,
        sessionsSnap,
      ] = await Promise.all([
        db.collection("animals").where("userId", "==", userId).count().get(),
        db.collection("health").where("userId", "==", userId).count().get(),
        db.collection("feed").where("userId", "==", userId).count().get(),
        db.collection("expenses").where("userId", "==", userId).count().get(),
        db.collection("sales").where("userId", "==", userId).count().get(),
        db.collection("listings").where("sellerId", "==", userId).count().get(),
        db.collection("orders").where("buyerId", "==", userId).count().get(),
        db
          .collection("activity_logs")
          .where("userId", "==", userId)
          .orderBy("timestamp", "desc")
          .limit(10)
          .get(),
        db
          .collection("user_sessions")
          .where("userId", "==", userId)
          .orderBy("loginAt", "desc")
          .limit(5)
          .get(),
      ]);

      const recentLogs = [];
      logsSnap.forEach((doc) => recentLogs.push({ id: doc.id, ...doc.data() }));

      const recentSessions = [];
      sessionsSnap.forEach((doc) =>
        recentSessions.push({ id: doc.id, ...doc.data() }),
      );

      return {
        success: true,
        summary: {
          user: {
            id: userId,
            name: userData.name,
            email: userData.email,
            role: userData.role,
            isActive: userData.isActive,
            createdAt: userData.createdAt,
            lastLoginAt: userData.lastLoginAt || null,
          },
          activityCounts: {
            animals: animalsSnap.data().count,
            healthRecords: healthSnap.data().count,
            feedRecords: feedSnap.data().count,
            expenses: expensesSnap.data().count,
            sales: salesSnap.data().count,
            listings: listingsSnap.data().count,
            orders: ordersSnap.data().count,
          },
          recentActivity: recentLogs,
          recentSessions: recentSessions,
        },
      };
    } catch (error) {
      AdminLogger.logError({
        errorType: "GET_USER_ACTIVITY_ERROR",
        message: error.message,
      });
      throw error;
    }
  }

  /**
   * Search users by name or email
   * @private
   */
  static _matchesSearch(userData, searchTerm) {
    const term = searchTerm.toLowerCase();
    return (
      (userData.name && userData.name.toLowerCase().includes(term)) ||
      (userData.email && userData.email.toLowerCase().includes(term))
    );
  }
}

module.exports = UserManagementService;
