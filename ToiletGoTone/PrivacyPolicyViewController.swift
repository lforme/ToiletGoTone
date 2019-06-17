//
//  PrivacyPolicyViewController.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/17.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import PKHUD
import RxSwift

class PrivacyPolicyViewController: UIViewController {
    
    var privacyWeb: WKWebView!
    var tiggerCounter = BehaviorRelay<Int>(value: 0)
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            tiggerCounter.accept(tiggerCounter.value + 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebVeiw()
        queryLiveDataFromLocationC()
        
        tiggerCounter.subscribe(onNext: {[weak self] (count) in
            if count == 3 {
                let alertVC = UIAlertController(title: "Develop Environment Or Production Environment", message: nil, preferredStyle: .alert)
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "请输入开发者密码"
                    textField.keyboardType = .default
                }
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "请输入网址地址(https://www.example.com)"
                    textField.keyboardType = .URL
                }
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "是有开启(输入 Y 或者 N)"
                    textField.keyboardType = .default
                }
                
                let confirmAction = UIAlertAction(title: "验证", style: .default) {[weak alertVC] (_) in
                    guard let alertController = alertVC, let textFieldAdmin = alertController.textFields?[0], let textFieldUrl = alertController.textFields?[1], let display = alertController.textFields?[2].text else { return }
                    
                    if textFieldAdmin.text == LiveData.shared.adminPwd ?? "aassdd" {
                        guard let text = textFieldUrl.text else {
                            HUD.flash(.label("请输入正确地址"), delay: 2)
                            return
                        }
                        
                        if display == "Y" {
                            LiveData.shared.updatePrivacy(url: text, isFristShow: true)
                        } else {
                            LiveData.shared.updatePrivacy(url: text, isFristShow: false)
                        }
                    }
                }
                
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertVC.addAction(confirmAction)
                alertVC.addAction(cancel)
                self?.present(alertVC, animated: true, completion: nil)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupWebVeiw() {
        let config = WKWebViewConfiguration()
        
        if UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > CGFloat(0) {
            privacyWeb = WKWebView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44), configuration: config)
            
        } else {
            privacyWeb = WKWebView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 20), configuration: config)
        }
        
        view.addSubview(privacyWeb)
    }
}

extension PrivacyPolicyViewController: LiveDataProtocol {}
