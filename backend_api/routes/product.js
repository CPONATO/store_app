const express = require('express');
const Product = require('../models/product');
const productRouter = express.Router();
const {auth,vendorAuth} = require('../middleware/auth');


productRouter.post('/api/add-product',auth,vendorAuth, async (req, res) => {
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
});
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
});
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
});

productRouter.get('/api/related-products-by-subcategory/:productId',async(req,res)=>{
    try {
        const {productId} = req.params;
        //find the product to get its subcategory
        const product = await Product.findById(productId);
        if(!product){
            return res.status(404).json({msg:"product not found"});
        }else{
            //find related product base on subcategory
            const relatedProduct = await Product.find({
                subCategory:product.subCategory,
                _id:{$ne:productId}//Exclude the current product
            });
            if(!relatedProduct || relatedProduct.length==0){
                return res.status(404).json({msg:"Related product not found"})
            }
            return res.status(200).json(relatedProduct);
        }
    } catch (e) {
    res.status(500).json({error:e.message});

    }
});

productRouter.get('/api/top-rated-products',async(req,res)=>{
    try {
        const topRatedProduct =  await Product.find({}).sort({averageRating:-1}).limit(10);//sort product by averageRating wiht -1 indicating decending with limit is top 10
    
        //check if there are any top rated product
        if(!topRatedProduct ||topRatedProduct.length==0){
            return res.status(404).json({msg:"No Top Rated Product found"});
        }
        return res.status(200).json(topRatedProduct);
    } catch (e) {
        res.status(500).json({error:e.message});

    }
});

module.exports = productRouter;