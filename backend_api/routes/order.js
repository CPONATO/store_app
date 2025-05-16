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

orderRouter.get('/api/orders/:buyerId',async(req,res)=>{
    try {
        const{buyerId} = req.params;
        const orders= await Order.find({buyerId});

        if(orders.length==0){
            return res.status(404).json({msg:"User Has No Oder"});
        }
        return res.status(200).json(orders);
    } catch (e) {
        res.status(500).json({error:e.message});
    }
});
orderRouter.delete('/api/orders/:id',async(req,res)=>{
    try {
        //the id in here is equal to _id in mongooseDB
        const {id} = req.params;
        const deletedOrder= await Order.findByIdAndDelete(id);
        if(!deletedOrder){
            return res.status(404).json({msg:"Order not found"})
        }
        return res.status(200).json({msg:"Order deleted"});

    } catch (e) {
        res.status(500).json({error:e.message});
    }
});


orderRouter.get('/api/orders/vendors/:vendorId',async(req,res)=>{
    try {
        const{vendorId} = req.params;
        const orders= await Order.find({vendorId});

        if(orders.length==0){
            return res.status(404).json({msg:"Vendor Has No Oder"});
        }
        return res.status(200).json(orders);
    } catch (e) {
        res.status(500).json({error:e.message});
    }
});

orderRouter.patch('/api/orders/:id/delivered',async(req,res)=>{
    try {
        const{id} = req.params;
        const updatedOrder= await Order.findByIdAndUpdate(id,{delivered:true},{new:true});

        if(!updatedOrder){
            return res.status(404).json({msg:"Order not found"})
        }else{
            return res.status(200).json(updatedOrder)
        }

    } catch (e) {
        res.status(500).json({error:e.message});
    }
});

orderRouter.patch('/api/orders/:id/processing', async(req, res) => {
    try {
        const { id } = req.params;
        const { processing } = req.body; 
        
        const updatedOrder = await Order.findByIdAndUpdate(
            id,
            { processing },  
            { new: true }
        );

        if(!updatedOrder) {
            return res.status(404).json({ msg: "Order not found" });
        } else {
            return res.status(200).json(updatedOrder);
        }

    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = orderRouter;