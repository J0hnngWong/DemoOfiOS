//
//  ViewController.m
//  MultiThreadDemo
//
//  Created by 王嘉宁 on 2020/3/27.
//  Copyright © 2020 王嘉宁. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //NSThread 静态工具方法
    // 1. 是否开启了多线程
    BOOL isMultiThreaded = [NSThread isMultiThreaded];
    // 2. 获取当前线程
    NSThread *currentThread = [NSThread currentThread];
    // 3. 获取主线程
    NSThread *mainThread = [NSThread mainThread];
    
    // 4. 睡眠当前线程
    // 4.1 线程睡眠5s
    [NSThread sleepForTimeInterval:2];
    self.view.backgroundColor = UIColor.blueColor;
    // 4.2 线程睡眠到指定时间
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    // 5. 退出当前线程
//    [NSThread exit];
    
    /** NSThread线程对象基本创建，target为入口函数所在的对象，selector为线程入口函数 **/
    /* 1 线程实例对象创建与设置 */
    NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    /* 设置线程优先级threadPriority(0~1.0)，即将被抛弃，将使用qualityOfService代替 */
    newThread.qualityOfService = NSQualityOfServiceBackground;
    /* 开启线程 */
    [newThread start];
    /* 2 静态方法快速创建并开启新线程 */
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"run block : %@", [NSThread currentThread]);
    }];
    /** NSObejct基类隐式创建线程的一些静态工具方法 **/
    /* 1 在当前线程上执行方法，延迟2s */
    [self performSelector:@selector(run) withObject:nil afterDelay:2.0];
    /* 2 在指定线程上执行方法，不等待当前线程 */
    [self performSelector:@selector(run) onThread:newThread withObject:nil waitUntilDone:NO];
    [self performSelector:@selector(run) onThread:newThread withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode, NSRunLoopCommonModes]];
    //about mode https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16
    /* 3 后台异步执行函数 */
    [self performSelectorInBackground:@selector(run) withObject:nil];
    /* 4 在主线程上执行函数 */
    [self performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:NO];
    
    self.view.backgroundColor = UIColor.redColor;
}

- (void)run
{
    NSLog(@"run : %@", [NSThread currentThread]);
}


@end
