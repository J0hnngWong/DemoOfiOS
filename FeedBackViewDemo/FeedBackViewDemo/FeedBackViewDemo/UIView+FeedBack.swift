//
//  UIView+FeedBack.swift
//  ViewTouchFeedBack
//
//  Created by 王嘉宁 on 2020/6/30.
//  Copyright © 2020 Johnny. All rights reserved.
//

import UIKit

public struct FeedBackType: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let visual = FeedBackType(rawValue: 1 << 0)
    static let touch = FeedBackType(rawValue: 1 << 1)
}

enum VisualFeedBackType {
    case enlarge //zoomIn
    case reduce //zoomOut
}

class FeedBackView: UIView {
    
    var needVisualFeedBack = false
    var needTouchFeedBack = false
    
    init(frame: CGRect, feedBackType: FeedBackType) {
        super.init(frame: frame)
        needVisualFeedBack = feedBackType.contains(.visual)
        needTouchFeedBack = feedBackType.contains(.touch)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        doScaleFeedBackAnimation(type: .reduce)
//        transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("cancel")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.count > 1 {
            return
        }
        
        let touchX = touches.first?.preciseLocation(in: self).x ?? -1
        let touchY = touches.first?.preciseLocation(in: self).y ?? -1
        let preTouchX = touches.first?.previousLocation(in: self).x ?? -1
        let preTouchY = touches.first?.previousLocation(in: self).y ?? -1

        let isCurrentTouchInside = !(touchX > bounds.width) && !(touchX < 0) && !(touchY > bounds.height) && !(touchY < 0)
        let isPreviousTouchInside = !(preTouchX > bounds.width) && !(preTouchX < 0) && !(preTouchY > bounds.height) && !(preTouchY < 0)
        print("touchX : ",touchX,"touchY : ",touchY, " boundWidth : ", bounds.width, " boundHeight : ", bounds.width, " preTouchX : ", preTouchX, " preTouchY : ", preTouchY, "\n")
        if !isCurrentTouchInside && isPreviousTouchInside {
            doScaleFeedBackAnimation(type: .enlarge)
        } else if isCurrentTouchInside && !isPreviousTouchInside {
            doScaleFeedBackAnimation(type: .reduce)
        }
        
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        transform = CGAffineTransform(scaleX: 1, y: 1)
        
        let touchX = touches.first?.preciseLocation(in: self).x ?? -1
        let touchY = touches.first?.preciseLocation(in: self).y ?? -1
        let isCurrentTouchInside = !(touchX > bounds.width) && !(touchX < 0) && !(touchY > bounds.height) && !(touchY < 0)
        
        if isCurrentTouchInside {
            doScaleFeedBackAnimation(type: .enlarge)
        }
        
        let feedBack = UIImpactFeedbackGenerator(style: .light)
        feedBack.impactOccurred()
    }
    
    func doScaleFeedBackAnimation(type: VisualFeedBackType) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.15
        animation.repeatCount = 0
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        var key = "scale-layer"
        switch type {
        case .enlarge:
            animation.fromValue = 0.9
            animation.toValue = 1
            key = "scale-layer-zoomIn"
        case .reduce:
            animation.fromValue = 1
            animation.toValue = 0.9
            key = "scale-layer-zoomOut"
        }
        animation.fillMode = .forwards
        layer.add(animation, forKey: key)
    }
    
//    func isSingleTouchInside(touche: UITouch?) -> Bool {
//        let touchX = touche?.preciseLocation(in: self).x ?? -1
//        let touchY = touche?.preciseLocation(in: self).y ?? -1
//        
//        let isCurrentTouchInside = !(touchX > bounds.width) && !(touchX < 0) && !(touchY > bounds.height) && !(touchY < 0)
//        
//        return isCurrentTouchInside
//    }
}
