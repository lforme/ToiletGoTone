//
//  LocalArchive.swift
//  IntelligentUOKO
//
//  Created by mugua on 2018/10/23.
//  Copyright © 2018年 mugua. All rights reserved.
//

import Foundation

public struct Storage {
    
    public static func save(key: String, value: Any?) {
        guard let value = value else {
            UserDefaults.standard.setValue(nil, forKey: key)
            return
        }
        UserDefaults.standard.setValue(value, forKey: key)
        do {
            UserDefaults.standard.synchronize()
        }
    }
    
    public static func load(key: String) -> Any? {
        return UserDefaults.standard.value(forKey:key)
    }
    
    public static func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}


