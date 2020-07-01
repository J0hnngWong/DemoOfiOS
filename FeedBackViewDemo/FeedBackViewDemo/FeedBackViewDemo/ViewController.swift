//
//  ViewController.swift
//  FeedBackViewDemo
//
//  Created by 王嘉宁 on 2020/7/1.
//  Copyright © 2020 Johnny. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let testView = FeedBackView(frame: CGRect(x: 100, y: 200, width: 60, height: 60), feedBackType: [.touch, .visual])
       

    override func viewDidLoad() {
       super.viewDidLoad()
       
       view.backgroundColor = .gray
       
       testView.backgroundColor = .red
       view.addSubview(testView)
    }


}

