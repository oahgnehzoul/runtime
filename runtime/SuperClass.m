//
//  SuperClass.m
//  runtime
//
//  Created by oahgnehzoul on 16/9/11.
//  Copyright © 2016年 llzzzhh. All rights reserved.
//

#import "SuperClass.h"
#import "SubClass.h"
#import <objc/runtime.h>

@implementation SuperClass

- (void)aboutClass {
    SubClass *sub = [[SubClass alloc] init];
//    objc_getClass(<#const char *name#>)  返回 id
//    class_getSuperclass(<#__unsafe_unretained Class cls#>)
    NSLog(@"%@,%@",objc_getClass("sub"),class_getSuperclass(objc_getClass("sub")));
}

@end
