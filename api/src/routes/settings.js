const express = require('express');
const Joi = require('joi');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();
router.use(authenticateToken, requireAdmin);

// Validation schema for updating settings
const updateSettingSchema = Joi.object({
  value: Joi.string().required()
});

// Get all system settings
router.get('/', async (req, res) => {
  try {
    const db = req.app.locals.db;
    const result = await db.query('SELECT * FROM system_settings ORDER BY key');
    res.json(result.rows);
  } catch (error) {
    console.error('Get settings error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get single setting
router.get('/:key', async (req, res) => {
  try {
    const db = req.app.locals.db;
    const result = await db.query('SELECT * FROM system_settings WHERE key = $1', [req.params.key]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Setting not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get setting error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update setting
router.put('/:key', async (req, res) => {
  try {
    const { error, value } = updateSettingSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const db = req.app.locals.db;

    // Check if setting exists
    const existingSetting = await db.query('SELECT * FROM system_settings WHERE key = $1', [req.params.key]);
    if (existingSetting.rows.length === 0) {
      return res.status(404).json({ error: 'Setting not found' });
    }

    // Update the setting
    const result = await db.query(
      'UPDATE system_settings SET value = $1, updated_at = CURRENT_TIMESTAMP WHERE key = $2 RETURNING *',
      [value.value, req.params.key]
    );

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Update setting error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
