const jwt = require('jsonwebtoken');
const User = require('../models/user');
const Vendor = require('../models/vendor');


//check if user is authenticated or not

const auth = async(req,res,next)=>{
    try {
        //extract token from request headers


        const token = req.headear('x-auth-token');
        //if no token

        if(!token) return res.status(401).json({msg:'No authentication token, authorization denied'});

        //verify jwt token by secret key
        const verified = jwt.verified(token,'passwordKey');

        //if token not verified

        if(!verified) return res.status(401).json({msg:'Token verifucation failed, authorization denied'});

        //find user or vendor in database by id in token payload
        //this id = _id in mongooseDb
        const user = await User.findById(verified.id) || await Vendor.findById(verified.id);

        if(!user) return res.status(401).json({msg:"User or Vendor not found, authorization denied"});

        req.user = user;
        
        req.token = token;
        next();
    } catch (e) {
        res.status(500).json({error:e.message});
    }
};


//vendor authentication middleware

//ensure the user makin request is vendor, only vendor can access

const vendorAuth = (req,res,next)=>{
try {
    
    //if user makin request is vendor or not (by "role")

    if(!req.user.role || req.user.role!=="vendor"){
        //if user is not vendor 
        return res.status(403).json({msg:"Access denied, only vendors are allowed"});
    }
    // if user is vender, then procced to next middleware
    next();
} catch (e) {
    return res.status(500).json({error:e.message});
}
};

module.exports={auth,vendorAuth};