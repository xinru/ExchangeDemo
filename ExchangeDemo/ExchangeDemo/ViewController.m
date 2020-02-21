//
//  ViewController.m
//  ExchangeDemo
//
//  Created by apple on 2020/2/21.
//  Copyright © 2020 apple. All rights reserved.
//

#import "ViewController.h"
#import "CustomImgsView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CustomImgsView *_imgsView = [[CustomImgsView alloc] init];
    [self.view addSubview:_imgsView];
    [_imgsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).offset(160);
        make.width.mas_equalTo(self.view.frame.size.width);
        make.height.mas_offset(168);
        make.right.equalTo(self.view);
    }];
    
//    目前只能放本地图片，如果放网络图片，请进入setter方法更改一下
    _imgsView.imgsArray = [NSMutableArray arrayWithArray:@[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg"]];
}


@end
