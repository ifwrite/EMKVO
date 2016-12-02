//
//  main.m
//  checkKVO
//
//  Created by 苏亮 on 2016/12/2.
//  Copyright © 2016年 Emir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface TestClass : NSObject

@property (assign, nonatomic) NSInteger x;
@property (assign, nonatomic) NSInteger y;
@property (assign, nonatomic) NSInteger z;

@end

@implementation TestClass
@end

/**
 返回类所有方法名字数组

 @param c 类
 @return 返回类所有方法名字数组
 */
static NSArray *ClassMethodsNames(Class c) {
    
    NSMutableArray *arr = [NSMutableArray array];
    unsigned int methodCount = 0;
    
    //获取类c的所有方法列表，methodList数组中元素包含了函数的名称、参数、返回值等信息。
    Method *methodList = class_copyMethodList(c, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        
        //arr存储了所有方法名
        [arr addObject:NSStringFromSelector(method_getName(methodList[i]))];
    }
    free(methodList);
    
    return arr;
}

/**
 * @brief 打印obj实例具体信息，
 * class_getName：实例所属类
 * object_getClass： 实例isa指向
 */
static void PrintDescription(NSString *name, id obj) {
    
    NSArray *methodNames = ClassMethodsNames(object_getClass(obj));
    
    NSString *str = [NSString stringWithFormat:
                     @"%@: %@\n\tNSObject class %s\n\tlibobjc class %@\n\timplements methods <%@>",
                     name,
                     obj,
                     class_getName([obj class]),
                     object_getClass(obj),
                     [methodNames componentsJoinedByString:@", "]];
    printf("%s\n", [str UTF8String]);
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
     
        TestClass *x = [[TestClass alloc] init];
        TestClass *y = [[TestClass alloc] init];
        TestClass *xy = [[TestClass alloc] init];
        TestClass *control = [[TestClass alloc] init];
        
        [x addObserver:x forKeyPath:@"x" options:0 context:NULL];
        [xy addObserver:xy forKeyPath:@"x" options:0 context:NULL];
        [y addObserver:y forKeyPath:@"y" options:0 context:NULL];
        [xy addObserver:xy forKeyPath:@"y" options:0 context:NULL];
        
        PrintDescription(@"control", control);
        PrintDescription(@"x", x);
        PrintDescription(@"y", y);
        PrintDescription(@"xy", xy);
        
        printf("Using NSObject methods, normal setX: is %p, overridden setX: is %p\n",
               [control methodForSelector:@selector(setX:)],
               [x methodForSelector:@selector(setX:)]);
        printf("Using libobjc functions, normal setX: is %p, overridden setX: is %p\n",
               method_getImplementation(class_getInstanceMethod(object_getClass(control),
                                                                @selector(setX:))),
               method_getImplementation(class_getInstanceMethod(object_getClass(x),
                                                                @selector(setX:))));
    }
    return 0;
}



