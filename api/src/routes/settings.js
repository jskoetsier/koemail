const express = require('express');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();
router.use(authenticateToken, requireAdmin);

router.get('/', async (req, res) => {
  try {
    const db = req.app.locals.db;
    const result = await db.query('SELECT * FROM system_settings ORDER BY key');
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
