//
//  HomeMapViewController.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Presentr

class HomeMapViewController: UIViewController {

    let presenter = Presentr(presentationType: .bottomHalf)
    @IBOutlet weak var historyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        interactiveNavigationBarHidden = true
        
        AppDelegate.changeStatusBarStyle(.lightContent)
        view.addSubview(MapHelper.shareInstance)
        view.bringSubviewToFront(historyButton)
        historyButton.clipsToBounds = true
        historyButton.layer.cornerRadius = 3
        
        MapHelper.shareInstance.selectBlock = {[weak self] (user, poi) in
            guard let this = self else {
                return
            }
        
            let controller: HalfViewController = ViewLoader.Storyboard.controller(from: "Main")
            controller.locationInfo = poi
            controller.userLocation = user
            controller.navigation = self?.navigationController
            
            this.customPresentViewController(this.presenter, viewController: controller, animated: true, completion: nil)

        }
    }

    @IBAction func historyTap(_ sender: UIButton) {
        let historyVC: HistoryViewController = ViewLoader.Storyboard.controller(from: "Main")
        navigationController?.pushViewController(historyVC, animated: true)
    }
}
