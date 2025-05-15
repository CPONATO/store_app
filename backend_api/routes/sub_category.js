const express = require('express');
const SubCategory = require('../models/sub_category');
const subCategoryRouter = express.Router();

subCategoryRouter.post('/api/subcategories',async(req, res)=>{
    try {
        const{categoryId,categoryName, image, subCategoryName} = req.body;
        const subCategory =  new SubCategory ({categoryId,categoryName, image, subCategoryName});
        await subCategory.save();
        res.status(200).send(subCategory);
    } catch (e) {
        console.error(e);
        res.status(500).json({error:e.msg});
    }
});

subCategoryRouter.get('/api/subcategories',async(req,res)=>{
    try {
        const subcategories = await SubCategory.find();
        return res.status(200).json(subcategories);
    } catch (e) {
        console.error(e);
        res.status(500).json({error:e.msg});
    }
})

subCategoryRouter.get('/api/category/:categoryName/subcategory', async(req,res)=>{
    try {
        ///extract the categoryName from the request url using destructureing
        const{categoryName} = req.params;

        const subcategories = await SubCategory.find({categoryName:categoryName});
        //check if any sub category were found
        if(!subcategories|| subcategories.length ==0){
            //if no category found response 404 code error
            return res.status(404).json({msg:'subcategory not found'});
        }else{
            return res.status(200).json(subcategories);
        }
    } catch (e) {
        console.error(e);
        res.status(500).json({error:e.msg});
    }
});

module.exports = subCategoryRouter;