//
//  LIUSqliteUnit+LIUCategory.m
//  SqliteTool
//
//  Created by 劉裕 on 1/5/2016.
//  Copyright © 2016年 劉裕. All rights reserved.
//

#import "LIUSqliteUnit+LIUCategory.h"

@implementation LIUSqliteUnit (LIUCategory)

+ (BOOL)liu_sqltool:(void (^)(LIUSqliteUnit *executer))block {
    LIUSqliteUnit *sqliteUnit = [LIUSqliteUnit new];
    block(sqliteUnit);
    return sqliteUnit.executeResult;
}
+ (id)liu_sqltoolGet:(void (^)(LIUSqliteUnit *executer))block {
    LIUSqliteUnit *sqliteUnit = [LIUSqliteUnit new];
    block(sqliteUnit);
    return sqliteUnit.getObj;
}
@end
