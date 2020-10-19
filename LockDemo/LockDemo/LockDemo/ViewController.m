//
//  ViewController.m
//  LockDemo
//
//  Created by 王嘉宁 on 2020/10/14.
//

#import "ViewController.h"
#import <libkern/OSSpinLockDeprecated.h>
#import "pthread.h"

static pthread_mutex_t pthread_mutex_locker;

@interface ViewController ()

@property (strong, nonatomic) NSLock *lock;
@property (strong, nonatomic) NSConditionLock *conditionLock;
@property (strong, nonatomic) NSRecursiveLock *recursiveLock;
@property (strong, nonatomic) NSCondition *condition;

@property (strong, nonatomic) NSMutableArray *synchronizeArray;
@property (strong, nonatomic) dispatch_semaphore_t dispatch_semaphore_lock;
@property (copy, nonatomic) NSString *networkResult;
@property (assign, nonatomic) OSSpinLock spinLock;

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
    self.condition = [[NSCondition alloc] init];
    
    // @synchronized
    // dispatch_semphore
    self.dispatch_semaphore_lock = dispatch_semaphore_create(1);
    // pthread_mutex
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_ERRORCHECK);
//    pthread_mutex_init(&pthread_mutex_locker, &attr);
    pthread_mutex_init(&pthread_mutex_locker, NULL);
    // OSSpinLock
    self.spinLock = OS_SPINLOCK_INIT;
    
    
    // NSLock
//    [self lockDemo];
    // NSConditionLock
//    [self conditionLockDemo];
    // NSRecursiveLock
//    [self recursiveLockDemo];
    // NSCondition
    [self conditionDemo];
    
    // @synchronized
//    [self synchronizedDemo];
    // dispatch_semphore
//    [self dispatch_semphoreDemo];
    // pthread_mutex
//    [self pthread_mutexDemo];
    // OSSpinLock
//    [self oSSpinLockDemo];
    
    unsigned long long a = ~0ull;
    NSLog(@"end");
    
    
    // NSLock（互斥锁）
    // 实现原理实际是在底层封装了一个属性为PTHREAD_MUTEX_ERRORCHECK的pthread_mutex 带错误提示的锁，损失一定性能换来错误提示
    // NSCondition （互斥锁+条件变量）
    // 底层是通过条件变量pthread_cond_t实现的
    // NSRecursiveLock （互斥锁）
    // 底层实现pthread_mutex_lock的recursive类型
    // NSConditionLock （互斥锁+条件变量）
    // 
    
    // pthread_mutex 是互斥锁
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

- (void)conditionDemo {
    NSMutableArray *array = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.condition lock];
        while (!array.count) {
            NSLog(@"数组没有元素");
            [self.condition wait];
            NSLog(@"线程1等待结束");
        }
        [array removeAllObjects];
        NSLog(@"移除所有元素");
        [self.condition unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1); // 延迟执行2线程
        [self.condition lock];
        [array addObject:@1];
        NSLog(@"线程2增加array 1个元素");
        [self.condition signal];
        [self.condition unlock];
    });
    
    
    // wait方法会让当前线程直接进入等待，不会像之前的锁导致当前线程先轮询再等待，waitUntilDate相当于设定一个超时时间点，到了时间就会返回
//    [self.condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    // signal 只是一个信号量，只能唤醒一个等待的线程，想唤醒多个就得多次调用，而 broadcast 可以唤醒所有在等待的线程。如果没有等待的线程，这两个方法都没有作用。
//    [self.condition broadcast];
}

- (void)synchronizedDemo {
    
    // @synchronized(object) 中的 object 为该锁的唯一标识，只有当标识相同时，才满足互斥, 不同时则不会互斥
    // @synchronized 指令实现锁的优点就是我们不需要在代码中显式的创建锁对象，便可以实现锁的机制，但作为一种预防措施，@synchronized 块会隐式的添加一个异常处理例程来保护代码，该处理例程会在异常抛出的时候自动的释放互斥锁。@synchronized 还有一个好处就是不用担心忘记解锁了
    
    // 如果在 @sychronized(object){} 内部 object 被释放或被设为 nil，从测试的结果来看，基本没有问题，但如果 object 一开始就是 nil，则失去了锁的功能。不过虽然 nil 不行，但 @synchronized([NSNull null]) 是完全可以的
    
//    if (self.synchronizeArray == nil) {
//        self.synchronizeArray = [NSMutableArray array];
//    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        @synchronized (self) {
//            sleep(2);
//            NSLog(@"线程1");
//        }
        
        @synchronized (self.synchronizeArray) {
            sleep(2);
            self.synchronizeArray = nil;
            NSLog(@"线程1");
        }
        
//        @synchronized ([NSNull null]) {
//            sleep(2);
//            NSLog(@"线程1");
//        }
        
        NSLog(@"线程1解锁成功");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
//        @synchronized (self) {
//            NSLog(@"线程2");
//        }
        
        @synchronized (self.synchronizeArray) {
            NSLog(@"线程2");
        }
        
//        @synchronized ([NSNull null]) {
//            NSLog(@"线程2");
//        }
        
    });
}

- (void)dispatch_semphoreDemo {
    
    // dispatch_semaphore 和 NSCondition 类似，都是一种基于信号的同步方式，但 NSCondition 信号只能发送，不能保存（如果没有线程在等待，则发送的信号会失效）。而 dispatch_semaphore 能保存发送的信号。dispatch_semaphore 的核心是 dispatch_semaphore_t 类型的信号量。

    // dispatch_semaphore_create(1) 方法可以创建一个 dispatch_semaphore_t 类型的信号量，设定信号量的初始值为 1。注意，这里的传入的参数必须大于或等于 0，否则 dispatch_semaphore_create 会返回 NULL。

    // dispatch_semaphore_wait(signal, overTime); 方法会判断 signal 的信号值是否大于 0。大于 0 不会阻塞线程，消耗掉一个信号，执行后续任务。如果信号值为 0，该线程会和 NSCondition 一样直接进入 waiting 状态，等待其他线程发送信号唤醒线程去执行后续任务，或者当 overTime  时限到了，也会执行后续任务。

    // dispatch_semaphore_signal(signal); 发送信号，如果没有等待的线程接受信号，则使 signal 信号值加一（做到对信号的保存）。 只要调用就直接提升信号量，增加任务数量

    // 从上面的实例代码可以看到，一个 dispatch_semaphore_wait(signal, overTime); 方法会去对应一个 dispatch_semaphore_signal(signal); 看起来像 NSLock 的 lock 和 unlock，其实可以这样理解，区别只在于有信号量这个参数，lock unlock 只能同一时间，一个线程访问被保护的临界区，而如果 dispatch_semaphore 的信号量初始值为 x ，则可以有 x 个线程同时访问被保护的临界区。


    
    dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    
//    DISPATCH_TIME_FOREVER
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(self.dispatch_semaphore_lock, overTime);
        sleep(2);
        NSLog(@"线程1");
        dispatch_semaphore_signal(self.dispatch_semaphore_lock);
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_semaphore_wait(self.dispatch_semaphore_lock, overTime);
        NSLog(@"线程2");
        dispatch_semaphore_signal(self.dispatch_semaphore_lock);
    });
    
//    dispatch_semaphore_signal(self.dispatch_semaphore_lock);
    
    
    
//    [self networkRequest];
//
//    dispatch_semaphore_wait(self.dispatch_semaphore_lock, overTime);
//    NSLog(@"%@", [self getResult]);
//    dispatch_semaphore_signal(self.dispatch_semaphore_lock);
    
}

- (void)networkRequest {
//    [[UIPasteboard generalPasteboard] string];
    dispatch_semaphore_wait(self.dispatch_semaphore_lock, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"请求开始");
        sleep(2);
        self.networkResult = @"成功了";
        NSLog(@"请求结束");
        dispatch_semaphore_signal(self.dispatch_semaphore_lock);
    });
}

- (NSString *)getResult {
    return self.networkResult;
}


- (void)oSSpinLockDemo {
    
    // 可以看到线程1解锁成功与线程2不是在一个时间点打印的，说明spinlock是在进行轮询而不是直接由线程唤醒的
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&(self->_spinLock));
        NSLog(@"线程1");
        sleep(10);
        OSSpinLockUnlock(&(self->_spinLock));
        NSLog(@"线程1解锁成功");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        OSSpinLockLock(&(self->_spinLock));
        NSLog(@"线程2");
        OSSpinLockUnlock(&(self->_spinLock));
    });
    
    // 不再安全的OSSpinLock https://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios/
    
    // 优先级反转问题，先进行高优先级的线程，高优先级线程一直在轮询，使用了大量的时间片导致低优先级的线程拿不到CPU时间从而完成不了任务就会一直阻塞高优先级线程
    // 自旋锁
    BOOL lock = false;
    {
        // 线程1
        // 非临界区代码
        while (lock);
        lock = true;
            // 线程1临界区代码
        lock = false;
            // 非临界区代码
    }
    
    {
        // 线程2
        // 非临界区代码
        while (lock);
        lock = true;
            // 线程2临界区代码
        lock = false;
            // 非临界区代码
    }
    
    // 假设两个线程同时开始while(lock)呢？
    
    // 这个时候就需要加锁操作是原子操作，单处理器的情况下，单条汇编指令一定是多原子操作，多处理器的情况下需要硬件层面上的”锁“ 例如x86平台下在指令前面加LOCK前缀，硬件层面上会在执行这条指令的时候把总线锁住，其他CPU也无法执行相同操作，这就是硬件层面上的原子操作
}

- (void)pthread_mutexDemo {
    
    // 由于 pthread_mutex 有多种类型，可以支持递归锁等，因此在申请加锁时，需要对锁的类型加以判断，这也就是为什么它和信号量的实现类似，但效率略低的原因
    
    // int pthread_mutex_init(pthread_mutex_t * __restrict, const pthread_mutexattr_t * __restrict);
    
    // PTHREAD_MUTEX_NORMAL 缺省类型，也就是普通锁。当一个线程加锁以后，其余请求锁的线程将形成一个等待队列，并在解锁后先进先出原则获得锁。
    
    // PTHREAD_MUTEX_ERRORCHECK 检错锁，如果同一个线程请求同一个锁，则返回 EDEADLK(11)，否则与普通锁类型动作相同。这样就保证当不允许多次加锁时不会出现嵌套情况下的死锁。

    // PTHREAD_MUTEX_RECURSIVE 递归锁，允许同一个线程对同一个锁成功获得多次，并通过多次 unlock 解锁。

    // PTHREAD_MUTEX_DEFAULT 适应锁，动作最简单的锁类型，仅等待解锁后重新竞争，没有等待队列。
    
    pthread_t thread1;
    pthread_create(&thread1, NULL, threadMethod1, NULL);
    
    pthread_t thread2;
    pthread_create(&thread2, NULL, threadMethod2, NULL);
}

void *threadMethod1() {
//    pthread_mutex_lock(&pthread_mutex_locker);
    pthread_mutex_lock(&pthread_mutex_locker);
    printf("线程1\n");
    sleep(2);
    pthread_mutex_unlock(&pthread_mutex_locker);
    printf("线程1解锁成功\n");
    return 0;
}

void *threadMethod2() {
    sleep(1);
    pthread_mutex_lock(&pthread_mutex_locker);
    printf("线程2\n");
    pthread_mutex_unlock(&pthread_mutex_locker);
    return 0;
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
