//
//  ScreenShot.swift
//  UIViewControllerCustomTrasitionDemo
//
//  Created by 王嘉宁 on 2020/8/5.
//  Copyright © 2020 Johnny. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func dataWithScreenshotInPNGFormat() -> Data? {
        var imageSize = CGSize.zero
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .portrait {
            imageSize = UIScreen.main.bounds.size
        } else {
            imageSize = CGSize(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
        }
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        for window in UIApplication.shared.windows {
            context.saveGState()
            context.translateBy(x: window.center.x, y: window.center.y)
            context.concatenate(window.transform)
            context.translateBy(x: -window.bounds.size.width * window.layer.anchorPoint.x, y: -window.bounds.size.height * window.layer.anchorPoint.y)
            if orientation == .landscapeLeft {
                context.rotate(by: CGFloat(Double.pi/2))
                context.translateBy(x: 0, y: -imageSize.width)
            } else if orientation == .landscapeRight {
                context.rotate(by: CGFloat(-Double.pi/2))
                context.translateBy(x: -imageSize.height, y: 0)
            } else if orientation == .portraitUpsideDown {
                context.rotate(by: CGFloat(Double.pi))
                context.translateBy(x: -imageSize.width, y: -imageSize.height)
            }
            
//            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            window.layer.render(in: context)
            
            context.restoreGState()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.pngData()
    }
}
