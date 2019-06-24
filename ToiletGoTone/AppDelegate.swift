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
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
     
    }
}

