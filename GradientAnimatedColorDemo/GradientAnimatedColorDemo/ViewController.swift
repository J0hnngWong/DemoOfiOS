//
//  ViewController.swift
//  GradientAnimatedColorDemo
//
//  Created by 王嘉宁 on 2019/4/30.
//  Copyright © 2019 Johnny. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.gradientAnimatedColor(in:self.firstView)
//        self.gradientAnimatedColor(in:self.thirdView)
        self.gradientAnimatedColor(in: self.secondView)
    }
    
    //参考:https://blog.csdn.net/jeffasd/article/details/53107249
    func gradientAnimatedColor(in view: UIView) {
        let originColor = UIColor.white.cgColor
        let darkGrayColor = UIColor.gray.cgColor
        let orangeColor = UIColor.orange.cgColor
        
        let duration = 0.75
        
        let animateBegin = CABasicAnimation.init(keyPath: "backgroundColor")
        animateBegin.duration = duration
        animateBegin.fromValue = originColor
        animateBegin.toValue = darkGrayColor
        animateBegin.fillMode = CAMediaTimingFillMode.forwards
        animateBegin.isRemovedOnCompletion = false
        animateBegin.beginTime = 0.0
        
        let animateGroupMember = CABasicAnimation.init(keyPath: "backgroundColor")
        animateGroupMember.duration = duration
        animateGroupMember.fromValue = darkGrayColor
        animateGroupMember.toValue = orangeColor
        animateGroupMember.repeatCount = 3
        animateGroupMember.autoreverses = true
        animateGroupMember.isRemovedOnCompletion = false
        animateGroupMember.fillMode = CAMediaTimingFillMode.both
        animateGroupMember.beginTime = 0.0
        
        let animateGroup = CAAnimationGroup.init()
        animateGroup.duration = 6 * duration
        animateGroup.animations = [animateGroupMember]
        animateGroup.isRemovedOnCompletion = false
        animateGroup.autoreverses = true
        animateGroup.fillMode = CAMediaTimingFillMode.forwards
        animateGroup.beginTime = duration
        
        let animateEnd = CABasicAnimation.init(keyPath: "backgroundColor")
        animateEnd.duration = duration
        animateEnd.fromValue = darkGrayColor
        animateEnd.toValue = originColor
        animateEnd.fillMode = CAMediaTimingFillMode.forwards
        animateEnd.isRemovedOnCompletion = false
        animateEnd.beginTime = 7 * duration
        
        let animateFinalGroup = CAAnimationGroup.init()
        animateFinalGroup.duration = 8 * duration
        animateFinalGroup.animations = [animateBegin, animateGroup, animateEnd]
        animateFinalGroup.isRemovedOnCompletion = false
        animateFinalGroup.fillMode = CAMediaTimingFillMode.both
        
        view.layer.add(animateFinalGroup, forKey: "backgroundColor")
    }

}

