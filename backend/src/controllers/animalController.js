const animalService = require("../services/animalService");

// GET /api/v1/animals
const getAnimals = async (req, res, next) => {
  try {
    const animals = await animalService.getAllAnimals(
      req.user.id,
      req.user.role,
    );
    res.json({ success: true, count: animals.length, data: animals });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/animals/:id
const getAnimal = async (req, res, next) => {
  try {
    const animal = await animalService.getAnimalById(req.params.id);
    res.json({ success: true, data: animal });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/animals
const createAnimal = async (req, res, next) => {
  try {
    const animal = await animalService.createAnimal(req.body, req.user.id);
    res.status(201).json({ success: true, data: animal });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/animals/:id
const updateAnimal = async (req, res, next) => {
  try {
    const animal = await animalService.updateAnimal(req.params.id, req.body);
    res.json({ success: true, data: animal });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/animals/:id  (Admin only)
const deleteAnimal = async (req, res, next) => {
  try {
    await animalService.deleteAnimal(req.params.id);
    res.json({ success: true, message: "Animal deleted" });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAnimals,
  getAnimal,
  createAnimal,
  updateAnimal,
  deleteAnimal,
};
