//
//  LIUSqliteUnit.m
//  SqliteTool
//
//  Created by 劉裕 on 30/4/2016.
//  Copyright © 2016年 劉裕. All rights reserved.
//

#import "LIUSqliteUnit.h"
#import <sqlite3.h>
#import <objc/runtime.h>
#import "NSObject+LIUVars.h"

@implementation LIUSqliteUnit
static sqlite3 *_db;

#pragma mark - 初始化操作

- (LIUSqliteUnit *(^)(NSString *))setupDatabase {
    return ^LIUSqliteUnit *(NSString *dbName) {
        _executeResult = [self liu_initDatabase:dbName];
        return self;
    };
}

- (BOOL)liu_initDatabase:(NSString *)dbName {
    NSString *database = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingString:dbName];
    int openStatus = sqlite3_open(database.UTF8String, &_db);
    if (openStatus == SQLITE_OK) {
        return YES;
    }
    return NO;
}

- (LIUSqliteUnit *(^)(NSString *, NSString *))initDatabase {
    return ^LIUSqliteUnit *(NSString *dbName, NSString *table) {
        _executeResult = [self liu_initDatabase:dbName table:table];
        return self;
    };
}

- (BOOL)liu_initDatabase:(NSString *)dbName table:(NSString *)table {
    if ([self liu_initDatabase:dbName]) {
        return [self liu_executeUpdate:table];
    }
    return NO;
}

#pragma mark - O/RM 操作

- (LIUSqliteUnit *(^)(id))insert {
    return ^LIUSqliteUnit *(id obj) {
        _executeResult = [self liu_insert:obj];
        return self;
    };
}
- (BOOL)liu_insert:(id)obj {
    NSMutableString *tmpStr = [NSMutableString string];
    NSMutableString *columnsName = [NSMutableString string];
    NSMutableString *value = [NSMutableString string];
    NSArray *vars = [[obj class] vars];
    for (LIUVarCode *var in vars) {
        NSString *varName = var.name;
        NSString *tmp = [NSString stringWithFormat:@"%@", var.wholeStr];
        [tmpStr appendString:tmp];
        NSString *tmpColumns = [NSString stringWithFormat:@"%@,", var.name];
        [columnsName appendString:tmpColumns];
        
        NSString *str = nil;
        if ([var.typeCode isEqualToString:@"%d"]) {
            long sendMsg = ((long (*)(id, SEL))(void *)objc_msgSend)(obj, NSSelectorFromString(varName));
            str = [NSString stringWithFormat:@"%ld,", sendMsg];
        } else if ([var.typeCode isEqualToString:@"%g"]) {
//            double sendMsg = ((double (*)(id, SEL))(void *)objc_msgSend)(obj, NSSelectorFromString(varName));
            double sendMsg = objc_msgSend_fpret(obj, NSSelectorFromString(varName));
            str = [NSString stringWithFormat:@"%g,", sendMsg];
        } else {
            id sendMsg = objc_msgSend(obj, NSSelectorFromString(varName));
            str = [NSString stringWithFormat:@"'%@',", [sendMsg description]];
        }
        [value appendString:str];
    }
    NSString *tableName = NSStringFromClass([obj class]);
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (tid integer PRIMARY KEY AUTOINCREMENT, %@);", tableName, [tmpStr substringToIndex:tmpStr.length - 1]];
    if ([self liu_executeUpdate:sql]) {
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@(tid, %@) VALUES(null, %@);", tableName, [columnsName substringToIndex:columnsName.length - 1], [value substringToIndex:value.length - 1]];
        return [self liu_executeUpdate:insertSql];
    }
    
    return NO;
}
+ (BOOL)liu_update:(id)obj {
    return NO;
}
+ (NSMutableArray *)liu_objc:(NSString *)sql {
    return nil;
}
+ (BOOL)liu_delete:(id)obj {
    return NO;
}
- (BOOL)liu_executeUpdate:(NSString *)table {
    const char *sql = table.UTF8String;
    char *errmsg = NULL;
    sqlite3_exec(_db, sql, NULL, NULL, &errmsg);
    if (errmsg) {
        NSLog(@"create table is fail, msg: %s", errmsg);
        return NO;
    }
    return YES;
}
@end
