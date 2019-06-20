//
//  SettingViewController.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import StoreKit

class SettingViewController: UITableViewController {
    
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "设置"
        tableView.tableFooterView = UIView(frame: .zero)
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "版本\(version)"
        }
        
        bindRx()
        checkAndAskForReview()
    }
    
    func bindRx() {
        let musicIsOn = Storage.load(key: "music") as? Bool
        musicSwitch.isOn = musicIsOn ?? true
        
        musicSwitch.rx.isOn.subscribe(onNext: { (isOn) in
            Storage.save(key: "music", value: isOn)
            NotificationCenter.default.post(name: .statuMusicDidChange, object: isOn)
        }).disposed(by: rx.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 8 : CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            showActionSheet(title: "确定要删除历史搜藏吗?", message: nil, buttonTitles: ["删除", "取消"], highlightedButtonIndex: 1) { (index) in
                if index == 0 {
                    guard let userId = AVUser.current()?.objectId else { return }
                    let query = AVQuery(className: DatabaseKey.favoriteToilet)
                    query.whereKey("userId", equalTo: userId)
                    if let objs = query.findObjects() as? [AVObject] {
                        AVObject.deleteAll(inBackground: objs, block: { (_, _) in
                            
                        })
                    }
                }
            }
        }
    }
}


extension SettingViewController {
    
    private func requestReview() {
        SKStoreReviewController.requestReview()
    }
    
    fileprivate func checkAndAskForReview() {
        
        guard let appOpenCount = Storage.load(key: "AppOpenCount") as? Int else {
            Storage.save(key: "AppOpenCount", value: 1)
            return
        }
        
        switch appOpenCount {
        case 1,5:
            requestReview()
        case _ where appOpenCount % 100 == 0 :
            requestReview()
        default:
            print("App run count is : \(appOpenCount)")
            break;
        }
        
        SettingViewController.incrementAppOpenedCount()
    }
    
    private static func incrementAppOpenedCount() {
        guard var appOpenCount = Storage.load(key: "AppOpenCount") as? Int else {
            Storage.save(key: "AppOpenCount", value: 1)
            return
        }
        appOpenCount += 1
        Storage.save(key: "AppOpenCount", value: appOpenCount)
    }
}
