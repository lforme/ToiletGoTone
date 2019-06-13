//
//  ViewController.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import PKHUD
import SnapKit

class RootViewController: UIViewController {

    fileprivate var _statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var baseNavigationVC: BaseNavigationController!
    var homeVC: HomeMapViewController?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self._statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
        
        setupViewControllers()
        
        let _ = MapHelper.shareInstance
        
        AVUser.loginAnonymously { (user, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                print(user ?? "")
            }
        }
    }
    
    func addObservers() {
        NotificationCenter.default.rx.notification(.statuBarDidChnage)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (noti) in
                if let style = noti.object as? UIStatusBarStyle {
                    self?._statusBarStyle = style
                }
            }).disposed(by: rx.disposeBag)
    }
    
    func setupViewControllers() {
        let temp: HomeMapViewController = ViewLoader.Storyboard.controller(from: "Main")
        self.homeVC = temp
        
        baseNavigationVC = BaseNavigationController(rootViewController: temp)
        
        view.addSubview(baseNavigationVC.view)
        baseNavigationVC.view.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self.view)
        }
        self.addChild(baseNavigationVC)
    }
}

