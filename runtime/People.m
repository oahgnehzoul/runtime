//
//  People.m
//  runtime
//
//  Created by oahgnehzoul on 16/9/12.
//  Copyright © 2016年 llzzzhh. All rights reserved.
//

#import "People.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation People

+ (instancetype)sharedInstance
{
    static People* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [People new];
    });

    return instance;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            const char *ivarName = ivar_getName(ivars[i]);
            NSString *key = [NSString stringWithUTF8String:ivarName];
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
        free(ivars);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        const char *ivarName = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithUTF8String:ivarName];
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
    free(ivars);
}


- (NSDictionary *)allProperties {
    unsigned int count = 0;
    // 获取类的所有属性
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableDictionary *resultDic = @{}.mutableCopy;
    
    for (int i = 0; i < count; i++) {
        // 获取属性的名称和值
        const char *propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        if ([self valueForKey:name]) {
            resultDic[name] = [self valueForKey:name];
        } else {
            resultDic[name] = @"字典 key 对应的 value 不能为 nil";
        }
    }
    // properties 是一个数组指针，需要 free 来释放内存
    free(properties);
    
    return resultDic;
}

- (NSDictionary *)allIvars {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    NSMutableDictionary *resultDic = @{}.mutableCopy;
    for (int i = 0; i < count; i++) {
        const char *ivarName = ivar_getName(ivars[i]);
        NSString *name = [NSString stringWithUTF8String:ivarName];
        if ([self valueForKey:name]) {
            resultDic[name] = [self valueForKey:name];
        } else {
            resultDic[name] = @"字典 key 对应的 value 不能为 nil";
        }
    }
    
    free(ivars);
    
    return resultDic;
}

- (NSDictionary *)allMethods {
    unsigned int count = 0;
    NSMutableDictionary *resultDic = @{}.mutableCopy;
    Method *methods =  class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        // 获取方法名称
        const char *methodName = sel_getName(method_getName(methods[i]));
        NSString *name = [NSString stringWithUTF8String:methodName];
        
        // 获取方法的参数列表
        int arguments = method_getNumberOfArguments(methods[i]);
        resultDic[name] = @(arguments - 2);  //为什么-2？？
    }
    free(methods);
    return resultDic;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        for (NSString *key in dictionary.allKeys) {
            id value = dictionary[key];
            SEL setter = [self propertySetterByKey:key];
            if (setter) {
//                objc_msgSend(self, setter,value);
                ((void(*)(id,SEL,id))objc_msgSend)(self,setter,value);
            }
        }
    }
    return self;
}

- (NSDictionary *)convertToDictionary {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    if (count > 0) {
        NSMutableDictionary *resultDic = @{}.mutableCopy;
        for (int i = 0; i < count; i++) {
            const char *propertyName = property_getName(properties[i]);
            NSString *name = [NSString stringWithUTF8String:propertyName];
            SEL getter = [self propertyGetterByKey:name];
            if (getter) {
                id value = objc_msgSend(self, getter);
                if (value) {
                    resultDic[name] = value;
                } else {
                    resultDic[name] = @"字典的 key 对应的 value 不能为 nil";
                }
            }
        }
        free(properties);
        return resultDic;
    }
    
    free(properties);
    return nil;
}

#pragma mark - private methods setter and getter
// 生成 setterKey: 方法
- (SEL)propertySetterByKey:(NSString *)key {
    NSString *propertySetterName = [NSString stringWithFormat:@"set%@:",key.capitalizedString];
    SEL setter = NSSelectorFromString(propertySetterName);
    if ([self respondsToSelector:setter]) {
        return setter;
    }
    return nil;
}
//生成 Key 方法
- (SEL)propertyGetterByKey:(NSString *)key {
    SEL getter = NSSelectorFromString(key);
    if ([self respondsToSelector:getter]) {
        return getter;
    }
    return nil;
}

#pragma mark - 消息动态解析

// 一、是否动态添加方法，返回 NO 则进入第二步
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if ([NSStringFromSelector(sel) isEqualToString:@"sing"]) {
        class_addMethod(self, sel, (IMP)otherSing, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

void otherSing(id self,SEL cmd) {
    NSLog(@"%@唱歌啦",((People *)self).name);
}
// 二、用于指定备选对象响应这个 sel,不能指定为 self。如果返回对象就会调用对象的方法;如果不指定备选对象响应 aSelector，则进入第三步
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}
// 三、通过 methodSignatureForSelector 方法签名，返回 nil 则消息无法处理，返回 methodSignature 则进入下一步
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"dance"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}
// 四、我们可以通过 anInvocation 对象做很多处理，例如修改实现方法、修改响应对象。方法调用成功则结束；如果失败就会进入 doesNotRecognizeSelector，如果我们没有实现这个方法，就会 crash
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation setSelector:@selector(eat)];
    [anInvocation invokeWithTarget:self];
}
// 如果 forwardInvocation 没有实现，就会调用此方法
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"消息无法处理:%@",NSStringFromSelector(aSelector));
}

- (void)eat {
    NSLog(@"eat come on");
}

@end
