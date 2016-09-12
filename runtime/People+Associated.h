//
//  People+Associated.h
//  runtime
//
//  Created by oahgnehzoul on 16/9/12.
//  Copyright © 2016年 llzzzhh. All rights reserved.
//

#import "People.h"

@interface People (Associated)
//胸围
@property (nonatomic, strong) NSNumber *associatedBust;
//coding
@property (nonatomic, copy) void(^associatedCallBack)();

@end
