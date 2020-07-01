//
//  ViewController.swift
//  LabelRectCalculateDemo
//
//  Created by 王嘉宁 on 2020/4/1.
//  Copyright © 2020 王嘉宁. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let label: UILabel = UILabel()
//        label.textRect(forBounds: , limitedToNumberOfLines: )
        
        let str = "Test String Length Test String Length Test String Length Test String Length"
        let label1: UILabel = UILabel()
        label1.numberOfLines = 0
        label1.text = str
        
        let label2: UILabel = UILabel()
        label2.numberOfLines = 0
        label2.text = str
        
        view.addSubview(label1)
        label1.frame = CGRect(origin: CGPoint(x: 16, y: 30), size: str.boundingWith(font: label1.font, specifiedWith: 50).size)
        view.addSubview(label2)
        label2.frame = CGRect(origin: CGPoint(x: 16, y: 400), size: str.boundingWith(font: label2.font, specifiedWith: 100).size)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            label1.frame = CGRect(origin: CGPoint(x: 16, y: 30), size: str.boundingWith(font: label1.font, specifiedWith: 200).size)
        }
        
        print(str.boundingWith(font: label1.font, specifiedWith: 50))

        print(str.boundingWith(font: label1.font, specifiedWith: 100))
        
        print("end")
    }


}

extension String {
    func boundingWith(font: UIFont, specifiedWith: CGFloat = CGFloat.infinity, specifiedHeight: CGFloat = CGFloat.infinity) -> CGRect {
        return NSString(string: self).boundingRect(with: CGSize(width: specifiedWith, height: specifiedHeight), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : font], context: nil)
    }
}
