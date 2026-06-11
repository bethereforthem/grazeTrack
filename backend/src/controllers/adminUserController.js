/**
 * Admin User Management Controller
 * Handles all user management operations
 */

const UserManagementService = require("../services/userManagementService");
const AdminValidator = require("../utils/adminValidator");
const AdminLogger = require("../utils/adminLogger");

/**
 * Get all users
 * GET /api/v1/admin/users
 */
exports.getAllUsers = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      search,
      status,
      role,
      sortBy,
      sortOrder,
    } = req.query;

    const options = {
      page: parseInt(page) || 1,
      limit: parseInt(limit) || 20,
      search: search || "",
      status: status || null,
      role: role || null,
      sortBy: sortBy || "createdAt",
      sortOrder: sortOrder || "desc",
    };

    const result = await UserManagementService.getAllUsers(options);

    res.status(200).json({
      success: true,
      message: "Users retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "GET_USERS_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(500).json({
      success: false,
      message: "Failed to retrieve users",
    });
  }
};

/**
 * Get user by ID
 * GET /api/v1/admin/users/:id
 */
exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await UserManagementService.getUserById(id);

    res.status(200).json({
      success: true,
      message: "User retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "GET_USER_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(error.message.includes("not found") ? 404 : 500).json({
      success: false,
      message: error.message || "Failed to retrieve user",
    });
  }
};

/**
 * Create new user
 * POST /api/v1/admin/users
 */
exports.createUser = async (req, res) => {
  try {
    const { name, email, password, role, phone } = req.body;

    const userData = {
      name: name || "",
      email: email,
      password: password,
      role: role || "Farmer",
      phone: phone || "",
    };

    const result = await UserManagementService.createUser(
      userData,
      req.admin.id,
    );

    res.status(201).json({
      success: true,
      message: "User created successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "CREATE_USER_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(400).json({
      success: false,
      message: error.message || "Failed to create user",
    });
  }
};

/**
 * Update user
 * PUT /api/v1/admin/users/:id
 */
exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const result = await UserManagementService.updateUser(
      id,
      updateData,
      req.admin.id,
    );

    res.status(200).json({
      success: true,
      message: "User updated successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "UPDATE_USER_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(error.message.includes("not found") ? 404 : 400).json({
      success: false,
      message: error.message || "Failed to update user",
    });
  }
};

/**
 * Suspend user
 * PUT /api/v1/admin/users/:id/suspend
 */
exports.suspendUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const result = await UserManagementService.suspendUser(
      id,
      req.admin.id,
      reason || "",
    );

    res.status(200).json({
      success: true,
      message: "User suspended successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "SUSPEND_USER_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(error.message.includes("not found") ? 404 : 400).json({
      success: false,
      message: error.message || "Failed to suspend user",
    });
  }
};

/**
 * Reactivate user
 * PUT /api/v1/admin/users/:id/reactivate
 */
exports.reactivateUser = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await UserManagementService.reactivateUser(id, req.admin.id);

    res.status(200).json({
      success: true,
      message: "User reactivated successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "REACTIVATE_USER_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(error.message.includes("not found") ? 404 : 400).json({
      success: false,
      message: error.message || "Failed to reactivate user",
    });
  }
};

/**
 * Delete user
 * DELETE /api/v1/admin/users/:id
 */
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await UserManagementService.deleteUser(id, req.admin.id);

    res.status(200).json({
      success: true,
      message: "User deleted successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "DELETE_USER_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(error.message.includes("not found") ? 404 : 400).json({
      success: false,
      message: error.message || "Failed to delete user",
    });
  }
};

/**
 * Get user activity summary
 * GET /api/v1/admin/users/:id/activity
 */
exports.getUserActivitySummary = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await UserManagementService.getUserActivitySummary(id);

    res.status(200).json({
      success: true,
      message: "User activity summary retrieved successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "GET_USER_ACTIVITY_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(error.message.includes("not found") ? 404 : 500).json({
      success: false,
      message: error.message || "Failed to retrieve user activity summary",
    });
  }
};

/**
 * Reset user password
 * POST /api/v1/admin/users/:id/reset-password
 */
exports.resetUserPassword = async (req, res) => {
  try {
    const { id } = req.params;
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        message: "New password is required",
      });
    }

    const result = await UserManagementService.resetUserPassword(
      id,
      password,
      req.admin.id,
    );

    res.status(200).json({
      success: true,
      message: "Password reset successfully",
      data: result,
    });
  } catch (error) {
    AdminLogger.logError({
      errorType: "RESET_PASSWORD_ERROR",
      message: error.message,
      userId: req.admin.id,
    });

    res.status(error.message.includes("not found") ? 404 : 400).json({
      success: false,
      message: error.message || "Failed to reset password",
    });
  }
};
