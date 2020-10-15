//
//  ViewController.m
//  LockDemo
//
//  Created by 王嘉宁 on 2020/10/14.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSLock *lock;
@property (strong, nonatomic) NSConditionLock *conditionLock;
@property (strong, nonatomic) NSRecursiveLock *recursiveLock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSLock
    self.lock = [[NSLock alloc] init];
    [self.lock addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.lock addObserver:self forKeyPath:@"priv" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    // NSConditionLock
    self.conditionLock = [[NSConditionLock alloc] initWithCondition:0];
    // NSRecursiveLock
    self.recursiveLock = [[NSRecursiveLock alloc] init];
    // NSCondition
    
    // @synchronized
    // dispatch_semphore
    // pthread_mutex
    // OSSpinLock
    
    // NSLock
//    [self lockDemo];
    // NSConditionLock
//    [self conditionLockDemo];
    // NSRecursiveLock
    [self recursiveLockDemo];
    // NSCondition
    
    // @synchronized
    // dispatch_semphore
    // pthread_mutex
    // OSSpinLock
}


- (void)lockDemo {
    
    // lock 加锁，unlock解锁，会阻塞当前线程，一个线程中不能重复加锁，否则会导致资源无法释放会导致死锁，加锁之后后续加入的任务会以FIFO队列的形式添加到任务中，当解锁的时候会从队列中取出第一个任务执行
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.lock lock];
//        [self.lock lock];
        NSLog(@"线程1");
        sleep(2);
        [self.lock unlock];
        NSLog(@"线程1解锁");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1); // 以保证让线程2的代码后执行
        [self.lock lock];
        NSLog(@"线程2");
        [self.lock unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        sleep(1);
        [self.lock lock];
        NSLog(@"线程3");
        [self.lock unlock];
    });
    
    // 尝试加锁，失败会返回NO，不会阻塞当前线程
//    [self.lock tryLock];
    // 在指定日期之前加锁，如果指定日期之前加锁失败会返回NO，否则返回YES，尝试加锁的时候会阻塞当前线程
//    [self.lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)conditionLockDemo {
    
    // 比正常的锁多了condition属性，每个方法都多一个带condition的参数的方法，lockWhenCondition的时候只有满足条件才会加锁，unlockWithCondition是解锁为特定条件，无论是否加锁直接调用这个方法都会将当前条件改为特定条件，可以用于多个任务的先后顺序的互相依赖，其余逻辑通NSLock锁
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.conditionLock lockWhenCondition:1];
        NSLog(@"线程1");
        sleep(2);
        [self.conditionLock unlockWithCondition:2];
        
//        if ([self.conditionLock lockWhenCondition:1 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]]) {
//            NSLog(@"线程1");
//            sleep(2);
//        } else {
//            NSLog(@"线程1加锁失败");
//        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        if ([self.conditionLock tryLockWhenCondition:3]) {
            NSLog(@"线程2");
            [self.conditionLock unlockWithCondition:2];
            NSLog(@"线程2解锁成功");
        } else {
            NSLog(@"线程2加锁失败");
        }
        
//        if ([self.conditionLock tryLock]) {
//            NSLog(@"线程2");
//            [self.conditionLock unlock];
//            NSLog(@"线程2解锁成功");
//        } else {
//            NSLog(@"线程2加锁失败");
//        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        [self.conditionLock lockWhenCondition:0];
        NSLog(@"线程3");
        sleep(2);
        [self.conditionLock unlockWithCondition:1];
        NSLog(@"线程3解锁成功");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(3);
        [self.conditionLock lockWhenCondition:2];
        NSLog(@"线程4");
        sleep(2);
        [self.conditionLock unlockWithCondition:3];
        NSLog(@"线程4解锁成功");
    });
    
    // 与lock方法类似，加锁失败会一直阻塞当前线程，直到条件被满足会立即加锁，
//    [self.conditionLock lockWhenCondition:1];
    // 在指定日期之前加锁，如果指定日期之前加锁失败会返回NO，否则返回YES，尝试加锁的时候会阻塞当前线程
//    [self.conditionLock lockWhenCondition:1 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
}

- (void)recursiveLockDemo {
    
    // 会记录上锁和解锁的次数，当二者平衡的时候，才会释放锁，其它线程才可以上锁成功
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        id<NSLocking> lock = self.recursiveLock;
        
        static void (^recursiveBlock)(int);
        recursiveBlock = ^(int count) {
            NSLog(@"递归第%d层加锁", count);
            [lock lock];
            if (count > 0) {
                recursiveBlock(count - 1);
            }
            [lock unlock];
            NSLog(@"递归第%d层解锁成功", count);
        };
        recursiveBlock(3);
        NSLog(@"线程%@ 执行结束", NSThread.currentThread);
    });
}

void printThread() {
    NSLog(@"当前线程: %@", [NSThread currentThread]);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (object == self.lock) {
        NSLog(@"keyPath : %@, change to : %@ \n", keyPath, change[NSKeyValueChangeNewKey]);
    }
}


@end
