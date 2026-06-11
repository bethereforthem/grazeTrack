/**
 * User data structure for Firestore
 * Collection: users/{userId}
 */
const UserModel = {
  name: "",             // Full name
  email: "",            // Unique email address
  password: "",         // Bcrypt hashed password (never store plain text)
  role: "Farmer",       // Admin | Farmer | Manager
  phone: "",            // Optional phone number
  profilePhotoUrl: "",  // Firebase Storage URL
  isActive: true,       // Account status
  createdAt: "",        // ISO timestamp
  updatedAt: "",        // ISO timestamp
};

module.exports = UserModel;
