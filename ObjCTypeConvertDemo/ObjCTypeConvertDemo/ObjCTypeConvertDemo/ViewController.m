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
    
    NSDictionary *dict1 = @{@"orderId":@(9102384927319373840)};
    NSString * orderIdStr8 = [self orEmptyOrderId:[self stringFromObject:dict1 key:@"orderId"]];
    NSLog(@"\n 8 \n str: %@", orderIdStr8);
    
    NSString *url = @"http://imdada.ndev.com/supplier/order/detail?orderId=9102384927319373840";
    NSString *orderIdStr9 = [self queryStringFromURL:[NSURL URLWithString:url] key:@"orderId"];
    NSLog(@"\n 9 \n str: %@", orderIdStr9);
}

- (void)callTestParameterType
{
    NSString *strParam = @"111";
    NSUInteger intValue = 22123;
//    [self testParameterType:strParam param2:intValue];
    
}

- (void)testParameterType:(NSUInteger)intValue param2:(NSString *)stringValue
{
    
}



- (NSString *)stringFromObject:(NSDictionary *)dictionary key:(NSString *)key {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    
    id object = [dictionary valueForKey:key];
    if ([object isKindOfClass:[NSString class]] &&
        ([self isEmptyString:object] || [@"<null>" isEqualToString:object])) {
        return @"";
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return [object stringValue];
    }
    return @"";
}

- (BOOL)isEmptyString:(NSString *)string
{
    NSCharacterSet *aCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    BOOL isEmpty = ([string isKindOfClass:[NSString class]] && [@"" isEqualToString:[string stringByTrimmingCharactersInSet:aCharacterSet]]);
    return !string || [string isEqual:[NSNull null]] || isEmpty;
}


- (NSString *)orEmptyOrderId:(NSString * _Nullable)str
{
    if ([self isEmptyString:str]) {
        return @"0";
    }
    return str;
}


- (NSString *)queryStringFromURL:(NSURL *)url key:(NSString *)key
{
    if ([self isEmptyString:key] || [self isEmptyString:url.absoluteString]) {
        return @"";
    }
    
    NSRange range = [url.absoluteString rangeOfString:@"?"];
    if (range.location == NSNotFound || url.absoluteString.length <= range.location + range.length) {
        return @"";
    }
    NSString *query = [url.absoluteString substringFromIndex:range.location + 1];
    NSArray *quertItems = [query componentsSeparatedByString:@"&"];
    for (NSString *queryItem in quertItems) {
        NSArray *items = [queryItem componentsSeparatedByString:@"="];
        if ([key isEqualToString:items.firstObject]) {
            return items.lastObject;
        }
    }
    
//    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
//    for (NSURLQueryItem *item in urlComponents.queryItems)
//    {
//        if ([item.name isEqualToString:key]) {
//            return item.value;
//        }
//    }
    return @"";
}

@end


