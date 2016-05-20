//
//  ViewController.m
//  SqliteTool
//
//  Created by 劉裕 on 30/4/2016.
//  Copyright © 2016年 劉裕. All rights reserved.
//

#import "ViewController.h"
#import "LIUPerson.h"
#import "LIUORM.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LIUPerson *p = [LIUPerson new];
    p.age = 201;
    p.name = @"foo";
    p.num = @5;
    BOOL executeResult1 = [LIUSqliteUnit liu_sqltool:^(LIUSqliteUnit *executer) {
        executer.setupDatabase(@"/test.sqlite").insert(p);
    }];
    NSLog(@"%d", executeResult1);
    
    LIUPerson *executeResult2 = (LIUPerson *)[LIUSqliteUnit liu_sqltoolGet:^(LIUSqliteUnit *executer) {
        executer.get([LIUPerson class], 1);
    }];
    NSLog(@"%@", executeResult2.name);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
