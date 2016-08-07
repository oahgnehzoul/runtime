//
//  CustomClass.h
//  runtime
//
//  Created by oahgnehzoul on 16/8/4.
//  Copyright © 2016年 llzzzhh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomClass : NSObject {
    int a;
    NSString *b;
    NSNumber *c;
    NSDictionary *d;
    NSArray *e;
}

+ (void)classMethod;

- (void)InstanceMethod;

- (void)run;

- (void)study;

+ (void)eat;
//
//- (instancetype)initWithCorder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;
- (NSArray *)ignoredNames;

- (void)decode:(NSCoder *)aDecoder;
- (void)encode:(NSCoder *)acoder;

@end


@interface CustomClass (Custom)

@property (nonatomic, assign) NSUInteger age;

@end