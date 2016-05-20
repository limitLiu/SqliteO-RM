//
//  LIUSqliteUnit.h
//  SqliteTool
//
//  Created by 劉裕 on 30/4/2016.
//  Copyright © 2016年 劉裕. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LIUSqliteUnit : NSObject

@property (nonatomic, assign) BOOL executeResult;
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) id getObj;


#pragma mark - 初始化操作

/**
 *  在Sandbox创建一个数据库文件
 */
- (LIUSqliteUnit *(^)(NSString *))setupDatabase;

/**
 *  传入数据库名和表名来初始化数据库
 *
 *  @param dbName 数据库文件名
 *  @param table  建表语句
 *
 */
- (LIUSqliteUnit *(^)(NSString *, NSString *))initDatabase;

#pragma mark - O/RM 操作

/**
 *  将一个Objective-C存储到数据库
 *
 *  @param obj objc实例
 *
 *  @return 返回成功或失败讯息
 */
- (LIUSqliteUnit *(^)(id))insert;
- (LIUSqliteUnit *(^)(id))update;
- (LIUSqliteUnit *(^)(Class, long))get;
- (LIUSqliteUnit *(^)(id))deleteObj;

+ (NSMutableArray *)liu_getData:(NSString *)sql;
@end
