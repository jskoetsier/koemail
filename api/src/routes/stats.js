const express = require('express');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();
router.use(authenticateToken, requireAdmin);

router.get('/', async (req, res) => {
  try {
    const db = req.app.locals.db;

    // Get basic stats
    const stats = await Promise.all([
      db.query('SELECT COUNT(*) as total_users FROM users WHERE active = true'),
      db.query('SELECT COUNT(*) as total_domains FROM domains WHERE active = true'),
      db.query('SELECT COUNT(*) as total_aliases FROM aliases WHERE active = true'),
      db.query('SELECT SUM(bytes_used) as total_storage FROM quota_usage'),
    ]);

    res.json({
      users: parseInt(stats[0].rows[0].total_users),
      domains: parseInt(stats[1].rows[0].total_domains),
      aliases: parseInt(stats[2].rows[0].total_aliases),
      storage: parseInt(stats[3].rows[0].total_storage) || 0,
    });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
