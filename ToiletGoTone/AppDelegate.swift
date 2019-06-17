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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var player: AVAudioPlayer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
        
        AMapServices.shared()?.apiKey = ThirdVenderKey.amapApiKey
        AMapServices.shared().enableHTTPS = true
        
        AVOSCloud.setApplicationId(ThirdVenderKey.leanCloudId, clientKey: ThirdVenderKey.leanCloudClentKey)
        
        EasyAnimation.enable()
        
        playSound()
            
        return true
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "Still-D-R-E", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            player.numberOfLoops = -1
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

