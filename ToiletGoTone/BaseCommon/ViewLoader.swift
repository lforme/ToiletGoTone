//
//  ViewLoader.swift
//  Multiplexing
//
//  Created by 郑林琴 on 2017/1/19.
//  Copyright © 2017年 Ice Butterfly. All rights reserved.
//

import UIKit

struct ViewLoader {
    
    struct Xib {
        
        static func view<T: UIView>() -> T {
            let str = String(describing: T.self)
            return Bundle.main.loadNibNamed(str, owner: nil, options: nil)?.last as! T
        }
        
        static func controller<T: UIViewController>() -> T {
            let str = String(describing: T.self)
            return T(nibName: str, bundle: nil)
        }
    }
    
    struct Storyboard {
        
        static func controller<T: UIViewController>(from: String) -> T {
            let str = String(describing: T.self)
            let storyboard = UIStoryboard(name: from, bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: str) as! T
        }
    }
    
}
