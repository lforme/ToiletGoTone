//
//  HalfViewController.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import GlitchLabel
import PKHUD
import RxSwift
import RxCocoa

class HalfViewController: UIViewController {
    
    var userLocation: MAUserLocation!
    var locationInfo: MAAnnotation!
    weak var navigation: UINavigationController?
    
    private let search = AMapSearchAPI()
    
    var vm: HistoryModel!
    
    @IBOutlet weak var streetInfoLabel: GlitchLabel!
    @IBOutlet weak var buildingLabel: GlitchLabel!
    @IBOutlet weak var distanceLabel: GlitchLabel!
    @IBOutlet weak var directionLabel: GlitchLabel!
    
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    deinit {
        print("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearch()
        
        guard let id = AVUser.current()?.objectId else {
            
            HUD.flash(.label("无法获取用户ID"), delay: 2)
            return
        }
        vm = HistoryModel(id: id)
        
        view.backgroundColor = UIColor.flatOrangeDark.withAlphaComponent(0.5)
        
        setupButton()
    }
    
    func setupButton() {
       
        [navigationButton, favoriteButton].forEach { (btn) in
            let color = UIColor.cyan
            btn?.layer.cornerRadius = 10
            btn?.layer.shadowColor = color.cgColor
            btn?.layer.borderWidth = 0
            btn?.layer.borderColor = color.cgColor
            btn?.layer.shadowOpacity = 0.8
            btn?.layer.shadowOffset = CGSize(width: 2, height: 2)
        }

    }
    
    func setupSearch() {
        search?.delegate = self
        
        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(locationInfo.coordinate.latitude), longitude: CGFloat(locationInfo.coordinate.longitude))
        request.requireExtension = true
        
        search?.aMapReGoecodeSearch(request)
    }
    
    @IBAction func navigateTap(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
        let autoVC = AutoNavigationController()
        
        autoVC.startPoint = AMapNaviPoint.location(withLatitude: CGFloat(userLocation.location.coordinate.latitude), longitude: CGFloat(userLocation.location.coordinate.longitude))
        
        autoVC.endPoint = AMapNaviPoint.location(withLatitude: CGFloat(locationInfo.coordinate.latitude), longitude: CGFloat(locationInfo.coordinate.longitude))
        
        navigation?.pushViewController(autoVC, animated: true)
    }
    
    @IBAction func favoriteTap(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
        vm.buildingName = streetInfoLabel.text
        vm.street = buildingLabel.text
        vm.evaluate = "这个厕所真的很好用哦"
        
        vm.saveToServer().subscribe(onNext: { (s) in
            if s {
                HUD.flash(.label("收藏成功"), delay: 2)
            }
        }, onError: { (error) in
            HUD.flash(.label(error.localizedDescription), delay: 2)
        }).disposed(by: rx.disposeBag)
        
    }
}


extension HalfViewController: AMapSearchDelegate {
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        
        if response.regeocode == nil {
            return
        }
        
        buildingLabel.text = response.regeocode.formattedAddress
        streetInfoLabel.text = response.regeocode.pois.first?.name
        
        if let distance = response.regeocode.pois.first?.distance {
            distanceLabel.text = "距离您还有\(distance.description)米!!!"
        }
        
        if let direction = response.regeocode.pois.first?.direction {
            directionLabel.text = "方向: \(direction)  冲啊 !!!"
        }
        
    }
}



