//
//  CustomClass.m
//  runtime
//
//  Created by oahgnehzoul on 16/8/4.
//  Copyright © 2016年 llzzzhh. All rights reserved.
//

#import "CustomClass.h"
#import <objc/runtime.h>
#import "OtherClass.h"
//#import <objc/message.h>
@implementation CustomClass

+ (void)classMethod {
    NSLog(@"classMethod");
}

- (void)InstanceMethod {
    NSLog(@"InstanceMethod");
}
- (void)study {
    NSLog(@"study");
    
//    OtherClass *other = [OtherClass new];
//    [other run];
    
}

+ (void)eat {
    NSLog(@"eat");
}

- (void)run {
    NSLog(@"run");
}
//归档
- (void)encode:(NSCoder *)acoder {
    Class class = self.class;
    while (class && class != [NSObject class]) {
        unsigned int outCount = 0;
        Ivar *ivars = class_copyIvarList(class, &outCount);
        for (int i = 0; i < outCount; i++) {
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
            
            if ([self respondsToSelector:@selector(ignoredNames)]) {
                if ([[self ignoredNames] containsObject:key]) {
                    continue;
                }
            }
            
            id value = [self valueForKeyPath:key];
            [acoder encodeObject:value forKey:key];
        }
        free(ivars);
        class = [class superclass];
    }
}
//解档
- (void)decode:(NSCoder *)aDecoder {
    Class class = self.class;
    while (class && class != [NSObject class]) {
        unsigned int outCount = 0;
        Ivar *ivars = class_copyIvarList(class, &outCount);
        for (int i = 0; i < outCount; i++) {
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
            
            if ([self respondsToSelector:@selector(ignoredNames)]) {
                if ([[self ignoredNames] containsObject:key]) {
                    continue;
                }
            }
            
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivars);
        class = [class superclass];
    }
}

//- (void)encodeWithCoder:(NSCoder *)aCoder {
//	
//}
//
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    if (self = [super initWithCoder:aDecoder]) {
//        
//    }
//    return self;
//}


- (NSArray *)ignoredNames {
    return @[@"_aaa,",@"_bbb"];
}







@end

@implementation CustomClass (Custom)

char ageKey;

- (void)setAge:(NSUInteger)age {
    objc_setAssociatedObject(self, &ageKey, @(age), OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)age {
    return [objc_getAssociatedObject(self, &ageKey) integerValue];
}

@end