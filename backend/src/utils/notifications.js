/**
 * Notifications Utility — Firebase Cloud Messaging (FCM)
 * Sends push notifications to mobile devices
 *
 * HOW IT WORKS:
 * 1. Each user stores their FCM token in Firestore (sent from the Flutter app on login)
 * 2. When an event occurs (e.g., upcoming vaccination), we get the user's FCM token
 * 3. We send a push notification via Firebase Cloud Messaging
 */

const { messaging, db } = require("../config/firebase");
const logger = require("./logger");

/**
 * Send a push notification to a single user
 * @param {string} userId - Target user's Firestore ID
 * @param {string} title - Notification title
 * @param {string} body - Notification body text
 * @param {Object} data - Optional extra data payload
 */
const sendNotificationToUser = async (userId, title, body, data = {}) => {
  try {
    // Get user's FCM token from Firestore
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) return;

    const fcmToken = userDoc.data().fcmToken;
    if (!fcmToken) {
      logger.warn(`No FCM token for user ${userId}`);
      return;
    }

    const message = {
      token: fcmToken,
      notification: { title, body },
      data: { ...data, click_action: "FLUTTER_NOTIFICATION_CLICK" },
      android: {
        notification: {
          sound: "default",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: { sound: "default" },
        },
      },
    };

    const response = await messaging.send(message);
    logger.info(`Notification sent to user ${userId}: ${response}`);
    return response;
  } catch (error) {
    logger.error(`Failed to send notification to user ${userId}: ${error.message}`);
  }
};

/**
 * Send vaccination reminder notification
 * @param {string} userId
 * @param {string} animalName
 * @param {string} vaccinationDate
 */
const sendVaccinationReminder = async (userId, animalName, vaccinationDate) => {
  await sendNotificationToUser(
    userId,
    "Vaccination Reminder",
    `${animalName} is due for vaccination on ${vaccinationDate}`,
    { type: "vaccination_reminder" }
  );
};

/**
 * Send expense alert when total expenses exceed a threshold
 * @param {string} userId
 * @param {number} totalExpenses
 * @param {number} threshold
 */
const sendExpenseAlert = async (userId, totalExpenses, threshold) => {
  await sendNotificationToUser(
    userId,
    "Expense Alert",
    `Your expenses ($${totalExpenses}) have exceeded the threshold ($${threshold})`,
    { type: "expense_alert" }
  );
};

/**
 * Send loss alert after a sale results in a loss
 * @param {string} userId
 * @param {string} animalInfo - e.g., "Cow - Friesian"
 * @param {number} lossAmount
 */
const sendLossAlert = async (userId, animalInfo, lossAmount) => {
  await sendNotificationToUser(
    userId,
    "Sale Loss Alert",
    `Sale of ${animalInfo} resulted in a loss of $${Math.abs(lossAmount)}`,
    { type: "loss_alert" }
  );
};

module.exports = {
  sendNotificationToUser,
  sendVaccinationReminder,
  sendExpenseAlert,
  sendLossAlert,
};
