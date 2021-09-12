//
//  BzModel.swift
//  jsCoreToy
//
//  Created by 李杰駿 on 2021/9/12.
//  Copyright © 2021 李杰駿. All rights reserved.
//

import UIKit
import JJJSBridge
import Alamofire

class BzModel {
    let worker : JJJSWorker = {
        var _worker = JJJSWorker(wokerId: "coster")
        return _worker
    }()
    private var js = """
        function costCal(mainProductID, mainCost, secProdroductID, secCost) {
            let cost = mainCost + secCost;
            if (mainProductID.substr(0,2) == secProdroductID.substr(0,2)) {
                cost *= 0.8;
            }
            return cost;
        }
    """
    
    private var readyCallback : ((Bool)->Void)?
    
    func fetch(_ callback : @escaping(Bool)->Void) {
        readyCallback = callback
        fetchFunc()
    }
    
    func configJS() {
        self.worker.evaluateJS(js)
    }
    
    func fetchFunc() {
        Alamofire.AF.request("http://192.168.0.184:3500/api/calculaterCost").responseJSON { [weak self](response) in
            guard let responseData = response.data else {
                self?.readyCallback?(false)
                return
            }
            guard let resultObj = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String:Any] else {
                self?.readyCallback?(false)
                return
            }
            guard let jsFunction = resultObj["costFunction"] as? String else{
                self?.readyCallback?(false)
                return
            }
            self?.js = jsFunction
            self?.configJS()
            self?.readyCallback?(true)
        }
    }
    
    func getCost(mainProductID:String, mainCost:Int, secProdroductID:String, secCost:Int)->Double? {
        return worker.callJSFunction("costCal", with: [mainProductID,mainCost,secProdroductID,secCost])?.toDouble()
    }
}
