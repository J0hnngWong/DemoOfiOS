//
//  DumpMemoryGraph.h
//  qosTest
//
//  Created by john on 2023/2/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void dump_current_memory_info(void);

@interface DumpMemoryGraph : NSObject

+ (void)dump;

@end

NS_ASSUME_NONNULL_END
