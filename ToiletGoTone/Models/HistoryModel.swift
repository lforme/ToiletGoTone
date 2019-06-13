//
//  HistoryModel.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/13.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class HistoryModel {
    
    var buildingName: String?
    var street: String?
    var evaluate: String?
    let userId: String
    
    private let query = AVQuery(className: DatabaseKey.favoriteToilet)
    
    init(id: String) {
        self.userId = id
    }
    
    func saveToServer() -> Observable<Bool> {
        
        return Observable<Bool>.create({[unowned self] (o) -> Disposable in
            let obj = AVObject(className: DatabaseKey.favoriteToilet)
            obj.setObject(self.userId, forKey: "userId")
            obj.setObject(self.buildingName, forKey: "buildingName")
            obj.setObject(self.street, forKey: "street")
            obj.setObject(self.evaluate, forKey: "eevaluate")
            
            obj.saveEventually { (success, error) in
                if let e = error {
                    o.onError(e)
                } else {
                    o.onNext(success)
                    o.onCompleted()
                }
            }
            return Disposables.create()
        })
    }
    
    
    func fetchLabelMoels(page: Int = 0) -> Observable<[HistoryModel]> {
        
        return Observable<[HistoryModel]>.create({[unowned self] (o) -> Disposable in
            
            self.query.whereKey("userId", equalTo: self.userId)
            self.query.order(byDescending: "createdAt")
            self.query.limit = 10
            self.query.skip = 10 * page
            self.query.cachePolicy = AVCachePolicy.networkElseCache
            
            self.query.findObjectsInBackground { (objs, error) in
                if let e = error {
                    o.onError(e)
                } else {
                    if let array = objs {
                        let entities = array.map({ (any) -> HistoryModel? in
                            
                            let dict = any as? AVObject
                            guard let id = dict?.object(forKey: "userId") as? String else { return nil
                                
                            }
                            let m = HistoryModel(id: id)
                            m.buildingName = dict?.object(forKey: "buildingName") as? String
                            m.street = dict?.object(forKey: "street") as? String
                            m.evaluate = dict?.object(forKey: "eevaluate") as? String
                            return m
                        }).compactMap { $0 }
                        o.onNext(entities)
                        o.onCompleted()
                    }
                }
            }
            return Disposables.create()
        })
        
    }
}
