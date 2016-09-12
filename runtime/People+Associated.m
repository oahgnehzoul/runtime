//
//  People+Associated.m
//  runtime
//
//  Created by oahgnehzoul on 16/9/12.
//  Copyright © 2016年 llzzzhh. All rights reserved.
//

#import "People+Associated.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation People (Associated)

- (void)setAssociatedBust:(NSNumber *)associatedBust {
    //设置关联对象
    objc_setAssociatedObject(self, @selector(associatedBust), associatedBust, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)associatedBust {
    //得到关联对象
    return objc_getAssociatedObject(self, @selector(associatedBust));
}


- (void)setAssociatedCallBack:(void (^)())associatedCallBack {
    objc_setAssociatedObject(self, @selector(associatedCallBack), associatedCallBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)())associatedCallBack {
    return objc_getAssociatedObject(self, @selector(associatedCallBack));
}

@end
