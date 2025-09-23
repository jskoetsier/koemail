const express = require('express');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();
router.use(authenticateToken, requireAdmin);

router.get('/', async (req, res) => {
  try {
    const db = req.app.locals.db;
    const result = await db.query(`
      SELECT a.*, d.domain
      FROM aliases a
      JOIN domains d ON a.domain_id = d.id
      ORDER BY a.source
    `);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
