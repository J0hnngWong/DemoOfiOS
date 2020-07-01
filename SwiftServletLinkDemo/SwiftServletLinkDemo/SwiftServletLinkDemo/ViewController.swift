//
//  ViewController.swift
//  SwiftServletLinkDemo
//
//  Created by 王嘉宁 on 2020/4/8.
//  Copyright © 2020 王嘉宁. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        accessHelloWorld()
        
    }
    
    func accessHelloWorld() {
        let urlStr = "http://localhost:8080/HelloWorld"
        guard let url = URL(string: urlStr) else { return }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 3)
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            print("\(data) \n")
            print("\(response) \n")
            print("\(error) \n")
            
            guard let dictData = data else { return }
            let dict = try? JSONSerialization.jsonObject(with: dictData, options: .allowFragments)
            print("end")
        }.resume()
    }


}

