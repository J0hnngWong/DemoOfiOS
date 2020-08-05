//
//  ThirdViewController.swift
//  UIViewControllerCustomTrasitionDemo
//
//  Created by 王嘉宁 on 2020/8/4.
//  Copyright © 2020 Johnny. All rights reserved.
//

import UIKit

@objc
public class ThirdViewController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
        view.backgroundColor = .clear
        let view = UIView(frame: CGRect(x: 0, y: 300, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 300))
        self.view.addSubview(view)
    }
}
