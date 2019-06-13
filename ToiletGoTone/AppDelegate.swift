//
//  AppDelegate.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import EasyAnimation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
        
        AMapServices.shared()?.apiKey = ThirdVenderKey.amapApiKey
        AMapServices.shared().enableHTTPS = true
        
        AVOSCloud.setApplicationId(ThirdVenderKey.leanCloudId, clientKey: ThirdVenderKey.leanCloudClentKey)
        
        EasyAnimation.enable()
        
        return true
    }
}

