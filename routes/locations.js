const express = require('express');
const router = express.Router();
const { query } = require('../database/connection');
const { authenticateToken } = require('../middleware/auth');

// GET ALL
router.get('/', authenticateToken, async (req, res) => {
  try {
    const result = await query('SELECT * FROM locations ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch locations' });
  }
});

// CREATE
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { name, address, latitude, longitude, radius } = req.body;

    const result = await query(`
      INSERT INTO locations (name, address, latitude, longitude, radius)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `, [name, address, latitude, longitude, radius || 100]);

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Create failed' });
  }
});

// UPDATE
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { name, address, latitude, longitude, radius } = req.body;

    const result = await query(`
      UPDATE locations
      SET name=$1, address=$2, latitude=$3, longitude=$4, radius=$5
      WHERE id=$6
      RETURNING *
    `, [name, address, latitude, longitude, radius || 100, req.params.id]);

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Update failed' });
  }
});

// DELETE
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    await query('DELETE FROM locations WHERE id=$1', [req.params.id]);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Delete failed' });
  }
});

module.exports = router;