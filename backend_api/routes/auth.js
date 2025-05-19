const express = require("express");
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require("../models/user");


const authRouter = express.Router();

authRouter.post('/api/signup', async(req, res) => {
   try{
      const { fullName, email, password } = req.body;
  
      const existingEmail  = await  User.findOne({email});
      if(existingEmail){
          return res.status(400).json({msg: ' user same email alruseready exits'});
  
      }else{
          const salt = await bcrypt.genSalt(10);
          const hashedPassword = await bcrypt.hash(password,salt);
          let user = new User({fullName, email,password:hashedPassword});
          user= await user.save();
          res.json({user});
      }
     }catch(e){
        console.error(e);
        res.status(500).json({ error:  e.message});
     }
  });


authRouter.post('/api/signin', async (req, res) => {
   try {
    const { email, password } = req.body;
    const findUser = await User.findOne({ email });
    if (!findUser) {
      return res.status(400).json({ msg: "User not found with this email" });
    } else {
       const isMatch = await bcrypt.compare(password, findUser.password);
       if (!isMatch) {
         return res.status(400).json({ msg: "Incorrect Password" });
       } else {
         const token = jwt.sign({ id: findUser._id }, "passwordKey");
         const {password, ...userWithoutPassword} = findUser._doc;
         res.json({token,user:userWithoutPassword});
       }
    }
   } catch(e) {
      console.log(req.body);
      res.status(500).json({ error: e.message });
   }
});


authRouter.put('/api/users/:id',async(req,res)=>{
   try {
      const {id} =req.params;
      const {state,city,locality} = req.body;
      const updatedUser = await User.findByIdAndUpdate(
         id,{state,city,locality},{new:true},
      );
      if(!updatedUser){
         return res.status(404).json({error:"User not found"});
      }else{
         return res.status(200).json(updatedUser);

      }
   } catch (e) {
      console.log(req.body);
      res.status(500).json({ error: e.message });
   }
});

authRouter.get('/api/users',async(req,res)=>{
   try {
      const users= await User.find().select('-password');//get all field except password
      return res.status(200).json(users);

   } catch (e) {
      console.log(req.body);
      res.status(500).json({ error: e.message });
   }
});


module.exports = authRouter;