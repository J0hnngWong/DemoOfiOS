//
//  SecondViewController.swift
//  UIViewControllerCustomTrasitionDemo
//
//  Created by 王嘉宁 on 2020/8/4.
//  Copyright © 2020 Johnny. All rights reserved.
//

import UIKit

//
//  ControllerTransitionAnimation.swift
//  NavigationDemo
//
//  Created by 王嘉宁 on 2020/8/7.
//  Copyright © 2020 王嘉宁. All rights reserved.
//

import UIKit


let ControllerTransitionAnimationUsingSpringWithDamping: CGFloat = 1.0

public protocol CustomRaisingAnimationProtocol {
    
    // 需要一个背景渐变图
    func transitionAlphaBgView() -> UIView
    // 需要一个背景图
    func transitionBgImageView() -> UIImageView
}

// MARK: 弹窗push动画
@objc
public class PushRaisingAnimation: NSObject {
    
}

extension PushRaisingAnimation: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        
        let screenBounds = UIScreen.main.bounds
        var finalFrame = CGRect.zero
        if let toVCTmp = toVC {
            finalFrame = transitionContext.finalFrame(for: toVCTmp)
        }
        // 半透明背景
        var alphaBgView = UIView()
        
        // 获取背景图
        let bgImage = UIImage(data: fromVC?.getScreenshotData() ?? Data())
        var bgImageView = UIImageView(image: bgImage ?? UIImage())
        if let toVcTmp = toVC as? CustomRaisingAnimationProtocol {
            alphaBgView = toVcTmp.transitionAlphaBgView()
            bgImageView = toVcTmp.transitionBgImageView()
            bgImageView.image = bgImage
        }
        
        if let toVCTmp = toVC, let fromVCTmp = fromVC {
            
            let containerView = transitionContext.containerView
            
            // 设定初始frame
            toVC?.view.frame = toVCTmp.view.frame.offsetBy(dx: 0, dy: screenBounds.size.height)
            fromVC?.view.frame = fromVCTmp.view.frame
            bgImageView.frame = containerView.frame
            
            // 背景图初始值设定
            alphaBgView.backgroundColor = UIColor.black
            alphaBgView.alpha = 0.0
            alphaBgView.frame = containerView.frame
            
            // 设定containerView
            for view in containerView.subviews {
                view.removeFromSuperview()
            }
            containerView.addSubview(bgImageView)
            containerView.addSubview(alphaBgView)
            containerView.addSubview(toVCTmp.view)
        }
        // 动画开始
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: ControllerTransitionAnimationUsingSpringWithDamping, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            toVC?.view.frame = finalFrame.offsetBy(dx: 0, dy: 0)
            alphaBgView.alpha = 0.6
        }) { (finished) in
            toVC?.view.addSubview(alphaBgView)
            toVC?.view.sendSubviewToBack(alphaBgView)
            toVC?.view.addSubview(bgImageView)
            toVC?.view.sendSubviewToBack(bgImageView)
            transitionContext.completeTransition(true)
        }
    }
}


// MARK: 弹窗pop动画
@objc
public class PopRaisingAnimation: NSObject {
    
}

extension PopRaisingAnimation: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        
        let screenBounds = UIScreen.main.bounds
        // 半透明背景
        let alphaBgView = UIView()
        // 获取背景图
        let bgImage = UIImage(data: toVC?.getScreenshotData() ?? Data())
        let bgImageView = UIImageView(image: bgImage ?? UIImage())
        if let fromVCTmp = fromVC as? CustomRaisingAnimationProtocol {
            fromVCTmp.transitionAlphaBgView().removeFromSuperview()
            fromVCTmp.transitionBgImageView().removeFromSuperview()
            print("")
        }
        
        if let toVCTmp = toVC, let fromVCTmp = fromVC {
            
            let containerView = transitionContext.containerView
            
            // 设定初始frame
            toVC?.view.frame = toVCTmp.view.frame
            fromVC?.view.frame = fromVCTmp.view.frame
            bgImageView.frame = containerView.frame
            
            // 背景图初始值设定
            alphaBgView.backgroundColor = UIColor.black
            alphaBgView.alpha = 0.6
            alphaBgView.frame = containerView.frame
            
            // 设定containerView
            for view in containerView.subviews {
                view.removeFromSuperview()
            }
            containerView.addSubview(toVCTmp.view) // ????
            containerView.addSubview(alphaBgView)
            containerView.addSubview(fromVCTmp.view)
        }
        // 动画开始
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: ControllerTransitionAnimationUsingSpringWithDamping, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            fromVC?.view.frame = fromVC?.view.frame.offsetBy(dx: 0, dy: screenBounds.size.height) ?? .zero
            alphaBgView.alpha = 0.0
        }) { (finished) in
            alphaBgView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}

// MARK: 弹窗动画navigationController的delegate
@objc
public class NavigationControllerRaisingAnimationTransition: NSObject, UINavigationControllerDelegate {
    
    let pushRaisingAnimation = PushRaisingAnimation()
    let popRaisingAnimation = PopRaisingAnimation()
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
//            navigationController.setNavigationBarHidden(true, animated: false)
            return pushRaisingAnimation
        } else if operation == .pop {
//            navigationController.setNavigationBarHidden(false, animated: false)
            return popRaisingAnimation
        }
        
        return nil
    }
}

@objc
public extension UIViewController {
    
    func getScreenshotData() -> Data? {
        
        var imageSize = CGSize.zero
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .portrait {
            imageSize = UIScreen.main.bounds.size
        } else {
            imageSize = CGSize(width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
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

            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false) // 如果afterScreenUpdates为true的话这种方式绘制会导致在转场已经发生的时候绘制不出image
//            window.layer.render(in: context) // 使用这种方式绘制会导致地图绘制不出来

            context.restoreGState()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.pngData()
    }
}

//class PushRasieAnimation: NSObject, UIViewControllerAnimatedTransitioning {
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 0.3
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        // 1. Get controllers from transition context
//        let toVC = transitionContext.viewController(forKey: .to)
//        let fromVC = transitionContext.viewController(forKey: .from)
//
//
//
//        // 2. Set init frame for toVC
//        let screenBounds = UIScreen.main.bounds
//        var finalFrame = CGRect.zero
//        if let toVCTmp = toVC {
//            finalFrame = transitionContext.finalFrame(for: toVCTmp)
//        }
//        if let toViewTmp = toVC?.view, let fromViewTmp = fromVC?.view {
//            toVC?.view.frame = toVC?.view.frame.offsetBy(dx: 0, dy: screenBounds.size.height) ?? .zero
//            fromVC?.view.frame = fromVC?.view.frame ?? .zero
//
//
//            // 获取背景图片
//            // 方法1
////            UIGraphicsBeginImageContext(fromViewTmp.frame.size)
//////            fromViewTmp.drawHierarchy(in: fromViewTmp.bounds, afterScreenUpdates: true)
////            if let context = UIGraphicsGetCurrentContext() {
////                toVC?.navigationController?.view.layer.render(in: context)
//////                toVC?.navigationController?.view.drawHierarchy(in: fromViewTmp.bounds, afterScreenUpdates: true)
////            }
////
////            let image = UIGraphicsGetImageFromCurrentImageContext()
////            UIGraphicsEndImageContext()
//            // 方法2
////            let window = UIApplication.shared.keyWindow
////            let scale = UIScreen.main.scale
////            UIGraphicsBeginImageContextWithOptions(window?.frame.size ?? .zero, true, scale)
////            if let context = UIGraphicsGetCurrentContext() {
////                window?.layer.render(in: context)
////            }
////            let image = UIGraphicsGetImageFromCurrentImageContext()
////            UIGraphicsEndImageContext()
//
//            // 方法3
//            guard let backGroundImageData = fromVC?.dataWithScreenshotInPNGFormat() else {
//                return
//            }
//
//            let image = UIImage(data: backGroundImageData)
//
//            let backGroundImageView = UIImageView(image: image)
//            backGroundImageView.frame = UIScreen.main.bounds
//
////            toViewTmp.addSubview(backGroundImageView)
////            toViewTmp.sendSubviewToBack(backGroundImageView)
//
//
//            if let toVCTmp = toVC as? SecondViewController {
//                toVCTmp.backGroundView = backGroundImageView
//            }
//            // 3. Add toVC's view to containerView
//            let containerView = transitionContext.containerView
//            for view in containerView.subviews {
//                view.removeFromSuperview()
//            }
//            containerView.addSubview(backGroundImageView)
//            containerView.addSubview(toViewTmp)
//        }
//
//        // 4. Do animate now
//        let duration = self.transitionDuration(using: transitionContext)
//        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
//            toVC?.view.frame = finalFrame.offsetBy(dx: 0, dy: 0)
//        }) { (finished) in
//            // 5. Tell context that we completed.
//            transitionContext.completeTransition(true)
//        }
//    }
//}
//
//class NavigationControllerTransition: NSObject, UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//
//        if operation == .push {
//            return PushRasieAnimation()
//        }
//
//        return nil
//    }
//}


class SecondViewController: UIViewController {
    
    let navigationTransitionDelegate = NavigationControllerRaisingAnimationTransition()
    
    public var backGroundView: UIImageView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
//        navigationController?.delegate = self
        transitioningDelegate = self
        
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let view1 = UIView(frame: CGRect(x: 0, y: 200, width: self.view.bounds.width, height: self.view.bounds.height))
        view1.backgroundColor = UIColor.cyan
        view.addSubview(view1)
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 100, y: 100, width: 60, height: 60)
        btn.backgroundColor = UIColor.brown
        btn.addTarget(self, action: #selector(setup), for: .touchUpInside)
        view1.addSubview(btn)
    }
    
    @objc
    func setup() {
//        let viewController = ThirdViewController()
//        navigationController?.delegate = navigationTransitionDelegate
//        navigationController?.pushViewController(viewController, animated: true)
//        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.addSubview(backGroundView)
        backGroundView.frame = self.view.frame
        self.view.sendSubviewToBack(backGroundView)
    }
    
    
}

//extension SecondViewController: UIViewControllerAnimatedTransitioning {
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 2
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//
//    }
//}



extension SecondViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}



