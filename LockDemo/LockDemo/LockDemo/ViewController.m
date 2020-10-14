//
//  ViewController.m
//  LockDemo
//
//  Created by 王嘉宁 on 2020/10/14.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSLock
    // NSConditionLock
    // NSRecursiveLock
    // NSCondition
    
    // @synchronized
    // dispatch_semphore
    // pthread_mutex
    // OSSpinLock
    
    // NSLock
    [self nsLockDemo];
    // NSConditionLock
    // NSRecursiveLock
    // NSCondition
    
    // @synchronized
    // dispatch_semphore
    // pthread_mutex
    // OSSpinLock
}


- (void)nsLockDemo {
    
    NSLock *lock = [[NSLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [lock lock];
        NSLog(@"线程1");
        sleep(2);
        [lock unlock];
        NSLog(@"线程1解锁");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1); // 以保证让线程2的代码后执行
        [lock lock];
        NSLog(@"线程2");
        [lock unlock];
    });
    
    // 尝试加锁，失败会返回NO，不会阻塞当前线程
    [lock tryLock];
    // 在指定日期之前加锁，如果指定日期之前加锁失败会返回NO，否则返回YES，尝试加锁的时候会阻塞当前线程
    [lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}


@end
