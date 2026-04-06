const express = require('express');
const router = express.Router();
const Stripe = require('stripe');

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

const { authenticateToken } = require('../middleware/auth');

router.post('/create-checkout-session', authenticateToken, async (req, res) => {
  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'subscription',

      line_items: [
        {
          price_data: {
            currency: 'gbp',
            product_data: {
              name: 'FieldSync Pro',
            },
            unit_amount: 600, // £6
            recurring: {
              interval: 'month',
            },
          },
          quantity: 1,
        },
      ],

      success_url: 'http://localhost:3000/success',
      cancel_url: 'http://localhost:3000/dashboard',
    });

    res.json({ url: session.url });

  } catch (err) {
    console.error('STRIPE ERROR:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;