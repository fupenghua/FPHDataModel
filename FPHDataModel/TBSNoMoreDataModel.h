//
//  TBSNoMoreDataModel.h
//  theBeastApp
//
//  Created by 付朋华 on 2018/7/31.
//  Copyright © 2018年 com.thebeastshop. All rights reserved.
//

#import "FPHParentDataModel.h"

@interface TBSNoMoreDataModel : FPHParentDataModel
@property (nonatomic, copy) NSNumber *offset;
@property (nonatomic, copy) NSNumber *limit;
@property (nonatomic, copy) NSNumber *total;

@property (nonatomic, assign) BOOL noMoreData;
@end
