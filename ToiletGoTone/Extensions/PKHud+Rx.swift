//
//  PKHud+Rx.swift
//  Dingo
//
//  Created by mugua on 2019/5/7.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import PKHUD
import RxCocoa
import RxSwift

extension Reactive where Base: PKHUD {
    
    var animation: Binder<Bool> {
        return Binder(self.base, scheduler: MainScheduler.instance, binding: { (_, show) in
            if show {
                HUD.show(.progress)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            } else {
                HUD.hide(afterDelay: 0.8)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }
    
    var showError: Binder<Error> {
        return Binder(self.base, scheduler: MainScheduler.instance, binding: { (_, error) in
            HUD.flash(.label(error.localizedDescription), delay: 2)
        })
    }
}
