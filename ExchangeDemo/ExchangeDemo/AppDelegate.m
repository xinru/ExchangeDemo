//
//  AppDelegate.m
//  ExchangeDemo
//
//  Created by apple on 2020/2/21.
//  Copyright © 2020 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) UIScrollView *imgsView;

//图片控件数组
@property (nonatomic, strong) NSMutableArray *subViewsArray;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    // 设置rootViewController
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}



@end
