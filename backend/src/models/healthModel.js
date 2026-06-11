/**
 * Health record data structure for Firestore
 * Collection: health/{healthId}
 */
const HealthModel = {
  animalId: "",          // Reference to animals/{animalId}
  userId: "",            // Who recorded this health event
  type: "",              // vaccination | treatment | checkup | deworming
  vaccination: "",       // Vaccine name (if type is vaccination)
  status: "",            // healthy | sick | recovering | critical
  description: "",       // Description of the health event
  medicine: "",          // Medicine used (if any)
  cost: 0,               // Cost of treatment/medicine
  vet: "",               // Veterinarian name (optional)
  nextCheckupDate: "",   // ISO date for next scheduled checkup
  date: "",              // ISO timestamp of the health event
  createdAt: "",
};

module.exports = HealthModel;
