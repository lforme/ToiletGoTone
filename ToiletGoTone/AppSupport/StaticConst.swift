//
//  StaticConst.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension NSNotification.Name {
    
    public static let statuBarDidChnage = NSNotification.Name(rawValue: "StatuBarDidChnage")
    public static let refreshState = NSNotification.Name(rawValue: "refreshState")
}


struct DatabaseKey {
    static let privacyTable = "PrivacyModel"
    static let favoriteToilet = "FavoriteToilet"
}


struct ThirdVenderKey {
    static let amapApiKey = "2b192ab58fc104f08f686ecfa3ef23e6"
    static let leanCloudId = "MGHYcjRFWPmEJXlswj1uA4lT-gzGzoHsz"
    static let leanCloudClentKey = "PkcPHPBL6L0RD32pz4n0Qme0"
    static let amdinPwd = "bbqqdd123"
}
