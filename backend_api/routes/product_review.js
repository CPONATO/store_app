const express = require('express');
const ProductReview = require('../models/product_review');
const Product = require('../models/product');
const productReviewRouter = express.Router();

productReviewRouter.post('/api/review', async (req, res)=> {
    try {
        const {buyerId, email, fullName, productId, rating, review,} = req.body;
        
        // Thêm log để kiểm tra
        console.log(`Processing review for product ID: ${productId}`);
        
        const existingReview = await ProductReview.findOne({buyerId, productId});
        if(existingReview){
            return res.status(400).json({msg:"You have already reviewed this product"});
        }
        
        // Tìm sản phẩm trước khi tạo đánh giá
        const product = await Product.findById(productId);
        if(!product){
            console.error(`Product not found with ID: ${productId}`);
            return res.status(404).json({msg:`Product not found with ID: ${productId}`});
        }
        
        // Tạo đánh giá khi đã xác nhận sản phẩm tồn tại
        const reviews = new ProductReview({buyerId, email, fullName, productId, rating, review});
        await reviews.save();
        
        // Cập nhật rating
        console.log(`Before update: totalRating=${product.totalRating}, averageRating=${product.averageRating}`);
        product.totalRating += 1;
        product.averageRating = ((product.averageRating * (product.totalRating - 1)) + rating) / product.totalRating;
        await product.save();
        console.log(`After update: totalRating=${product.totalRating}, averageRating=${product.averageRating}`);
        
        return res.status(200).send(reviews);
    } catch (e) {
        console.error(`Error in review API: ${e.message}`);
        res.status(500).json({error: e.message});
    }
});

module.exports = productReviewRouter;