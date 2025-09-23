const jwt = require('jsonwebtoken');

// Middleware to authenticate JWT tokens
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    
    req.user = user;
    next();
  });
};

// Middleware to require admin privileges
const requireAdmin = (req, res, next) => {
  if (!req.user || !req.user.admin) {
    return res.status(403).json({ error: 'Admin privileges required' });
  }
  next();
};

// Middleware to check if user owns resource or is admin
const requireOwnershipOrAdmin = (userIdParam = 'userId') => {
  return (req, res, next) => {
    const resourceUserId = req.params[userIdParam];
    
    if (req.user.admin || req.user.userId.toString() === resourceUserId) {
      return next();
    }
    
    return res.status(403).json({ error: 'Insufficient permissions' });
  };
};

module.exports = {
  authenticateToken,
  requireAdmin,
  requireOwnershipOrAdmin
};