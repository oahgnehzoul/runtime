//
//  People.h
//  runtime
//
//  Created by oahgnehzoul on 16/9/12.
//  Copyright © 2016年 llzzzhh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface People : NSObject<NSCoding>
{
    NSString *_occupation;
    NSString *_nationality;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger age;

- (NSDictionary *)allProperties;
- (NSDictionary *)allIvars;
- (NSDictionary *)allMethods;

//生成 model
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
//转换成字典
- (NSDictionary *)convertToDictionary;

- (void)sing;

@end
