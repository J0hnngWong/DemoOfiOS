//
//  ViewController.swift
//  SwiftMD5Demo
//
//  Created by 王嘉宁 on 2020/7/24.
//  Copyright © 2020 Johnny. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let bytes = 301.convertToBytes(capacity: 10)
        
        let test = MD5()
        test.preProcessMessage()
    }


}

extension Int {
    func convertToBytes(capacity: Int) -> [UInt8] {
        let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        pointer.pointee = self
        
        // 转换指针类型
        let pointerBytes = pointer.withMemoryRebound(to: UInt8.self, capacity: capacity) { (bytePointer) -> [UInt8] in
            var result = [UInt8](repeating: 0, count: capacity)
            for index in 0..<capacity {
                result.append((bytePointer + index).pointee)
            }
            return result
        }
        
        pointer.deinitialize(count: 1)
        pointer.deallocate()
        
        return pointerBytes.reversed()
    }
}


class MD5 {
    
    // [UInt8]是因为swift里面data和uint8可以互相转换，可以通过打印Data对象的实例来验证
    var message: [UInt8] = []
    
    func calculateMD5() {
        
    }
    
    func preProcessMessage() {
        // 512 / 8 = 64, 448 / 8 = 56
        if message.count%64 == 56 {
            // 获取十进制的长度
            let messageLength = message.count * 8
            
            // 十进制的长度转换为UInt8的长度
            let messageLengthTmp = messageLength.convertToBytes(capacity: 64 / 8)
            // 将UInt8的长度拼到后面
            message += messageLengthTmp
            
        } else {
            
        }
    }
    
}
