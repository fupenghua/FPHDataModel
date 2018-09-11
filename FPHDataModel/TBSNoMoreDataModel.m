//
//  TBSNoMoreDataModel.m
//  theBeastApp
//
//  Created by 付朋华 on 2018/7/31.
//  Copyright © 2018年 com.thebeastshop. All rights reserved.
//

#import "TBSNoMoreDataModel.h"

@implementation TBSNoMoreDataModel
+ (NSDictionary *)objectMapping {
    return @{@"offset":@"offset",
             @"limit":@"limit",
             @"total":@"total"
             };
}

- (BOOL)noMoreData {
    NSInteger total = [self.total integerValue];
    NSInteger offset = [self.offset integerValue];
    NSInteger limit = [self.limit integerValue];
    return total <= offset + limit;
}
@end
