//
//  AYPageViewController.m
//  YZDisplayViewControllerDemo
//
//  Created by alpha yu on 02/04/2018.
//  Copyright © 2018 tlm group. All rights reserved.
//

#import "AYPageViewController.h"
#import "AYPageTitleView.h"
#import "UIView+Frame.h"
@interface AYPageViewController ()

@end

@implementation AYPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"AYPageViewController";
    
    self.view.backgroundColor = [UIColor whiteColor];
    AYPageTitleView *titleView = [[AYPageTitleView alloc] initWithFrame:CGRectMake(0, 100, self.view.yz_width, 44) titles:@[@"标题一", @"标题一二", @"标题一二三", @"标题一二三四", @"标题a", @"标题b", @"标题c", @"标题d", @"标题e", @"标题f"] currentIndex:5];
    titleView.titleViewBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    
//    titleView.currentIndex = 3;
    
//    titleView.isTitleViewScrollEnable = NO;
//    titleView.isShowLineView = YES;
    
//    titleView.isShowCoverView = YES;
//    titleView.coverViewHeight = 40;
//    titleView.coverViewRadius = 0;
    
//    titleView.isScaleEnable = YES;
//    titleView.maximumScaleFactor = 1.5;
    
    titleView.delegate = (id<AYPageTitleViewDelegate>)self;
    
    [self.view addSubview:titleView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AYPageTitleViewDelegate
- (void)titleView:(AYPageTitleView *)titleView clickAtIndex:(NSUInteger)index {
    NSLog(@"点到我了 = %@", [titleView.titleLabels[index] text]);

}
- (void)titleView:(AYPageTitleView *)titleView repeatClickAtIndex:(NSUInteger)index {
    NSLog(@"又点到我了 = %@", [titleView.titleLabels[index] text]);
}
@end
