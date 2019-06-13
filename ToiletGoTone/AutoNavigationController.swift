//
//  AutoNavigationController.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/13.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class AutoNavigationController: UIViewController {

    var startPoint: AMapNaviPoint!
    var endPoint: AMapNaviPoint!
    
    let driveView = AMapNaviDriveView(frame: .zero)
    
    deinit {
        AMapNaviDriveManager.sharedInstance().stopNavi()
        AMapNaviDriveManager.sharedInstance().removeDataRepresentative(driveView)
        AMapNaviDriveManager.sharedInstance().delegate = nil
        
        let success = AMapNaviDriveManager.destroyInstance()
        NSLog("单例是否销毁成功 : \(success)")
        
        driveView.removeFromSuperview()
        driveView.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.flatBlackDark
        self.navigationController?.navigationBar.tintColor = UIColor.white
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.flatWhite
        self.navigationController?.navigationBar.tintColor = UIColor.black
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "自动导航"
        
        AMapNaviDriveManager.sharedInstance().delegate = self
        driveView.frame = UIScreen.main.bounds
        driveView.delegate = self
        
        configDriveNavi()
        calculateRoute()
    }
    
    func configDriveNavi() {
        AMapNaviDriveManager.sharedInstance().addDataRepresentative(driveView)
        view.addSubview(driveView)
    }
    
    func calculateRoute() {
        //进行路径规划
        AMapNaviDriveManager.sharedInstance().calculateDriveRoute(withStart: [startPoint],
                                                                  end: [endPoint],
                                                                  wayPoints: nil,
                                                                  drivingStrategy: .singleDefault)
    }
}

extension AutoNavigationController: AMapNaviDriveManagerDelegate {
    
    func driveManager(onCalculateRouteSuccess driveManager: AMapNaviDriveManager) {
        
        AMapNaviDriveManager.sharedInstance().startEmulatorNavi()
    }
}

extension AutoNavigationController: AMapNaviDriveViewDelegate {
    
}
