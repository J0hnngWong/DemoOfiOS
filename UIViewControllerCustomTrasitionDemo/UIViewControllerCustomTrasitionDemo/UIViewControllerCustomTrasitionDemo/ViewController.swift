//
//  ViewController.swift
//  UIViewControllerCustomTrasitionDemo
//
//  Created by 王嘉宁 on 2020/8/4.
//  Copyright © 2020 Johnny. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let navigationTransitionDelegate = NavigationControllerTransition()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        modalPresentationStyle = .fullScreen
        
        view.backgroundColor = UIColor.gray
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 100, y: 100, width: 60, height: 60)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(setup), for: .touchUpInside)
        view.addSubview(btn)
        
        
        let btn1 = UIButton(type: .custom)
        btn1.frame = CGRect(x: 100, y: 200, width: 60, height: 60)
        btn1.backgroundColor = UIColor.blue
        btn1.addTarget(self, action: #selector(push), for: .touchUpInside)
        view.addSubview(btn1)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
            self.view.backgroundColor = UIColor.darkGray
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+6) {
            self.view.backgroundColor = UIColor.darkText
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+9) {
            self.view.backgroundColor = UIColor.purple
        }
        
    }
    
    @objc
    func setup() {
        let viewController = ViewController()
        let naviVC = UINavigationController(rootViewController: viewController)
        naviVC.modalPresentationStyle = .fullScreen
        naviVC.delegate = navigationTransitionDelegate
        present(naviVC, animated: true, completion: {
            
        })
    }
    
    @objc
    func push() {
        let viewController = SecondViewController()
//        viewController.backGroundView = getBackGroundImageView()
        navigationController?.pushViewController(viewController, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
//    func getBackGroundImageView() -> UIImageView {
//        UIGraphicsBeginImageContext(view.frame.size)
//        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return UIImageView(image: image)
//    }

}

