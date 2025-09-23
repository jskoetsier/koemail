const express = require('express');
const Joi = require('joi');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();
router.use(authenticateToken, requireAdmin);

// Validation schemas
const createDomainSchema = Joi.object({
  domain: Joi.string().domain().required(),
  description: Joi.string().max(255).allow(''),
  active: Joi.boolean().default(true)
});

const updateDomainSchema = Joi.object({
  description: Joi.string().max(255).allow(''),
  active: Joi.boolean()
});

// Get all domains
router.get('/', async (req, res) => {
  try {
    const db = req.app.locals.db;
    const result = await db.query(`
      SELECT d.*, COUNT(u.id) as user_count
      FROM domains d
      LEFT JOIN users u ON d.id = u.domain_id AND u.active = true
      GROUP BY d.id
      ORDER BY d.domain
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Get domains error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get single domain
router.get('/:id', async (req, res) => {
  try {
    const db = req.app.locals.db;
    const domainId = parseInt(req.params.id);
    
    const result = await db.query(`
      SELECT d.*, COUNT(u.id) as user_count
      FROM domains d
      LEFT JOIN users u ON d.id = u.domain_id AND u.active = true
      WHERE d.id = $1
      GROUP BY d.id
    `, [domainId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Domain not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get domain error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create domain
router.post('/', async (req, res) => {
  try {
    const { error, value } = createDomainSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const db = req.app.locals.db;
    const result = await db.query(
      'INSERT INTO domains (domain, description, active) VALUES ($1, $2, $3) RETURNING *',
      [value.domain.toLowerCase(), value.description || null, value.active]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Create domain error:', error);
    if (error.code === '23505') {
      return res.status(400).json({ error: 'Domain already exists' });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update domain
router.put('/:id', async (req, res) => {
  try {
    const domainId = parseInt(req.params.id);
    const { error, value } = updateDomainSchema.validate(req.body);
    
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const db = req.app.locals.db;

    // Check if domain exists
    const existingDomain = await db.query('SELECT id FROM domains WHERE id = $1', [domainId]);
    if (existingDomain.rows.length === 0) {
      return res.status(404).json({ error: 'Domain not found' });
    }

    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramCount = 1;

    for (const [key, val] of Object.entries(value)) {
      if (val !== undefined) {
        updates.push(`${key} = $${paramCount}`);
        values.push(val);
        paramCount++;
      }
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    values.push(domainId);

    const result = await db.query(`
      UPDATE domains 
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `, values);

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Update domain error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete domain
router.delete('/:id', async (req, res) => {
  try {
    const domainId = parseInt(req.params.id);
    const db = req.app.locals.db;

    // Check if domain has users
    const userCount = await db.query('SELECT COUNT(*) FROM users WHERE domain_id = $1', [domainId]);
    if (parseInt(userCount.rows[0].count) > 0) {
      return res.status(400).json({ error: 'Cannot delete domain with existing users' });
    }

    const result = await db.query('DELETE FROM domains WHERE id = $1 RETURNING domain', [domainId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Domain not found' });
    }

    res.json({ message: `Domain ${result.rows[0].domain} deleted successfully` });
  } catch (error) {
    console.error('Delete domain error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
