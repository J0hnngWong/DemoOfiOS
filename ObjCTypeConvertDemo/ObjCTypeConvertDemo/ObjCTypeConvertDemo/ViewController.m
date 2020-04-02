//
//  ViewController.m
//  ObjCTypeConvertDemo
//
//  Created by 王嘉宁 on 2020/4/2.
//  Copyright © 2020 王嘉宁. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testString];
}

- (void)testString
{
    //把值变量或常量直接赋值给对象变量会报错，反之不会
    
    //orderId是String直接赋值给UInt
    NSString *orderIdStr1 = @"9102384927319373840";
    NSUInteger orderIdInt1 = orderIdStr1;
    NSLog(@"\n 1 \n str: %@ \n long: %lu", orderIdStr1, orderIdInt1);
 
      //orderId是UInt直接赋值给String 会报错
//    NSUInteger orderIdInt1_1 = 9102384927319373840;
//    NSString *orderIdStr1_1 = orderIdInt1_1;
//    NSLog(@"\n 1 \n str: %@ \n long: %ld", orderIdStr1_1, orderIdInt1_1);
    
    
    //number from object
    //orderId 是 uint使用NSNumber直接赋值
    NSUInteger orderIdInt2 = 9102384927319373840;
    NSString *orderIdStr2 = [[NSNumber alloc] initWithUnsignedLong:orderIdInt2];
    NSLog(@"\n 2 \n str: %@ \n long: %lu", orderIdStr2, orderIdInt2);
    
    // orderId 是uint转换NSNumber在转换string
    NSUInteger orderIdInt3 = 9102384927319373840;
    NSString *orderIdStr3 = [[NSNumber alloc] initWithUnsignedLong:orderIdInt3].stringValue;
    NSLog(@"\n 3 \n str: %@ \n long: %lu", orderIdStr3, orderIdInt3);
    
    //number from object orderId 是string 转换为number再转换string
    NSString *orderIdStr4 = @"9102384927319373840";
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSString *orderIdStr4_1 = [formatter numberFromString:orderIdStr4].stringValue;
    NSLog(@"\n 4 \n str: %@ \n str str: %@", orderIdStr4, orderIdStr4_1);
    
    // orderId 是uint 直接使用@()来转换为nsnumber
    NSUInteger orderIdInt5 = 9102384927319373840;
    NSString *orderIdStr5 = @(orderIdInt5);
    NSLog(@"\n 5 \n str: %@ \n long: %lu", orderIdStr5, orderIdInt5);
    
    //number from object orderId 是string 转换为number再转换string 超过长度
    NSString *orderIdStr6 = @"910238492731937384023424317236479216391699102384927319373840234243172364792163916991023849273193738402342431723647921639169910238492731937384023424317236479216391699102384927319373840234243172364792163916991023849273193738402342431723647921639169910238492731937384023424317236479216391699102384927319373840123";//最长308位 否则就是nil(null)
    NSString *orderIdStr6_1 = [formatter numberFromString:orderIdStr6].stringValue;
    NSLog(@"\n 6 \n str: %@ \n str str: %@", orderIdStr6, orderIdStr6_1);
    
    //对于id 类型的问题
    NSString *orderIdStr7 = @"9102384927319373840";
    id x = orderIdStr7;
    NSUInteger orderIdInt7 = x;
    NSLog(@"\n 7 \n str: %@ \n long: %lu", orderIdStr7, orderIdInt7);
}


@end
