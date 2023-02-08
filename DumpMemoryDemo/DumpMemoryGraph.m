//
//  DumpMemoryGraph.m
//  qosTest
//
//  Created by john on 2023/2/7.
//

#import "DumpMemoryGraph.h"
#import <Foundation/Foundation.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>
#import <malloc/malloc.h>
#import <objc/runtime.h>

//https://github.com/FLEXTool/FLEX/blob/master/Classes/Utility/FLEXHeapEnumerator.m

static CFMutableSetRef registeredClasses;
static CFMutableArrayRef classMemoryList;

typedef struct {
    char *name;
    unsigned long size;
} class_memory_item;

class_memory_item **class_memory_list;
unsigned long class_memory_list_count = 0;

typedef struct {
    Class isa;
} maybe_class_type;

typedef void check_memory_zone_function(__unsafe_unretained id object, __unsafe_unretained Class actualClass);

kern_return_t memory_reader(task_t remote_task, vm_address_t remote_address, vm_size_t size, void **local_memory) {
    *local_memory = (void *)remote_address;
    return KERN_SUCCESS;
}

void range_callback(task_t task, void * context, unsigned type, vm_range_t *ranges, unsigned rangeCount) {
    for (unsigned int i = 0; i < rangeCount; i++) {
        vm_range_t range = ranges[i];
        maybe_class_type *tryObject = (maybe_class_type *)range.address;
        Class tryClass = NULL;
#ifdef __arm64__
        extern uint64_t objc_debug_isa_class_mask WEAK_IMPORT_ATTRIBUTE;
        tryClass = (__bridge Class)((void *)((uint64_t)tryObject->isa & objc_debug_isa_class_mask));
#else
        tryClass = tryObject->isa;
#endif
        if (CFSetContainsValue(registeredClasses, (__bridge const void *)(tryClass))) {
            (*(check_memory_zone_function __unsafe_unretained *)context)((__bridge id)tryObject, tryClass);
            class_memory_item *item = malloc(sizeof(class_memory_item));
            item->name = malloc(sizeof(char *));
            item->size = range.size;
//            if (!class_memory_list) {
//                class_memory_list = &item;
//            } else {
//                class_memory_list[class_memory_list_count++] = item;
//            }
            printf("class: %s, size: %lu\n", class_getName(tryClass), range.size);
            if (strcmp(class_getName(tryClass), "qosTest.ViewController") == 0) {
                unsigned int property_count;
                objc_property_t *properties = class_copyPropertyList(tryClass, &property_count);
                printf("find");
            }
            free(item);
            
//            CFIndex list_count = CFArrayGetCount(classMemoryList);
//            CFIndex upper_bound = list_count - 1;
//            CFIndex lower_bound = 0;
//            CFIndex current_index = (lower_bound + upper_bound) / 2;
//            while (upper_bound > lower_bound) {
//                class_memory_item *current_item = (void *)CFArrayGetValueAtIndex(classMemoryList, current_index);
//                if (upper_bound - lower_bound == 1) {
//                    CFArrayInsertValueAtIndex(classMemoryList, upper_bound, &item);
//                    break;
//                } else if (item.size > current_item->size) {
//                    lower_bound = current_index;
//                    current_index = (lower_bound + upper_bound) / 2;
//                    continue;
//                } else if (item.size < current_item->size) {
//                    upper_bound = current_index;
//                    current_index = (lower_bound + upper_bound) / 2;
//                    continue;
//                } else if (item.size == current_item->size) {
//                    CFArrayInsertValueAtIndex(classMemoryList, current_index, &item);
//                    break;
//                }
//            }
            
//            printf("class: %s, size: %lu\n", class_getName(tryClass), range.size);
        }
    }
}

void check_memory_zone(__unsafe_unretained id object, __unsafe_unretained Class actualClass) {
//    printf("object: %s class: %s", object, actualClass);
//    printf("check_memory_zone");
}

void dump_current_memory_info(void) {
    if (!registeredClasses) {
        registeredClasses = CFSetCreateMutable(NULL, 0, NULL);
    } else {
        CFSetRemoveAllValues(registeredClasses);
    }
    unsigned int class_count = 0;
    Class *classes = objc_copyClassList(&class_count);
    for (unsigned int i = 0; i < class_count; i++) {
        CFSetAddValue(registeredClasses, (__bridge const void *)classes[i]);
//        printf("register class: %s\n", class_getName(classes[i]));
    }
    free(classes);
    
    if (!classMemoryList) {
        classMemoryList = CFArrayCreateMutable(NULL, 0, NULL);
    } else {
        CFArrayRemoveAllValues(classMemoryList);
    }
    
    mach_port_t task = mach_task_self();
    vm_address_t address = 0;
    vm_size_t size = 0;
    natural_t nesting_depth = 1;
//    vm_region_recurse_info_t info;
    struct vm_region_submap_info_64 info;
    mach_msg_type_number_t infoCnt = VM_REGION_SUBMAP_INFO_COUNT_64;
    // Darwin.Mach.vm_map
    kern_return_t krc = vm_region_recurse_64(task, &address, &size, &nesting_depth, (vm_region_info_64_t)&info, &infoCnt);
    
//    memory_reader_t memory_reader;
    vm_address_t *address_pointer = NULL;
    unsigned int zone_count = 0;
    kern_return_t zone_krc = malloc_get_all_zones(TASK_NULL, &memory_reader, &address_pointer, &zone_count);
    KERN_SUCCESS;
    printf("%d", krc);
    printf("%d", zone_krc);
    
    for (int i = 0; i < zone_count; i++) {
        malloc_zone_t *zone = (malloc_zone_t *)address_pointer[i];
        if (zone->introspect && zone->introspect->enumerator) {
            kern_return_t enumerator_zone_krc = zone->introspect->enumerator(TASK_NULL, (void *)&check_memory_zone, MALLOC_PTR_IN_USE_RANGE_TYPE, (vm_address_t)zone, memory_reader, &range_callback);
            printf("%d", enumerator_zone_krc);
        }
    }
    
    unsigned long list_count = CFArrayGetCount(classMemoryList);
    for (CFIndex i = 0; i < list_count; i++) {
        class_memory_item *current_item = (void *)CFArrayGetValueAtIndex(classMemoryList, i);
        printf("class: %s, size: %lu\n", current_item->name, current_item->size);
    }
    
    printf("dump end");
}

@implementation DumpMemoryGraph

+ (void)dump {
    dump_current_memory_info();
}

@end
