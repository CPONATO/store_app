const express = require('express');
const Product = require('../models/product');
const productRouter = express.Router();

productRouter.post('/api/add-product', async (req, res) => {
  try {
    console.log('Received body:', req.body); // Log dữ liệu nhận được
    const { productName, productPrice, quantity, description, category, subCategory, images, vendorId, fullName } = req.body;

    // Kiểm tra dữ liệu đầu vào
    if (!productName || !productPrice || !quantity || !description || !category || !subCategory || !images || !vendorId || !fullName) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const product = new Product({ productName, productPrice, quantity, description, category, subCategory, images, vendorId, fullName });
    await product.save();
    return res.status(201).send(product);
  } catch (e) {
    console.error('Error saving product:', e.message); // Log lỗi
    res.status(500).json({ error: e.message });
  }
});

productRouter.get('/api/popular-product', async(req,res)=>{
    try {
        const product = await Product.find({popular:true})
        if(!product||product.length==0){
            return res.status(400).json({msg:"product not found"});
        }else{
            return res.status(200).json(product);
        }
    } catch (e) {
        res.status(500).json({error:e.msg});
    }
})
productRouter.get('/api/recommend-product', async(req,res)=>{
    try {
        const product = await Product.find({recommend:true})
        if(!product||product.length==0){
            return res.status(400).json({msg:"product not found"});
        }else{
            return res.status(200).json(product);
        }
    } catch (e) {
        res.status(500).json({error:e.msg});
    }
})
productRouter.get('/api/products-by-category/:category', async(req,res)=>{
    try {
        const{category} = req.params;
        const products= await Product.find({category,popular:true});
        if(!products || products.length==0){
            return res.status(404).json({msg:"Product Not Found"});
        }else{
            return res.status(200).json(products);
        }
    } catch (e) {
        res.status(500).json({error:e.message});
    }
})

module.exports = productRouter;