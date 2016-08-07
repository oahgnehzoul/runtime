//
//  main.m
//  runtime
//
//  Created by oahgnehzoul on 16/8/4.
//  Copyright © 2016年 llzzzhh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "CustomClass.h"

int main(int argc, const char * argv[]) {

//    class_getClassMethod([CustomClass class], <#SEL name#>)
    
//    class_getInstanceMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>)

//    method_exchangeImplementations(<#Method m1#>, <#Method m2#>)
    
    method_exchangeImplementations(class_getInstanceMethod([CustomClass class], @selector(run)), class_getInstanceMethod([CustomClass class], @selector(study)));
    
    CustomClass *c = [CustomClass new];
    [c run];
    [c study];
    
    objc_msgSend(c, @selector(run));
//    objc_msgSend(<#id self#>, <#SEL op, ...#>) \
    根据方法编号SEL找到映射表中对应的IMP，然后实现方法调用
    objc_msgSend([CustomClass class], @selector(eat));
    
    c.age = 10;
    NSLog(@"%lu",c.age);
    
    unsigned int outCount = 0;
    //获取某个类的所有属性，outCount返回成员变量个数
    Ivar *ivars = class_copyIvarList([CustomClass class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        const char *name = ivar_getName(ivars[i]);
        const char *type = ivar_getTypeEncoding(ivars[i]);
        NSLog(@"name:%s,type:%s",name,type);
    }
    free(ivars);
    
    
    return 0;
}
