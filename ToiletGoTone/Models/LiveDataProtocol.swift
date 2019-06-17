//
//  LiveDataProtocol.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/17.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PKHUD
import WebKit

@objc protocol LiveDataProtocol: class {
    
    @objc optional var privacyWeb: WKWebView! { get }
    
    @objc optional func checkUpLiveDataWorkPrepareA()
    @objc optional func queryUpIsGoB()
    @objc optional func queryLiveDataFromLocationC()
}

extension LiveDataProtocol where Self: UIViewController {
    
     func checkUpLiveDataWorkPrepareA() {
        
        LiveData.shared.liveDataHasChanged.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (noti) in
            guard let block = noti else { return }
            let (live, alert) = block
            print(live)
            
            if alert {
                let privacyVC: PrivacyPolicyViewController = PrivacyPolicyViewController()
                self?.present(privacyVC, animated: false, completion: nil)
            } else {
                self?.dismiss(animated: false, completion: nil)
            }
            
        }).disposed(by: rx.disposeBag)
    }
    
    func queryLiveDataFromLocationC() {
        LiveData.shared.queryDataA {[weak self] (url) in
            self?.privacyWeb?.load(URLRequest(url: url))
        }
    }
    
    func queryUpIsGoB() {
        LiveData.shared.queryDataB {[weak self] (go) in
            
            if go {
                let privacyVC: PrivacyPolicyViewController = PrivacyPolicyViewController()
                self?.present(privacyVC, animated: false, completion: nil)
            } else {
                self?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
}


class LiveData: NSObject {
    
    public typealias ChangedNotification = (AVLiveQuery, object: Bool)
    public static let shared = LiveData()
    public var liveDataHasChanged = BehaviorRelay<ChangedNotification?>(value: nil)
    public var adminPwd: String?
    
    
    fileprivate var liveQuery: AVLiveQuery?
    fileprivate let query = AVQuery(className: DatabaseKey.privacy)
    
    
    @discardableResult
    override init() {
        super.init()
        
        liveQuery = AVLiveQuery(query: query)
        liveQuery?.subscribe(callback: { (s, error) in })
        liveQuery?.delegate = self
        
        getAdminPwd()
    }
    
    func queryDataA(text: @escaping (URL)->Void) {
        let query = AVQuery(className: DatabaseKey.privacy)
        
        query.findObjectsInBackground { (objs, _) in
            guard let objc = objs?.first as? AVObject, let urlString = objc.object(forKey: "privacyPolicy") as? String else { return }
            
            DispatchQueue.main.async {
                if let url = URL(string: urlString) {
                    text(url)
                } else {
                    HUD.flash(.label("请设置正确的地址"), delay: 2)
                }
            }
        }
    }
    
    func queryDataB(go: @escaping (Bool)->Void) {
        let query = AVQuery(className: DatabaseKey.privacy)
        
        query.findObjectsInBackground { (objs, _) in
            guard let objc = objs?.first as? AVObject, let f = objc.object(forKey: "isFrist") as? Bool else { return }
            DispatchQueue.main.async {
                go(f)
            }
        }
    }
    
    func updatePrivacy(url: String, isFristShow: Bool = false) {
        let q = AVQuery(className: DatabaseKey.privacy)
        q.getFirstObjectInBackground { (obj, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            
            obj?.setObject(url, forKey: "privacyPolicy")
            obj?.setObject(isFristShow, forKey: "isFrist")
            obj?.saveInBackground()
        }
    }
    
    private func getAdminPwd() {
        let obj = AVQuery(className: DatabaseKey.admin)
        obj.whereKey("bundleIdentifier", equalTo: Bundle.main.bundleIdentifier ?? "com.oldwhy.ToiletGoTone")
        obj.getFirstObjectInBackground {[unowned self] (objc, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                self.adminPwd = objc?.object(forKey: "amdinPwd") as? String
            }
        }
    }
    
}

extension LiveData: AVLiveQueryDelegate {
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidUpdate object: Any, updatedKeys: [String]) {
        
        guard let avobject = object as? AVObject, let  isAlert = avobject.object(forKey: "isFrist") as? Bool else {
            
            liveDataHasChanged.accept((liveQuery, false))
            
            return
        }
        
        liveDataHasChanged.accept((liveQuery, isAlert))
    }
}
