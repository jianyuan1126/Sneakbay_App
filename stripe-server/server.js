const express = require('express');
const stripe = require('stripe')('sk_test_51PJTeIDpKg8wlVpqv5Iaf5L6FIUeliM5XPIEgVEVdouEUV4Ip8h1sYM0lTAs5zlXwR3Mgye9ckFyuTvVqshJXFxP00zNSZPIh8');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(cors());

app.post('/create-payment-intent', async (req, res) => {
  const { amount, shipping } = req.body;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: 'myr', 
      shipping,
    });

    res.status(200).send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    res.status(400).send({
      error: error.message,
    });
  }
});

const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0';  
app.listen(PORT, HOST, () => {
  console.log(`Server is running on port ${PORT}`);
});
