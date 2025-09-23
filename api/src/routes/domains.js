const express = require('express');
const Joi = require('joi');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();
router.use(authenticateToken, requireAdmin);

// Get all domains
router.get('/', async (req, res) => {
  try {
    const db = req.app.locals.db;
    const result = await db.query(`
      SELECT d.*, COUNT(u.id) as user_count
      FROM domains d
      LEFT JOIN users u ON d.id = u.domain_id
      GROUP BY d.id
      ORDER BY d.domain
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Get domains error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create domain
router.post('/', async (req, res) => {
  const schema = Joi.object({
    domain: Joi.string().domain().required(),
    description: Joi.string().max(255),
    active: Joi.boolean().default(true)
  });

  try {
    const { error, value } = schema.validate(req.body);
    if (error) return res.status(400).json({ error: error.details[0].message });

    const db = req.app.locals.db;
    const result = await db.query(
      'INSERT INTO domains (domain, description, active) VALUES ($1, $2, $3) RETURNING *',
      [value.domain, value.description, value.active]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    if (error.code === '23505') {
      return res.status(400).json({ error: 'Domain already exists' });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;