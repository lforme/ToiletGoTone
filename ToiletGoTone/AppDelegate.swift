//
//  AppDelegate.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import EasyAnimation
import AVFoundation
import RxSwift
import RxCocoa
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var player: AVAudioPlayer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        AMapServices.shared()?.apiKey = ThirdVenderKey.amapApiKey
        AMapServices.shared().enableHTTPS = true
        
        AVOSCloud.setServerURLString("https://avoscloud.com", for: AVServiceModule.API)
        AVOSCloud.setServerURLString("https://avoscloud.com", for: AVServiceModule.engine)
        AVOSCloud.setServerURLString("https://avoscloud.com", for: AVServiceModule.push)
        AVOSCloud.setServerURLString("https://avoscloud.com", for: AVServiceModule.RTM)
        AVOSCloud.setApplicationId(ThirdVenderKey.leanCloudId, clientKey: ThirdVenderKey.leanCloudClentKey)
        
        EasyAnimation.enable()
        
        playSound()
        observeMusicPlayStatus()
        
        let jpEntity = JPUSHRegisterEntity()
        jpEntity.types = Int(UInt8(JPAuthorizationOptions.alert.rawValue) | UInt8(JPAuthorizationOptions.badge.rawValue) | UInt8(JPAuthorizationOptions.sound.rawValue))
        JPUSHService.register(forRemoteNotificationConfig: jpEntity, delegate: self)
        #if DEBUG
        JPUSHService.setup(withOption: launchOptions, appKey: "8672e1af605a706f678bfbf1", channel: "iOS", apsForProduction: false)
        #else
        JPUSHService.setup(withOption: launchOptions, appKey: "8672e1af605a706f678bfbf1", channel: "iOS", apsForProduction: true)
        #endif
        
        return true
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "Still-D-R-E", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            player.play()
            player.numberOfLoops = -1
            if let played = Storage.load(key: "music") as? Bool {
                if played {
                    player.play()
                } else {
                    player.stop()
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func observeMusicPlayStatus() {
        NotificationCenter.default.rx.notification(.statuMusicDidChange)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (noti) in
                guard let isOn = noti.object as? Bool else {
                    return
                }
                if isOn {
                    self?.player?.play()
                } else {
                    self?.player?.stop()
                }
                
            }).disposed(by: rx.disposeBag)
    }
}


// MARK: - JPUSHRegisterDelegate
extension AppDelegate: JPUSHRegisterDelegate {
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("推送设备注册失败: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        let userInfo = notification.request.content.userInfo
        print(userInfo.description)
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            let invalidLogin = userInfo["Type"] as? String
            if let invalidLogin = invalidLogin, invalidLogin == "1" {
                
            }
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
