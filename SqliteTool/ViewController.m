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
    p.age = 20;
    p.name = @"foo";
    p.num = @5;
    BOOL executeResult = [LIUSqliteUnit liu_sqltool:^(LIUSqliteUnit *executer) {
        executer.setupDatabase(@"/test.sqlite").insert(p);
    }];
    NSLog(@"%d", executeResult);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
