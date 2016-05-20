//
//  LIUTypeCode.h
//  SqliteTool
//
//  Created by 劉裕 on 1/5/2016.
//  Copyright © 2016年 劉裕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if DEBUG
#define rac_keywordify autoreleasepool {}
#else
#define rac_keywordify try {} @catch (...) {}
#endif

#define onExit\
    rac_keywordify\
    __strong void(^block)(void) __attribute__((cleanup(blockCleanUp), unused)) = ^

static void blockCleanUp(__strong void(^*block)(void)) {
    (*block)();
}

@interface LIUVarCode : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *wholeStr;
@property (nonatomic, copy) NSString *typeCode;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) Ivar ivar;
@end
