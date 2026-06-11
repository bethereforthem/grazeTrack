/**
 * Feed Controller — handles feeding record requests
 */

const feedService = require("../services/feedService");

// GET /api/v1/feed
const getAllFeed = async (req, res, next) => {
  try {
    const records = await feedService.getAllFeed(req.user.id, req.user.role);
    res.json({ success: true, count: records.length, data: records });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/feed/animal/:animalId
const getFeedByAnimal = async (req, res, next) => {
  try {
    const records = await feedService.getFeedByAnimal(req.params.animalId);
    res.json({ success: true, count: records.length, data: records });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/feed/:id
const getFeed = async (req, res, next) => {
  try {
    const record = await feedService.getFeedById(req.params.id);
    res.json({ success: true, data: record });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/feed
const createFeed = async (req, res, next) => {
  try {
    const record = await feedService.createFeed(req.body, req.user.id);
    res.status(201).json({ success: true, data: record });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/feed/:id
const updateFeed = async (req, res, next) => {
  try {
    const record = await feedService.updateFeed(req.params.id, req.body);
    res.json({ success: true, data: record });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/feed/:id
const deleteFeed = async (req, res, next) => {
  try {
    await feedService.deleteFeed(req.params.id);
    res.json({ success: true, message: "Feed record deleted" });
  } catch (error) {
    next(error);
  }
};

module.exports = { getAllFeed, getFeedByAnimal, getFeed, createFeed, updateFeed, deleteFeed };
