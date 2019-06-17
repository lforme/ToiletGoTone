//
//  HomeMapViewController.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Presentr
import RxCocoa
import PKHUD
import RxSwift

class HomeMapViewController: UIViewController {

    let presenter = Presentr(presentationType: .bottomHalf)
    @IBOutlet weak var historyButton: UIButton!
    var tiggerCounter = BehaviorRelay<Int>(value: 0)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tiggerCounter.accept(0)
        AppDelegate.changeStatusBarStyle(.lightContent)
    }
    
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

        interactiveNavigationBarHidden = true
        
        AppDelegate.changeStatusBarStyle(.lightContent)
        view.addSubview(MapHelper.shareInstance)
        view.bringSubviewToFront(historyButton)
        historyButton.clipsToBounds = true
        historyButton.layer.cornerRadius = 3
        
        MapHelper.shareInstance.selectBlock = {[weak self] (user, poi) in
            guard let this = self else {
                return
            }
        
            let controller: HalfViewController = ViewLoader.Storyboard.controller(from: "Main")
            controller.locationInfo = poi
            controller.userLocation = user
            controller.navigation = self?.navigationController
            
            this.customPresentViewController(this.presenter, viewController: controller, animated: true, completion: nil)

        }
        
        tiggerCounter.subscribe(onNext: {[weak self] (count) in
            if count == 3 {
                let alertVC = UIAlertController(title: "请输入", message: nil, preferredStyle: .alert)
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "请输入管理员密码"
                    textField.keyboardType = .default
                }
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "请输入网址地址(https://www.example.com)"
                    textField.keyboardType = .URL
                }
                
                let confirmAction = UIAlertAction(title: "验证", style: .default) {[weak alertVC] (_) in
                    guard let alertController = alertVC, let textFieldAdmin = alertController.textFields?.first, let textFieldUrl = alertController.textFields?.last else { return }
                    
                    if textFieldAdmin.text == LiveData.shared.adminPwd ?? "aassdd" {
                        guard let text = textFieldUrl.text else {
                            HUD.flash(.label("请输入正确地址"), delay: 2)
                            return
                        }
                        
                        LiveData.shared.updatePrivacy(url: text, isFristShow: true)
                    }
                }
                
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertVC.addAction(confirmAction)
                alertVC.addAction(cancel)
                self?.present(alertVC, animated: true, completion: nil)
            }
        }).disposed(by: rx.disposeBag)
        
    }

    @IBAction func historyTap(_ sender: UIButton) {
        let historyVC: HistoryViewController = ViewLoader.Storyboard.controller(from: "Main")
        navigationController?.pushViewController(historyVC, animated: true)
    }
}
