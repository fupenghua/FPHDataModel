//
//  FPHParentRequest.h
//  projectModel
//
//  Created by 付朋华 on 16/1/14.
//  Copyright © 2016年 付朋华. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (entity)

- (id)safeBindValue:(NSString *)key;
- (NSString *)safeBindStringValue:(NSString *)key;

@end


@interface NSDictionary (entity)

- (id)safeBindValue:(NSString *)key;
- (NSString *)safeBindStringValue:(NSString *)key;

@end

@interface NSArray (entity)

- (id)objectAtIndexSafe:(NSUInteger)index;

@end



@interface FPHParentDataModel : NSObject

@property (nonatomic,assign) NSInteger code;//服务器返回的状态
@property (nonatomic,strong) NSString *msg;//服务器返回的状态描述
@property (nonatomic,strong) id data;//response中的data
@property (nonatomic,strong) id responseObject;//返回的整个数据

@property (nonatomic,strong) NSError *error;
@property (nonatomic,copy) NSArray *cookies;

@property (nonatomic, copy) NSDictionary *responseHeaders;

//- (NSDictionary *)dictionary;

- (NSArray *)arrayOfModel:(Class)modelClass;
- (NSArray *)arrayOfModel:(Class)modelClass atKeyPath:(NSString *)keyPath;

- (id)model:(Class)modelClass;
- (id)model:(Class)modelClass atKeyPath:(NSString *)keyPath;

+ (NSDictionary *)objectMapping;//子类重写

////////////////
- (NSDictionary *)dataDictionary;//model 转 dic
+ (NSArray *)dictionaryListWithModelList:(NSArray *)modelList;

@end
