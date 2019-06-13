//
//  BaseNavigationController.swift
//  Dingo
//
//  Created by mugua on 2019/5/5.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import ChameleonFramework

class BaseNavigationController: UINavigationController {

    @IBInspectable open var clearBackTitle: Bool = true
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
 
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        controlClearBackTitle()
        
        if self.viewControllers.count == 1 {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override open func show(_ vc: UIViewController, sender: Any?) {
        controlClearBackTitle()
        super.show(vc, sender: sender)
    }
}


// MARK: Private Methods
private extension BaseNavigationController {
    
    func commonInit() {
        navigationBar.prefersLargeTitles = true
        navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black,
                                                  NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30)]
        
        navigationBar.shadowImage = UIImage()
        navigationBar.layer.shadowColor  = UIColor.clear.cgColor
        navigationBar.isTranslucent = false
        
        self.interactivePopGestureRecognizer?.delegate = self
        self.delegate = self
    }
    
    func controlClearBackTitle() {
        if clearBackTitle {
            topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
}


extension BaseNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let bgColor = viewController.navigationController?.navigationBar.barTintColor {
            let titleColor = ContrastColorOf(bgColor, returnFlat: true)
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : titleColor]
            navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : titleColor]
        }
        
    }
}


extension BaseNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        return viewControllers.count > 1
    }
}
