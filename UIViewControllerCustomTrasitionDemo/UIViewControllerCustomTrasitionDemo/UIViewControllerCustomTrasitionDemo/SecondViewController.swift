//
//  SecondViewController.swift
//  UIViewControllerCustomTrasitionDemo
//
//  Created by 王嘉宁 on 2020/8/4.
//  Copyright © 2020 Johnny. All rights reserved.
//

import UIKit


class PushRasieAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 1. Get controllers from transition context
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        
        
        // 2. Set init frame for toVC
        let screenBounds = UIScreen.main.bounds
        var finalFrame = CGRect.zero
        if let toVCTmp = toVC {
            finalFrame = transitionContext.finalFrame(for: toVCTmp)
        }
        if let toViewTmp = toVC?.view, let fromViewTmp = fromVC?.view {
            toVC?.view.frame = toVC?.view.frame.offsetBy(dx: 0, dy: screenBounds.size.height) ?? .zero
            fromVC?.view.frame = fromVC?.view.frame ?? .zero
            
            
            // 获取背景图片
            // 方法1
//            UIGraphicsBeginImageContext(fromViewTmp.frame.size)
////            fromViewTmp.drawHierarchy(in: fromViewTmp.bounds, afterScreenUpdates: true)
//            if let context = UIGraphicsGetCurrentContext() {
//                toVC?.navigationController?.view.layer.render(in: context)
////                toVC?.navigationController?.view.drawHierarchy(in: fromViewTmp.bounds, afterScreenUpdates: true)
//            }
//
//            let image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
            // 方法2
//            let window = UIApplication.shared.keyWindow
//            let scale = UIScreen.main.scale
//            UIGraphicsBeginImageContextWithOptions(window?.frame.size ?? .zero, true, scale)
//            if let context = UIGraphicsGetCurrentContext() {
//                window?.layer.render(in: context)
//            }
//            let image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
            
            // 方法3
            guard let backGroundImageData = fromVC?.dataWithScreenshotInPNGFormat() else {
                return
            }
            
            let image = UIImage(data: backGroundImageData)
            
            let backGroundImageView = UIImageView(image: image)
            backGroundImageView.frame = UIScreen.main.bounds
            
//            toViewTmp.addSubview(backGroundImageView)
//            toViewTmp.sendSubviewToBack(backGroundImageView)
            
            
            if let toVCTmp = toVC as? SecondViewController {
                toVCTmp.backGroundView = backGroundImageView
            }
            // 3. Add toVC's view to containerView
            let containerView = transitionContext.containerView
            for view in containerView.subviews {
                view.removeFromSuperview()
            }
            containerView.addSubview(backGroundImageView)
            containerView.addSubview(toViewTmp)
        }
        
        // 4. Do animate now
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            toVC?.view.frame = finalFrame.offsetBy(dx: 0, dy: 0)
        }) { (finished) in
            // 5. Tell context that we completed.
            transitionContext.completeTransition(true)
        }
    }
}

class NavigationControllerTransition: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            return PushRasieAnimation()
        }
        
        return nil
    }
}


class SecondViewController: UIViewController {
    
    let navigationTransitionDelegate = NavigationControllerTransition()
    
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



