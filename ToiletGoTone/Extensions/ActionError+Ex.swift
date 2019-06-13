//
//  ActionError+Ex.swift
//  Dingo
//
//  Created by mugua on 2019/5/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import Action
import RxCocoa
import RxSwift

enum APPCommonError: Error {
    case msg(String)
    
    var msg: String {
        switch self {
        case .msg(let value):
            return value
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .msg(let value):
            return value
        }
    }
}

extension Observable {
    
    func actionErrorShiftError() -> Observable<Error> {
        
        return self.map { (actionError) -> Error in
            
            guard let e = actionError as? ActionError else {
                return APPCommonError.msg("actionError Shifted Error failed")
            }
            
            switch e {
            case .underlyingError(let es):
                return es
                
            case .notEnabled:
                return APPCommonError.msg("失败了")
            }
            
        }
    }
}
