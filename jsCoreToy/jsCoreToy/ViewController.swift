//
//  ViewController.swift
//  jsCoreToy
//
//  Created by 李杰駿 on 2021/9/12.
//  Copyright © 2021 李杰駿. All rights reserved.
//

import UIKit
import SnapKit
import JJJSBridge
import Alamofire

class ViewController: UIViewController {
    let bzModel : BzModel = BzModel()
    let mainProdInput : InputComponent = {
        var _input = InputComponent(title: "MainProd cost : ", frame: .zero)
        return _input
    }()
    let mainProdIdInput : InputComponent = {
        var _input = InputComponent(title: "MainProd ID : ", frame: .zero)
        return _input
    }()
    let secProdInput : InputComponent = {
        var _input = InputComponent(title: "secProd cost : ", frame: .zero)
        return _input
    }()
    let secProdIdInput : InputComponent = {
        var _input = InputComponent(title: "secProd cost ID : ", frame: .zero)
        return _input
    }()
    let resultLabel : UILabel = {
        let _lbl = UILabel()
        _lbl.textColor = .black
        _lbl.text = "0"
        _lbl.textAlignment = .center
        return _lbl
    }()
    lazy var calcualteButton : UIButton = {
        var _btn = ConvButton(action: { [weak self](btn) in
//************* Calculate Here
            
            let cost = self?.bzModel.getCost(
                mainProductID:self?.mainProdIdInput.getText() ?? "KKday",
                mainCost:Int(self?.mainProdInput.getText() ?? "0") ?? 0,
                secProdroductID:self?.secProdIdInput.getText() ?? "KKday",
                secCost:Int(self?.secProdInput.getText() ?? "0") ?? 0)
            
//************** Calculate Here
            self?.resultLabel.text = "\(cost ?? 0)"
            
        })
        _btn.setTitle("計算Cost", for: .normal)
        _btn.backgroundColor = .lightGray
        _btn.setTitleColor(.white ,for: .normal)
        return _btn
    }()
    lazy var refreshButton : UIButton = {
        var _btn = ConvButton (action:{ [weak self](btn) in
            self?.calcualteButton.backgroundColor = .lightGray
            self?.bzModel.fetch({isSuccess in
                if isSuccess {
                    self?.calcualteButton.backgroundColor = .darkGray
                }
            })
        })
        _btn.setTitle("重抓函式", for: .normal)
        _btn.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        _btn.setTitleColor(.white ,for: .normal)
        return _btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configComponents()
        bzModel.fetch({
                [weak self]isSuccess in
                if isSuccess {
                    self?.calcualteButton.backgroundColor = .darkGray
                }
            })
    }
    
    //components
    private func configComponents() {
        let stack : UIStackView = UIStackView(arrangedSubviews: [mainProdIdInput,mainProdInput,secProdIdInput,secProdInput,resultLabel, calcualteButton,refreshButton])
        stack.axis = .vertical
        stack.spacing = 10
        self.view.addSubview(stack)
        
        resultLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        calcualteButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
        refreshButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
        stack.snp.makeConstraints { (make) in
            make.width.equalTo(300)
            make.center.equalToSuperview()
        }
    }

}




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
