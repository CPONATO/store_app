const express = require('express');
const Order = require('../models/order');

const orderRouter = express.Router();

orderRouter.post('/api/orders',async(req,res)=>{
    try {
        const {fullName, email,state,city,locality, productName,productPrice,quantity,category,image,buyerId,vendorId}= req.body;
        const createdAt = new Date().getTime();

        const order = new Order({fullName, email,state,city,locality, productName,productPrice,quantity,category,image,buyerId,vendorId,createdAt});
        await order.save();
        return res.status(201).json(order)
    } catch (e) {
        res.status(500).json({error:e.message});
    }
});
module.exports = orderRouter;