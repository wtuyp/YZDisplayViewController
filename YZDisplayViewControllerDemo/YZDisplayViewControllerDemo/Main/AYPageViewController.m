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
#import "AYPageContentView.h"

#import "ChildViewController.h"


@interface AYPageViewController ()

@end

@implementation AYPageViewController {
    AYPageTitleView *titleView;
    AYPageContentView *contentView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"AYPageViewController";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
//    AYPageTitleView *titleView = [[AYPageTitleView alloc] initWithFrame:CGRectMake(0, 100, self.view.yz_width, 44) titles:@[@"标题一", @"标题一二", @"标题一二三", @"标题一二三四", @"标题a", @"标题b", @"标题c", @"标题d", @"标题e", @"标题f"]];
    
    titleView = [[AYPageTitleView alloc] init];
    titleView.titles = @[@"标题一", @"标题一二", @"标题一二三", @"标题一二三四", @"标题a", @"标题b", @"标题c", @"标题d", @"标题e", @"标题f"];
    titleView.frame = CGRectMake(0, 100, self.view.yz_width, 44);
    titleView.titleViewBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];

    titleView.currentIndex = 8;

//    titleView.isTitleViewScrollEnable = NO;

    titleView.isShowLineView = YES;
//    titleView.lineViewColor = [UIColor yellowColor];
//    titleView.lineViewWidth = 30;

    titleView.isShowCoverView = YES;
//    titleView.coverViewColor = [UIColor yellowColor];
//    titleView.coverViewHeight = 40;
//    titleView.coverViewRadius = 0;

//    titleView.isTitleScaleEnable = YES;
//    titleView.maximumScaleFactor = 1.5;

    titleView.delegate = (id<AYPageTitleViewDelegate>)self;

    [self.view addSubview:titleView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        titleView.titles = @[@"标题一", @"标题一二", @"标题一二三", @"标题一二三四", @"标题a", @"标题b"];
        
//        titleView.lineViewColor = [UIColor yellowColor];
//        [titleView setNeedsLayout];
        
//        [titleView clickTitleAtIndex:2];
    });
    
    //xib way
    UINib *nib = [UINib nibWithNibName:@"AYPageTitleView" bundle:nil];
    AYPageTitleView *titleView1 = [nib instantiateWithOwner:self options:nil].firstObject;
    [self.view addSubview:titleView1];
    titleView1.center = self.view.center;
    titleView1.titles = @[@"标题一", @"标题一二", @"标题一二三", @"标题一二三四", @"标题a", @"标题b"];
    
//    contentView = [[AYPageContentView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleView.frame) + 5, self.view.yz_width - 20, CGRectGetMinY(titleView1.frame) - CGRectGetMaxY(titleView.frame) - 10) childViewControllers:[self childVCs] currentIndex:0];
    
    contentView = [[AYPageContentView alloc] init];
    contentView.frame = CGRectMake(10, CGRectGetMaxY(titleView.frame) + 5, self.view.yz_width - 20, CGRectGetMinY(titleView1.frame) - CGRectGetMaxY(titleView.frame) - 10);
    contentView.childViewControllers = [self childVCs];
    contentView.delegate = (id<AYPageContentViewDelegate>)self;
    [self.view addSubview:contentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)childVCs {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1];
        [array addObject:vc];
    }
    return [array copy];
}
#pragma mark - AYPageTitleViewDelegate
- (void)titleView:(AYPageTitleView *)titleView clickAtIndex:(NSUInteger)index {
    NSLog(@"titleView 点到我了 = %@", [titleView.titleLabels[index] text]);
    
    [contentView scrollToIndex:index];

}
- (void)titleView:(AYPageTitleView *)titleView repeatClickAtIndex:(NSUInteger)index {
    NSLog(@"titleView 又点到我了 = %@", [titleView.titleLabels[index] text]);
}

#pragma mark - AYPageContentViewDelegate
- (void)contentView:(AYPageContentView *)contentView didSEndScrollAtIndex:(NSUInteger)index {
    NSLog(@"contentView 滚动到了 %lu", (unsigned long)index);
    [titleView clickTitleAtIndex:index];
}

- (void)contentView:(AYPageContentView *)contentView scrollFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex progress:(CGFloat)progress {
    NSLog(@"contentView 从 index %lu 滚动到了 index %lu, 进度 %f", (unsigned long)fromIndex, (unsigned long)toIndex, progress);
    [titleView moveFromIndex:fromIndex toIndex:toIndex progress:progress];
    
}
@end
