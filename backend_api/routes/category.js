const express = require('express');
const Category = require('../models/category');

const categoryRouter = express.Router();

categoryRouter.post('/api/categories', async (req, res)=> {
    try {
        const{name, image, banner} = req.body;
        const category = new Category({name, image, banner});
        await category.save();
        res.status(200).send(category);
    } catch (e) {
        res.status(500).json({error:e.msg});
    }
});
categoryRouter.get('/api/categories', async(req, res) =>{
    try {
        const categories = await Category.find();
        res.status(200).json(categories);
    } catch (e) {
        res.status(500).json({error:e.msg});
    }
})
module.exports = categoryRouter;