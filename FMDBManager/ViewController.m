//
//  ViewController.m
//  FMDBManager
//
//  Created by 王腾飞 on 2017/1/19.
//  Copyright © 2017年 Jason. All rights reserved.
//

#import "ViewController.h"
#import "SQLiteManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)open:(id)sender {
    [[SQLiteManager shareSQL] open];
}
- (IBAction)create:(id)sender {
    [[SQLiteManager shareSQL] create];
}
- (IBAction)insert:(id)sender {
    [[SQLiteManager shareSQL] insert];
}
- (IBAction)select:(id)sender {
    [[SQLiteManager shareSQL] select];
}
- (IBAction)delete:(id)sender {
    [[SQLiteManager shareSQL] deleteData];
}
- (IBAction)close:(id)sender {
    [[SQLiteManager shareSQL] close];
}
@end
