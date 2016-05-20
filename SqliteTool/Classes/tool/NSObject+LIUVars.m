//
//  NSObject+LIUProperty.m
//  SqliteTool
//
//  Created by 劉裕 on 30/4/2016.
//  Copyright © 2016年 劉裕. All rights reserved.
//

#import "NSObject+LIUVars.h"
#import <objc/runtime.h>

@implementation NSObject (LIUVars)

+ (NSArray *)vars {
    NSMutableArray *varsArrayM = [NSMutableArray array];
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    @onExit {
        free(ivars);
    };
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString *name = [@(ivar_getName(ivar)) substringFromIndex:1];
        name = [name lowercaseString];
        NSString *type = @(ivar_getTypeEncoding(ivar));
        LIUVarCode *var = [LIUVarCode new];
        if ([self integerType:type]) {
            var.typeCode = @"%d";
            type = @"integer";
            var.type = type;
        } else if ([self realType:type]) {
            var.typeCode = @"%g";
            type = @"real";
            var.type = type;
        } else {
            // \x40 表示 64 位 ASCII 的 @ 符号
            if ([type isEqualToString:@"\x40\"NSString\""] || [type isEqualToString:@"\x40\"NSNumber\""]) {
                type = @"text";
                var.type = type;
            } else {
                type = @"blob";
                var.type = type;
            }
            var.typeCode = @"%@";
        }
        NSString *tmpStr = [NSString stringWithFormat:@"%@ %@,", name, type];
        var.name = name;
        var.wholeStr = tmpStr;
        var.ivar = ivar;
        [varsArrayM addObject:var];
    }
    
    return varsArrayM;
}

+ (BOOL)integerType:(NSString *)type {
    if ([type isEqualToString:@"i"] || [type isEqualToString:@"s"] || [type isEqualToString:@"l"] || [type isEqualToString:@"q"] || [type isEqualToString:@"c"] || [type isEqualToString:@"b"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)realType:(NSString *)type {
    if ([type isEqualToString:@"f"] || [type isEqualToString:@"d"]) {
        return YES;
    }
    return NO;
}

@end
