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

#pragma mark - 插入操作
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

#pragma mark - 更新操作

- (LIUSqliteUnit *(^)(id))update {
    return ^LIUSqliteUnit *(id obj) {
        _executeResult = [self liu_update:obj];
        return self;
    };
}

- (BOOL)liu_update:(id)obj {
    
    return NO;
}

#pragma mark - 查询操作

- (LIUSqliteUnit *(^)(Class, long))get {
    return ^LIUSqliteUnit *(Class cls, long tid) {
        _getObj = [self liu_obj:cls tid:tid];
        return self;
    };
}


- (id)liu_obj:(Class)cls tid:(long)tid {
    
    id tmpCls = [[cls alloc] init];
    NSArray *vars = [cls vars];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE tid = %ld;", cls, tid];
    sqlite3_stmt *stmt = NULL;
    int status = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (status == SQLITE_OK) {
        if ((sqlite3_step(stmt) == SQLITE_ROW)) {
            int col_idx = sqlite3_column_count(stmt);
            for (unsigned i = 0; i < col_idx; i++) {
                int columnType = sqlite3_column_type(stmt, i);
                for (LIUVarCode *var in vars) {
                    NSString *columnName = @(sqlite3_column_name(stmt, i));
                    if (![columnName isEqualToString:@"tid"]) {
                        if (columnType == SQLITE_INTEGER && [var.type isEqualToString:@"integer"] && [var.name isEqualToString:columnName]) {
                            NSInteger tmp = sqlite3_column_int(stmt, i);
                            NSNumber *test = [NSNumber numberWithInteger:tmp];
                            object_setIvar(tmpCls, var.ivar, test);
                        }
                    }
                    if (columnType == SQLITE_FLOAT && [var.type isEqualToString:@"real"] && [var.name isEqualToString:columnName]) {
                        NSNumber *getDoubleValue = @(sqlite3_column_double(stmt, i));
                        object_setIvar(tmpCls, var.ivar, getDoubleValue);
                    }
                    if (columnType == SQLITE_BLOB && [var.type isEqualToString:@"blob"] && [var.name isEqualToString:columnName]) {
                        const char *dataBuffer = sqlite3_column_blob(stmt, i);
                        int dataSize = sqlite3_column_bytes(stmt, i);
                        NSData *getData = [NSData dataWithBytes:(const void *)dataBuffer length:(NSUInteger)dataSize];
                        object_setIvar(tmpCls, var.ivar, getData);
                    }
                    if (columnType == SQLITE_TEXT && [var.type isEqualToString:@"text"] && [var.name isEqualToString:columnName]) {
                        NSString *str = @((const char *)sqlite3_column_text(stmt, i));
                        object_setIvar(tmpCls, var.ivar, str);
                    }
                }
            }
        }
    }
    return tmpCls;
}

+ (NSMutableArray *)liu_getData:(NSString *)sql {
    return nil;
}

#pragma mark - 刪除操作

- (LIUSqliteUnit *(^)(id))deleteObj {
    return ^LIUSqliteUnit *(id obj) {
        _executeResult = [self liu_delete:obj];
        return self;
    };
}

- (BOOL)liu_delete:(id)obj {
    
    return NO;
}

@end
