/**
 * Role-based access control middleware
 * Usage: router.delete('/users/:id', protect, authorize('Admin'), deleteUser)
 *
 * @param {...string} roles - Allowed roles (e.g., 'Admin', 'Manager')
 */
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Role '${req.user.role}' is not authorized for this action`,
      });
    }
    next();
  };
};

module.exports = { authorize };
