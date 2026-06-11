/**
 * Report Controller — generates analytics and dashboard data
 */

const reportService = require("../services/reportService");

// GET /api/v1/reports?startDate=&endDate=  — full farm report with optional date range
const getFarmReport = async (req, res, next) => {
  try {
    const { startDate, endDate } = req.query;
    const report = await reportService.generateFarmReport(
      req.user.id,
      req.user.role,
      startDate || null,
      endDate || null,
    );
    res.json({ success: true, data: report });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/reports/dashboard  — comprehensive dashboard stats
const getDashboard = async (req, res, next) => {
  try {
    const stats = await reportService.getDashboardStats(req.user.id, req.user.role);
    res.json({ success: true, data: stats });
  } catch (error) {
    next(error);
  }
};

module.exports = { getFarmReport, getDashboard };
