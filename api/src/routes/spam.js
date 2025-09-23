const express = require('express');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
router.use(authenticateToken);

// Get user's spam quarantine
router.get('/quarantine', async (req, res) => {
  try {
    const db = req.app.locals.db;
    const result = await db.query(`
      SELECT * FROM spam_quarantine 
      WHERE user_id = $1 AND released = false
      ORDER BY quarantine_date DESC
    `, [req.user.userId]);
    
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Release spam message
router.post('/quarantine/:id/release', async (req, res) => {
  try {
    const db = req.app.locals.db;
    await db.query(`
      UPDATE spam_quarantine 
      SET released = true, released_at = CURRENT_TIMESTAMP 
      WHERE id = $1 AND user_id = $2
    `, [req.params.id, req.user.userId]);
    
    res.json({ message: 'Message released from quarantine' });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;