//
//  circlularprogress.swift
//  Render3D
//
//  Created by Tikahari Khanal on 4/12/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

import Foundation
import UIKit

class circlular: UIView {
    fileprivate var layer1 = CAShapeLayer()
    fileprivate var track = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircle()
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        createCircle()
    }
    
    var trackColor = UIColor.white{
        didSet{
            layer1.strokeColor = layer1Color.cgColor
        }
    }
    
    var layer1Color = UIColor.white{
        didSet{
            track.strokeColor = trackColor.cgColor
        }
    }
    
    fileprivate func createCircle(){
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: frame.size.width/2, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        track.path  = circlePath.cgPath
        track.fillColor = UIColor.clear.cgColor
        track.strokeColor = trackColor.cgColor
        track.lineWidth = 10
        track.strokeEnd = 1
        layer.addSublayer(track)
        
        layer1.path  = circlePath.cgPath
        layer1.fillColor = UIColor.clear.cgColor
        layer1.strokeColor = layer1Color.cgColor
        layer1.lineWidth = 10
        layer1.strokeEnd = 0
        layer.addSublayer(layer1)
    }
    
    func setProgress(duration: TimeInterval, value: Float){
        print("progress set to", value, duration)
        let animation = CABasicAnimation(keyPath: "strokend")
        self.layer.speed = Float(( 1 / duration))
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        layer1.strokeEnd = CGFloat(value)
        layer1.add(animation, forKey: "progress")
    }
}

