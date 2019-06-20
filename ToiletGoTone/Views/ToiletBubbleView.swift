//
//  ToiletBubbleView.swift
//  ToiletGoTone
//
//  Created by mugua on 2019/6/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import EasyAnimation


class ToiletBubbleView: MAAnnotationView {
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        self.imageView.contentMode = .scaleAspectFit
        self.image = UIImage(named: "wc_icon")
        
        UIView.animateAndChain(withDuration: 0.5, delay: 0,
                               options: [], animations: {
                                self.imageView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
        }, completion: nil).animate(withDuration: 0.5, animations: {
            self.imageView.layer.transform = CATransform3DMakeScale(1, 1, 1.0)
        })
        
        let label = UILabel(frame: .zero)
        label.text = "厕所"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.white
        self.addSubview(label)
        
        label.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(self.imageView)
            maker.top.equalTo(self.imageView.snp.bottom).offset(0)
        }
        
        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
}
