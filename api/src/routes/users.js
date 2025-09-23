const express = require('express');
const bcrypt = require('bcrypt');
const Joi = require('joi');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// Apply authentication to all routes
router.use(authenticateToken);

// Custom email validation that allows IP addresses and regular domains
const emailWithIPSchema = Joi.alternatives().try(
  Joi.string().email(), // Standard email validation
  Joi.string().pattern(/^[^\s@]+@\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) // Email with IP address
).required();

// Validation schemas
const createUserSchema = Joi.object({
  email: emailWithIPSchema,
  password: Joi.string().min(8).required(),
  name: Joi.string().min(1).max(255).required(),
  quota: Joi.number().integer().min(0).default(1073741824), // 1GB default
  admin: Joi.boolean().default(false),
  active: Joi.boolean().default(true),
});

const updateUserSchema = Joi.object({
  name: Joi.string().min(1).max(255),
  quota: Joi.number().integer().min(0),
  admin: Joi.boolean(),
  active: Joi.boolean(),
});

// Get all users (admin only)
router.get('/', requireAdmin, async (req, res) => {
  try {
    const db = req.app.locals.db;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 25;
    const offset = (page - 1) * limit;

    // Get total count
    const countResult = await db.query('SELECT COUNT(*) FROM users');
    const totalUsers = parseInt(countResult.rows[0].count);

    // Get users with pagination
    const result = await db.query(`
      SELECT u.id, u.email, u.name, u.admin, u.active, u.quota, u.created_at, u.last_login,
             d.domain, qu.bytes_used, qu.message_count
      FROM users u
      LEFT JOIN domains d ON u.domain_id = d.id
      LEFT JOIN quota_usage qu ON u.id = qu.user_id
      ORDER BY u.created_at DESC
      LIMIT $1 OFFSET $2
    `, [limit, offset]);

    const users = result.rows.map(user => ({
      id: user.id,
      email: user.email,
      name: user.name,
      domain: user.domain,
      admin: user.admin,
      active: user.active,
      quota: {
        limit: user.quota,
        used: user.bytes_used || 0,
        messageCount: user.message_count || 0,
        percentage: user.quota > 0 ? Math.round((user.bytes_used || 0) / user.quota * 100) : 0
      },
      createdAt: user.created_at,
      lastLogin: user.last_login
    }));

    res.json({
      users,
      pagination: {
        page,
        limit,
        total: totalUsers,
        pages: Math.ceil(totalUsers / limit)
      }
    });

  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get single user
router.get('/:id', async (req, res) => {
  try {
    const db = req.app.locals.db;
    const userId = parseInt(req.params.id);

    // Check permissions - admin or owner
    if (!req.user.admin && req.user.userId !== userId) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    const result = await db.query(`
      SELECT u.id, u.email, u.name, u.admin, u.active, u.quota, u.created_at, u.last_login,
             d.domain, qu.bytes_used, qu.message_count
      FROM users u
      LEFT JOIN domains d ON u.domain_id = d.id
      LEFT JOIN quota_usage qu ON u.id = qu.user_id
      WHERE u.id = $1
    `, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = result.rows[0];

    res.json({
      id: user.id,
      email: user.email,
      name: user.name,
      domain: user.domain,
      admin: user.admin,
      active: user.active,
      quota: {
        limit: user.quota,
        used: user.bytes_used || 0,
        messageCount: user.message_count || 0,
        percentage: user.quota > 0 ? Math.round((user.bytes_used || 0) / user.quota * 100) : 0
      },
      createdAt: user.created_at,
      lastLogin: user.last_login
    });

  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new user (admin only)
router.post('/', requireAdmin, async (req, res) => {
  try {
    const { error, value } = createUserSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { email, password, name, quota, admin, active } = value;
    const db = req.app.locals.db;

    // Check if email already exists
    const existingUser = await db.query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    // Get domain ID from email
    const domain = email.split('@')[1];
    const domainResult = await db.query('SELECT id FROM domains WHERE domain = $1', [domain]);
    if (domainResult.rows.length === 0) {
      return res.status(400).json({ error: 'Domain not found' });
    }

    // Hash password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Insert user
    const result = await db.query(`
      INSERT INTO users (email, password, name, domain_id, quota, admin, active)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id, email, name, admin, active, quota, created_at
    `, [email.toLowerCase(), hashedPassword, name, domainResult.rows[0].id, quota, admin, active]);

    const newUser = result.rows[0];

    // Create quota usage record
    await db.query(
      'INSERT INTO quota_usage (user_id, bytes_used, message_count) VALUES ($1, 0, 0)',
      [newUser.id]
    );

    res.status(201).json({
      id: newUser.id,
      email: newUser.email,
      name: newUser.name,
      admin: newUser.admin,
      active: newUser.active,
      quota: {
        limit: newUser.quota,
        used: 0,
        messageCount: 0,
        percentage: 0
      },
      createdAt: newUser.created_at
    });

  } catch (error) {
    console.error('Create user error:', error);
    if (error.code === '23505') { // Unique violation
      return res.status(400).json({ error: 'Email already exists' });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update user
router.put('/:id', async (req, res) => {
  try {
    const userId = parseInt(req.params.id);

    // Check permissions
    if (!req.user.admin && req.user.userId !== userId) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    const { error, value } = updateUserSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const db = req.app.locals.db;

    // Check if user exists
    const existingUser = await db.query('SELECT id, admin FROM users WHERE id = $1', [userId]);
    if (existingUser.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Non-admin users can't modify admin status
    if (!req.user.admin && 'admin' in value) {
      delete value.admin;
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
    values.push(userId);

    const result = await db.query(`
      UPDATE users
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING id, email, name, admin, active, quota, updated_at
    `, values);

    const updatedUser = result.rows[0];

    res.json({
      id: updatedUser.id,
      email: updatedUser.email,
      name: updatedUser.name,
      admin: updatedUser.admin,
      active: updatedUser.active,
      quota: updatedUser.quota,
      updatedAt: updatedUser.updated_at
    });

  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete user (admin only)
router.delete('/:id', requireAdmin, async (req, res) => {
  try {
    const userId = parseInt(req.params.id);
    const db = req.app.locals.db;

    // Prevent deleting self
    if (req.user.userId === userId) {
      return res.status(400).json({ error: 'Cannot delete your own account' });
    }

    const result = await db.query('DELETE FROM users WHERE id = $1 RETURNING email', [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ message: `User ${result.rows[0].email} deleted successfully` });

  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
