
// 1. 讀取json數據
// let calculaterCost = require('./CostCalculater.js');
const fs = require("fs");

// __dirname means relative to script. Use "./data.txt" if you want it relative to execution path.


// 2. router
const express = require('express');
const app = express();
var routes = express.Router();

// 3. API
routes.get('/calculaterCost', (req,res)=>{
    //load file
    fs.readFile(__dirname + "/CostCalculater.js", (error, data) => {
        if(error) {
            throw error;
        }
        //send back data
        let calFunctionStr = data.toString();
        let obj = {
            "costFunction" : calFunctionStr
        }
        res.json(obj);
    });
});

// 4. 中間件
app.use('/api',routes);

console.log('app listening at port 3500...');
app.listen(3500);