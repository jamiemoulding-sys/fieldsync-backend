const express = require('express');
const router = express.Router();
const { sendInviteEmail } = require('../services/emailService');

// ✅ SEND INVITE EMAIL
router.post('/send-invite', async (req, res) => {
  try {
    const { email, name, token } = req.body;

    if (!email || !token) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    await sendInviteEmail({ email, name, token });

    console.log('📨 Invite sent:', email);

    res.json({ success: true });

  } catch (err) {
    console.error('❌ Invite error:', err);
    res.status(500).json({ error: 'Failed to send invite' });
  }
});

module.exports = router;