//
//  Bird.m
//  runtime
//
//  Created by oahgnehzoul on 16/9/13.
//  Copyright © 2016年 llzzzhh. All rights reserved.
//

#import "Bird.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "People.h"

@implementation Bird

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"sing"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    People *cangTeacher = [[People alloc] init];
    cangTeacher.name = @"丑八怪";
    [anInvocation invokeWithTarget:cangTeacher];
}



@end
