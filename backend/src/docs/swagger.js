/**
 * Swagger / OpenAPI Documentation Setup
 * Access docs at: http://localhost:5000/api-docs
 */

const swaggerUi = require("swagger-ui-express");

const swaggerSpec = {
  openapi: "3.0.0",
  info: {
    title: "GrazeTrack API",
    version: "1.0.0",
    description:
      "Smart livestock management API for tracking animals, feeding, health, expenses, and profits.",
    contact: { name: "GrazeTrack Support", email: "support@grazetrack.com" },
  },
  servers: [
    { url: "http://localhost:5000/api/v1", description: "Development Server" },
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: "http",
        scheme: "bearer",
        bearerFormat: "JWT",
        description: "Enter your JWT token from the login response",
      },
    },
    schemas: {
      User: {
        type: "object",
        properties: {
          id: { type: "string" },
          name: { type: "string", example: "John Farmer" },
          email: { type: "string", example: "john@farm.com" },
          role: { type: "string", enum: ["Admin", "Farmer", "Manager"] },
          createdAt: { type: "string", format: "date-time" },
        },
      },
      Animal: {
        type: "object",
        properties: {
          id: { type: "string" },
          name: { type: "string", example: "Bessie" },
          type: { type: "string", example: "Cow" },
          breed: { type: "string", example: "Friesian" },
          age: { type: "number", example: 24 },
          gender: { type: "string", enum: ["Male", "Female"] },
          weight: { type: "number", example: 450 },
          purchaseCost: { type: "number", example: 1200 },
          status: { type: "string", enum: ["active", "sold", "deceased"] },
        },
      },
      Feed: {
        type: "object",
        properties: {
          id: { type: "string" },
          animalId: { type: "string" },
          type: { type: "string", example: "Hay" },
          quantity: { type: "number", example: 10 },
          unit: { type: "string", example: "kg" },
          cost: { type: "number", example: 25 },
          date: { type: "string", format: "date-time" },
        },
      },
      Health: {
        type: "object",
        properties: {
          id: { type: "string" },
          animalId: { type: "string" },
          type: { type: "string", enum: ["vaccination", "treatment", "checkup", "deworming"] },
          status: { type: "string", enum: ["healthy", "sick", "recovering", "critical"] },
          cost: { type: "number", example: 50 },
          date: { type: "string", format: "date-time" },
        },
      },
      Expense: {
        type: "object",
        properties: {
          id: { type: "string" },
          type: { type: "string", enum: ["feed", "medicine", "labor", "equipment", "other"] },
          description: { type: "string" },
          amount: { type: "number", example: 150 },
          date: { type: "string", format: "date-time" },
        },
      },
      Sale: {
        type: "object",
        properties: {
          id: { type: "string" },
          animalId: { type: "string" },
          sellingPrice: { type: "number", example: 2000 },
          totalCost: { type: "number", example: 1500 },
          profit: { type: "number", example: 500 },
          roi: { type: "number", example: 33.33 },
          isProfit: { type: "boolean" },
        },
      },
      Error: {
        type: "object",
        properties: {
          success: { type: "boolean", example: false },
          message: { type: "string" },
        },
      },
    },
  },
  security: [{ bearerAuth: [] }],
  paths: {
    "/auth/register": {
      post: {
        tags: ["Authentication"],
        summary: "Register a new user",
        security: [],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                required: ["name", "email", "password"],
                properties: {
                  name: { type: "string", example: "John Farmer" },
                  email: { type: "string", example: "john@farm.com" },
                  password: { type: "string", example: "securepass123" },
                  role: { type: "string", enum: ["Admin", "Farmer", "Manager"], default: "Farmer" },
                },
              },
            },
          },
        },
        responses: {
          201: { description: "User registered successfully" },
          400: { description: "Email already exists or invalid input" },
        },
      },
    },
    "/auth/login": {
      post: {
        tags: ["Authentication"],
        summary: "Login and receive JWT token",
        security: [],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                required: ["email", "password"],
                properties: {
                  email: { type: "string", example: "john@farm.com" },
                  password: { type: "string", example: "securepass123" },
                },
              },
            },
          },
        },
        responses: {
          200: { description: "Login successful, returns JWT token" },
          401: { description: "Invalid credentials" },
        },
      },
    },
    "/animals": {
      get: {
        tags: ["Animals"],
        summary: "Get all animals",
        responses: { 200: { description: "List of animals" } },
      },
      post: {
        tags: ["Animals"],
        summary: "Register a new animal",
        responses: { 201: { description: "Animal created" } },
      },
    },
    "/animals/{id}": {
      get: { tags: ["Animals"], summary: "Get single animal", parameters: [{ name: "id", in: "path", required: true, schema: { type: "string" } }], responses: { 200: { description: "Animal data" } } },
      put: { tags: ["Animals"], summary: "Update animal", parameters: [{ name: "id", in: "path", required: true, schema: { type: "string" } }], responses: { 200: { description: "Updated animal" } } },
      delete: { tags: ["Animals"], summary: "Delete animal (Admin only)", parameters: [{ name: "id", in: "path", required: true, schema: { type: "string" } }], responses: { 200: { description: "Deleted" } } },
    },
    "/feed": {
      get: { tags: ["Feeding"], summary: "Get all feed records", responses: { 200: { description: "Feed records" } } },
      post: { tags: ["Feeding"], summary: "Add a feed record", responses: { 201: { description: "Feed record created" } } },
    },
    "/health": {
      get: { tags: ["Health"], summary: "Get all health records", responses: { 200: { description: "Health records" } } },
      post: { tags: ["Health"], summary: "Add a health record", responses: { 201: { description: "Health record created" } } },
    },
    "/health/upcoming": {
      get: { tags: ["Health"], summary: "Get upcoming vaccinations (next 7 days)", responses: { 200: { description: "Upcoming vaccinations" } } },
    },
    "/expenses": {
      get: { tags: ["Expenses"], summary: "Get all expenses", responses: { 200: { description: "Expense records" } } },
      post: { tags: ["Expenses"], summary: "Add an expense", responses: { 201: { description: "Expense created" } } },
    },
    "/sales": {
      get: { tags: ["Sales"], summary: "Get all sales", responses: { 200: { description: "Sales records" } } },
      post: { tags: ["Sales"], summary: "Record a sale (auto-calculates profit)", responses: { 201: { description: "Sale recorded with profit calculation" } } },
    },
    "/reports": {
      get: { tags: ["Reports"], summary: "Get full farm analytics report", responses: { 200: { description: "Full farm report" } } },
    },
    "/reports/dashboard": {
      get: { tags: ["Reports"], summary: "Get dashboard quick stats", responses: { 200: { description: "Dashboard stats" } } },
    },
  },
};

module.exports = { swaggerUi, swaggerSpec };
