//
//  LIUSqliteUnit+LIUCategory.h
//  SqliteTool
//
//  Created by 劉裕 on 1/5/2016.
//  Copyright © 2016年 劉裕. All rights reserved.
//

#import "LIUSqliteUnit.h"


@interface LIUSqliteUnit (LIUCategory)

+ (BOOL)liu_sqltool:(void(^)(LIUSqliteUnit *executer))block;
+ (id)liu_sqltoolGet:(void (^)(LIUSqliteUnit *executer))block;
@end
