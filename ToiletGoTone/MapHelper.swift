//
//  MapHelper.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

final class MapHelper: UIView {
    
    typealias DidSelectAnnotation = (_ userCurrent: MAUserLocation, _ selected: MAAnnotation)->Void
    
    static let shareInstance = MapHelper()
    var selectBlock: DidSelectAnnotation?
    
    private let mapView: MAMapView
    private let search = AMapSearchAPI()
    private var request = AMapPOIAroundSearchRequest()
    private let userLocationObserver = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    
    private var hasLoad = false
    private var lastPolylines: [MAPolyline] = []
    private var lastPolyFristShow = true
    
    let walkManager = AMapNaviWalkManager()
    
    private override init(frame: CGRect) {
        mapView = MAMapView(frame: UIScreen.main.bounds)
        super.init(frame: UIScreen.main.bounds)
        commonInit()
        setupSearch()
        setupWalkMan()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        mapView = MAMapView(frame: UIScreen.main.bounds)
        super.init(coder: aDecoder)
        commonInit()
        setupSearch()
        setupWalkMan()
    }
}


private extension MapHelper {
    
    func commonInit() {
        
        let url = Bundle.main.url(forResource: "style", withExtension: "data")
        let jsonData = try! Data(contentsOf: url!)
        let url2 = Bundle.main.url(forResource: "style_extra", withExtension: "data")
        let jsonData2 = try! Data(contentsOf: url2!)
        let options = MAMapCustomStyleOptions()
        options.styleData = jsonData
        options.styleExtraData = jsonData2
        mapView.setCustomMapStyleOptions(options)
        mapView.customMapStyleEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.isShowsIndoorMap = true
        mapView.setZoomLevel(17, animated: true)
        mapView.desiredAccuracy = 500
        mapView.distanceFilter = 500
        mapView.minZoomLevel = 10
        mapView.maxZoomLevel = 20
        
        
        // 自定义定位小圆点图标
        let r = MAUserLocationRepresentation()
        r.showsAccuracyRing = true
        r.lineWidth = 2
        r.enablePulseAnnimation = false
        r.image = UIImage(named: "me_icon")
        mapView.update(r)
        self.addSubview(mapView)
        
        // 设置代理
        mapView.delegate = self
        search?.delegate = self
        
    }
    
    func setupSearch() {
        
        userLocationObserver.observeOn(MainScheduler.instance).subscribe(onNext: {[unowned self] (location) in
            
            guard let l = location else { return }
            
            self.request.location = AMapGeoPoint.location(withLatitude: CGFloat(l.latitude), longitude: CGFloat(l.longitude))
            self.request.keywords = "厕所|公共厕所|商场"
            self.request.requireExtension = true
            self.search?.aMapPOIAroundSearch(self.request)
        }).disposed(by: rx.disposeBag)
        
    }
    
    func setupWalkMan() {
        
        self.walkManager.delegate = self
    }
}

// MARK: - MAMapViewDelegate
extension MapHelper: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            
            if userLocation.location != nil {
                self?.userLocationObserver.accept(userLocation.location.coordinate)
                mapView.userTrackingMode = .none
            }
        }
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        let left = (annotation.coordinate.latitude, annotation.coordinate.longitude)
        let right = (mapView.userLocation.coordinate.latitude, mapView.userLocation.coordinate.longitude)
        
        if annotation.isKind(of: MAPointAnnotation.self) && left != right {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: ToiletBubbleView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? ToiletBubbleView
            
            if annotationView == nil {
                annotationView = ToiletBubbleView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            return annotationView!
        }
        
        return nil
    }
    
    
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        
        selectBlock?(mapView.userLocation, view.annotation)
        
        let startPoint = AMapNaviPoint.location(withLatitude: CGFloat(mapView.userLocation.location.coordinate.latitude), longitude: CGFloat(mapView.userLocation.location.coordinate.longitude))!
        
        let endPoint = AMapNaviPoint.location(withLatitude: CGFloat(view.annotation.coordinate.latitude), longitude: CGFloat(view.annotation.coordinate.longitude))!
        
        self.walkManager.calculateWalkRoute(withStart: [startPoint], end: [endPoint])
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAPolyline.self) {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 3.0
            renderer.strokeColor = UIColor.cyan
            return renderer
        }
        return nil
    }
}


extension MapHelper: AMapSearchDelegate {
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        if response.count == 0 {
            return
        }
        let annimations = response.pois.compactMap { (poi) -> MAAnnotation in
            let a = MAPointAnnotation()
            a.coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(poi.location!.latitude), longitude: CLLocationDegrees(poi.location!.longitude))
            return a
        }
        
        if !hasLoad {
            self.mapView.addAnnotations(annimations)
        }
        
        hasLoad = true
    }
}


extension MapHelper: AMapNaviWalkManagerDelegate {
    
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        guard let lines = walkManager.naviRoute?.routeCoordinates else { return }
        
        var lineCoordinates = lines.map { (p) -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(p.latitude), longitude: CLLocationDegrees(p.longitude))
        }
        
        let polyline: MAPolyline = MAPolyline(coordinates: &lineCoordinates, count: UInt(lineCoordinates.count))
        
        
        if lastPolylines.count < 3 {
            lastPolylines.append(polyline)
        }
        
        if lastPolylines.count == 3 {
            lastPolylines.removeFirst()
        }
        
        mapView.add(lastPolylines.last)
        mapView.remove(lastPolylines.first)
        
        if lastPolyFristShow {
            mapView.add(polyline)
            lastPolyFristShow = false
        }
    }
}
