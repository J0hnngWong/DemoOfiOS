//
//  ViewController.swift
//  ObjCFileSystemDemo
//
//  Created by 王嘉宁 on 2020/4/2.
//  Copyright © 2020 王嘉宁. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var dataArray: [Any] = []
    
    let label = UILabel(frame: CGRect(x: 100, y: 200, width: 300, height: 100))
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.font = UIFont(name: "PingFangSC-Regular", size: 80)
        label.text = "0"
        view.addSubview(label)
        
        //read from file
        readFromFile()
        
        loopRequest()
    }
    
    func readFromFile() {
        guard let filePathStr = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else { return }
        var filePath = filePathStr
        filePath.append("/text")
        print(filePath)
        
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        } else {
            let fileUrl = URL(fileURLWithPath: filePath)
            guard let data = try? Data(contentsOf: fileUrl) else { return }
            guard let array = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return }
            dataArray = array as? Array<Any> ?? []
            label.text = String(dataArray.count)
        }
        
    }
    
    func writeToFile(responseData: Data?) {
        
        //file path
        guard let filePathStr = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else { return }
        var filePath = filePathStr
        filePath.append("/text")
        print(filePath)
        
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        let fileUrl = URL(fileURLWithPath: filePath)
        
        // type convert
//        let str = "{\"status\":\"ok\",\"content\":1071557556647755776,\"errorCode\":null,\"errorMsg\":null}"
//        let data = Data(bytes: str.cString(using: .utf8) ?? [], count: str.count)
        guard let data = responseData else { return }
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return }
        dataArray.append(dict)
        
        // write
        guard let writableData = try? JSONSerialization.data(withJSONObject: dataArray, options: .prettyPrinted) else { return }
        do {
            try writableData.write(to: fileUrl, options: .atomic)
        } catch let error {
            print(error)
        }
        
        DispatchQueue.main.async {
            self.label.text = String(format: "%d", self.dataArray.count)
        }
//        guard let result = try? writableData.write(to: fileUrl, options: .atomic) else { return }
//        print(result)
//        guard let result = try? str.write(toFile: filePath, atomically: true, encoding: .utf8) else { return }
//        str.write(to: URL(), atomically: true, encoding: .utf8)
    }
    
    func networkRequestIdGenerator(complete: ((Data?, URLResponse?, Error?) -> (Void))?) {
        guard let url = URL(string: "http://idgenerator.ndev.imdada.cn/seq") else { return }
        let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: TimeInterval.infinity)
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (data, response, error) in
            complete?(data, response, error)
        }.resume()
    }
    
    @objc
    func loopRequest() {
        networkRequestIdGenerator { (data, response, error) -> (Void) in
            if error == nil {
                self.writeToFile(responseData: data)
            }
        }
        perform(#selector(self.loopRequest), with: nil, afterDelay: 3)
    }

//    @objc
//    func loopRequest2() {
//        networkRequestIdGenerator { (data, response, error) -> (Void) in
//            self.writeToFile(responseData: data)
//            DispatchQueue.main.async {
//                self.label.text = String(format: "%d", self.times)
//            }
//
//        }
//        perform(#selector(self.loopRequest), with: nil, afterDelay: 1)
//    }

}

