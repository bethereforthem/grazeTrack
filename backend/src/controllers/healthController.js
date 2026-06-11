/**
 * Health Controller — handles animal health record requests
 */

const healthService = require("../services/healthService");

// GET /api/v1/health
const getAllHealth = async (req, res, next) => {
  try {
    const records = await healthService.getAllHealth(req.user.id, req.user.role);
    res.json({ success: true, count: records.length, data: records });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/health/animal/:animalId
const getHealthByAnimal = async (req, res, next) => {
  try {
    const records = await healthService.getHealthByAnimal(req.params.animalId);
    res.json({ success: true, count: records.length, data: records });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/health/upcoming
const getUpcomingVaccinations = async (req, res, next) => {
  try {
    const records = await healthService.getUpcomingVaccinations(req.user.id, req.user.role);
    res.json({ success: true, count: records.length, data: records });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/health/:id
const getHealth = async (req, res, next) => {
  try {
    const record = await healthService.getHealthById(req.params.id);
    res.json({ success: true, data: record });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/health
const createHealth = async (req, res, next) => {
  try {
    const record = await healthService.createHealth(req.body, req.user.id);
    res.status(201).json({ success: true, data: record });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/health/:id
const updateHealth = async (req, res, next) => {
  try {
    const record = await healthService.updateHealth(req.params.id, req.body);
    res.json({ success: true, data: record });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/health/:id
const deleteHealth = async (req, res, next) => {
  try {
    await healthService.deleteHealth(req.params.id);
    res.json({ success: true, message: "Health record deleted" });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllHealth,
  getHealthByAnimal,
  getUpcomingVaccinations,
  getHealth,
  createHealth,
  updateHealth,
  deleteHealth,
};
