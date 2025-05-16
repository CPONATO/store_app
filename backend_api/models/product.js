const mongoose = require('mongoose');
const SubCategory = require('./sub_category');

const productSchema = new mongoose.Schema({
  productName: { type: String, required: true },
  productPrice: { type: Number, required: true },
  quantity: { type: Number, required: true },
  description: { type: String, required: true },
  category: { type: String, required: true },
  subCategory: { type: String, required: true },
  images: { type: [String], default: [] },
  vendorId: { type: String, required: true },
  fullName: { type: String, required: true },
  popular: { type: Boolean, default: false },
  recommend: { type: Boolean, default: false },
  averageRating:{type:Number,default:0},
  totalRating:{type:Number,default:0}
});
const Product = mongoose.model("Product", productSchema);

module.exports = Product;