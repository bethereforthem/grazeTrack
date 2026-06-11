/**
 * Encryption Utility
 * Handles encryption/decryption of sensitive data
 * Uses AES-256-GCM for maximum security
 */

const crypto = require("crypto");

class Encryption {
  /**
   * Initialize encryption with key and algorithm
   * Key should be 32 bytes for AES-256
   */
  static getEncryptionKey() {
    const key =
      process.env.ENCRYPTION_KEY ||
      "default-dev-key-change-in-production-32char";

    // Ensure key is 32 bytes for AES-256
    if (key.length < 32) {
      return crypto.scryptSync(key, "salt", 32);
    }
    return key.slice(0, 32);
  }

  /**
   * Encrypt sensitive string data
   * @param {String} plaintext - Data to encrypt
   * @returns {String} Encrypted data with IV and auth tag
   */
  static encrypt(plaintext) {
    try {
      const key = this.getEncryptionKey();
      const iv = crypto.randomBytes(16); // 16 bytes for AES
      const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);

      let encrypted = cipher.update(plaintext, "utf8", "hex");
      encrypted += cipher.final("hex");

      const authTag = cipher.getAuthTag();

      // Return IV + authTag + encrypted data (all hex)
      return (
        iv.toString("hex") + ":" + authTag.toString("hex") + ":" + encrypted
      );
    } catch (error) {
      console.error("Encryption error:", error.message);
      throw new Error("Encryption failed");
    }
  }

  /**
   * Decrypt encrypted data
   * @param {String} encrypted - Encrypted data with IV and auth tag
   * @returns {String} Decrypted plaintext
   */
  static decrypt(encrypted) {
    try {
      const key = this.getEncryptionKey();
      const parts = encrypted.split(":");

      if (parts.length !== 3) {
        throw new Error("Invalid encrypted data format");
      }

      const iv = Buffer.from(parts[0], "hex");
      const authTag = Buffer.from(parts[1], "hex");
      const encryptedData = parts[2];

      const decipher = crypto.createDecipheriv("aes-256-gcm", key, iv);
      decipher.setAuthTag(authTag);

      let decrypted = decipher.update(encryptedData, "hex", "utf8");
      decrypted += decipher.final("utf8");

      return decrypted;
    } catch (error) {
      console.error("Decryption error:", error.message);
      throw new Error("Decryption failed");
    }
  }

  /**
   * Hash data (one-way encryption for comparison)
   * @param {String} data - Data to hash
   * @returns {String} SHA-256 hash
   */
  static hash(data) {
    return crypto.createHash("sha256").update(data).digest("hex");
  }

  /**
   * Generate random token
   * @param {Number} length - Token length in bytes
   * @returns {String} Random hex token
   */
  static generateToken(length = 32) {
    return crypto.randomBytes(length).toString("hex");
  }

  /**
   * Hash and verify token (secure comparison)
   * @param {String} token - Plain token
   * @param {String} hash - Stored hash
   * @returns {Boolean} True if match
   */
  static verifyTokenHash(token, hash) {
    const tokenHash = this.hash(token);
    return crypto.timingSafeEqual(Buffer.from(tokenHash), Buffer.from(hash));
  }
}

module.exports = Encryption;
