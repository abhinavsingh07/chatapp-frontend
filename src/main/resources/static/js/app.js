// Constructor function
function Validator() { }

// Sanitize input (XSS prevention)
Validator.prototype.sanitizeInput = function (value) {
  if (typeof value !== "string") {
    return "";
  }

  var sanitized = value.trim();

  // Remove dangerous tags
  sanitized = sanitized.replace(/<\s*script.*?>.*?<\s*\/\s*script\s*>/gi, "");
  sanitized = sanitized.replace(/<\s*iframe.*?>.*?<\s*\/\s*iframe\s*>/gi, "");
  sanitized = sanitized.replace(/<\s*object.*?>.*?<\s*\/\s*object\s*>/gi, "");

  // Encode HTML entities
  sanitized = sanitized
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#x27;");

  return sanitized;
};

/**
  * Checks if a value is safe after sanitization (no HTML/script content).
  * @param {string} value - Input to check
  * @returns {boolean} - True if safe, false if unsafe
  */

Validator.prototype.isSafe = function (value) {
  if (typeof value !== "string" || value.trim() === "") {
    return false;
  }
  const sanitized = this.sanitizeInput(value);
  // If sanitization changes the value, it means it had unsafe content
  return sanitized === value.trim();
};


// Email validation
Validator.prototype.isEmail = function (email) {
  var clean = this.sanitizeInput(email);
  var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return typeof clean === "string" && emailRegex.test(clean);
};

// Phone validation
Validator.prototype.isPhone = function (phone) {
  var clean = this.sanitizeInput(phone);
  var phoneRegex = /^\+?[0-9\s\-]{7,15}$/;
  return typeof clean === "string" && phoneRegex.test(clean);
};

// Empty string check
Validator.prototype.isEmpty = function (value) {
  var clean = this.sanitizeInput(value);
  return clean === "";
};

// Strong password check
Validator.prototype.isStrongPassword = function (password) {
  var clean = this.sanitizeInput(password);
  var passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/;
  return typeof clean === "string" && passwordRegex.test(clean);
};


// Example usage
// var util = new Validator();
// console.log(util.isEmail("john.doe@example.com"));      // true
// console.log(util.isPhone("+1 234-567-8901"));           // true
// console.log(util.isEmpty("   "));                       // true
// console.log(util.isStrongPassword("Pass@1234"));        // true