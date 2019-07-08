//
//  FPHParentRequest.m
//  projectModel
//
//  Created by 付朋华 on 16/1/14.
//  Copyright © 2016年 付朋华. All rights reserved.
//

#import "FPHParentDataModel.h"
#import "RKPropertyInspector.h"

#define SSTypeAssert(var, type) NSAssert([var isKindOfClass:[type class]], @"type Check error, expect %@, return is %@", [type class], [var class]);

#define SSOverrideAssert NSAssert(0, @"Subclass should override This!");

@implementation NSObject (entity)

- (id)safeBindValue:(NSString *)key
{
    NSLog(@"错误对象调用 safeBindValue 调用路径 %@", [NSThread callStackSymbols]);
    return nil;
}

- (NSString *)safeBindStringValue:(NSString *)key
{
    NSLog(@"错误对象调用 safeBindStringValue 调用路径 %@", [NSThread callStackSymbols]);
    return nil;
}


@end


@implementation NSDictionary (entity)

- (id)safeBindValue:(NSString *)key
{
    id result = nil;
    if ([self.allKeys containsObject:key])
    {
        result = [self objectForKey:key];
        result = [result isKindOfClass:[NSNull class]] ? nil : result;
    }
    return result;
}

- (NSString *)safeBindStringValue:(NSString *)key
{
    id result = [self safeBindValue:key];
    if (result)
    {
        return [NSString stringWithFormat:@"%@", result];
    }
    return nil;
}


@end

@implementation NSString (Value)

- (NSString *)stringValue{
    return self;
}

- (NSNumber *)numberValue {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *numTemp = [numberFormatter numberFromString:self];
    return numTemp;
}
@end

@implementation NSNumber (Value)

- (NSNumber *)numberValue {
    NSString *numString = [NSString stringWithFormat:@"%lf", [self doubleValue]];
    NSDecimalNumber *nub = [NSDecimalNumber decimalNumberWithString:numString];
    return nub;
}

- (NSString *)stringValue {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [numberFormatter stringFromNumber:self];
}
@end

@implementation NSArray(entity)

- (id)objectAtIndexSafe:(NSUInteger)index
{
    if ([self count] > index)
    {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end




@implementation FPHParentDataModel




- (NSArray *)arrayOfModel:(Class)modelClass {
    if ([self.data isKindOfClass:[NSArray class]]) {
         return [modelClass modelListWithDictionaryList:self.data];
    } else {
        return nil;
     }
}

+ (NSArray *)modelListWithDictionaryList:(NSArray *)dictList {
    if ([dictList isKindOfClass:[NSArray class]]) {
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:dictList.count];
        for (NSDictionary *dictionary in dictList) {
            if ([dictionary isKindOfClass:[NSDictionary class]]) {
                FPHParentDataModel *item = [self modelFromDictionary:dictionary];
                [list addObject:item];
            }
        }
        return list;
    }
    return nil;
}
+ (NSDictionary *)objectMapping {
    SSOverrideAssert
    return nil;
}
+ (FPHParentDataModel *)modelFromDictionary:(NSDictionary *)dictionary {
    FPHParentDataModel *model = [self new];
    NSDictionary *mapping = [self objectMapping];
    for (NSString *key in mapping) {
        id mapInfo = mapping[key];
        NSString *dictionaryKey;
        if ([mapInfo isKindOfClass:[NSString class]]) {
            dictionaryKey = mapInfo;
        } else if ([mapInfo isKindOfClass:[NSDictionary class]]) {
            dictionaryKey = mapInfo[@"key"];
        } else {
            dictionaryKey = mapInfo[0];
        }
        
         id value = [self getDefaultValueBymapInfo:mapInfo key:dictionaryKey dictionary:dictionary];
        if (value == nil || value == [NSNull null] || ([value isKindOfClass:[NSArray class]] && [(NSArray *)value count] == 0)) {
            continue;
        }
        Class propertyClass = RKPropertyInspectorGetClassForPropertyAtKeyPathOfObject(key, model);
        NSAssert(propertyClass != nil, @"Object Mapping error, property not exist");

        if ([propertyClass isSubclassOfClass:[NSString class]]) {
            
            value = [value stringValue];
        } else if ([propertyClass isSubclassOfClass:[NSNumber class]]) {
            value = [value numberValue];
        } else if ([propertyClass isSubclassOfClass:[NSArray class]]) {
            if ([mapInfo isKindOfClass:[NSString class]]) {
                value = value;
            } else {
                SSTypeAssert(value, NSArray);
                Class modelClass = mapInfo[1];
                value = [modelClass modelListWithDictionaryList:value];
            }
        } else if ([propertyClass isSubclassOfClass:[FPHParentDataModel class]]) {
            SSTypeAssert(value, NSDictionary);
            value = [propertyClass modelFromDictionary:value];
        } else if ([propertyClass isSubclassOfClass:[NSDictionary class]]){
            value = value;
        } else {
            NSAssert(0, @"type for model not valid, it should be one of NSString/NSNumber/NSArray/NSDictionary, actual type is %@", propertyClass);
        }
        [model setValue:value forKey:key];
    }
    return model;
}

+ (id)getDefaultValueBymapInfo:(id)mapInfo key:(NSString *)key dictionary:(NSDictionary *)dictionary {
    if ([mapInfo isKindOfClass:[NSDictionary class]]) {
        if ([self isExistKeyInDictionary:dictionary key:key]) {
            id value = dictionary[key];
            if (value)
                return value;
        }
        return mapInfo[@"default"];
    } else {
        if ([dictionary isKindOfClass:[NSDictionary class]])
            return dictionary[key];
        else
            return nil;
        
    }
}
+ (BOOL)isExistKeyInDictionary:(NSDictionary *)dictionary key:(NSString *)key {
    BOOL exist = NO;
    for (NSString *subKey in dictionary) {
        if ([subKey isEqualToString:key]) {
            exist = YES;
            break;
        }
    }
    return exist;
}

- (id)model:(Class)modelClass{
    if (self.data) {
        return [modelClass modelFromDictionary:self.data];
    }
    return nil;
}

- (id)model:(Class)modelClass atKeyPath:(NSString *)keyPath {
    NSDictionary *dictionary = self.data;
    NSDictionary *modelDict = [dictionary valueForKeyPath:keyPath];
    if ([modelDict isKindOfClass:[NSDictionary class]]) {
        return [modelClass modelFromDictionary:modelDict];
    }
    return nil;
}


- (NSArray *)arrayOfModel:(Class)modelClass atKeyPath:(NSString *)keyPath {
    NSDictionary *dictionary = self.data;
    NSArray *array = [dictionary valueForKeyPath:keyPath];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return [modelClass modelListWithDictionaryList:array];
    }
    return nil;
}


- (NSDictionary *)dataDictionary {
    NSDictionary *mapping = [self.class objectMapping];
    NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionary];
    for (NSString *key in mapping) {
        id mapInfo = mapping[key];
        NSString *dictionaryKey;
        if ([mapInfo isKindOfClass:[NSString class]]) {
            dictionaryKey = mapInfo;
        } else if ([mapInfo isKindOfClass:[NSDictionary class]]) {
            dictionaryKey = mapInfo[@"key"];
        } else {
            dictionaryKey = mapInfo[0];
        }
        id value = [self valueForKey:key];
        if (value == nil) {
            resultDictionary[dictionaryKey] = [NSNull null];
        } else if ([value isKindOfClass:[FPHParentDataModel class]]){
            resultDictionary[dictionaryKey] = [value dataDictionary];
        } else if ([value isKindOfClass:[NSArray class]]) {
            if ([mapInfo isKindOfClass:[NSString class]]) {
                resultDictionary[dictionaryKey] = value;
            } else {
                Class modelClass = mapInfo[1];
                resultDictionary[dictionaryKey] = [modelClass dictionaryListWithModelList:value];
            }
        } else {
            resultDictionary[dictionaryKey] = value;
        }
    }
    return resultDictionary;
}

+ (NSArray *)dictionaryListWithModelList:(NSArray *)modelList {
    NSMutableArray *dictArray = [NSMutableArray array];
    for (FPHParentDataModel *model in modelList) {
        [dictArray addObject:model.dataDictionary];
    }
    return dictArray;
}



@end
