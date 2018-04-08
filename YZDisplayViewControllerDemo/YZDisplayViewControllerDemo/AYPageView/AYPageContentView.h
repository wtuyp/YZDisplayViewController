//
//  AYPageContentView.h
//  YZDisplayViewControllerDemo
//
//  Created by alpha yu on 04/04/2018.
//  Copyright © 2018 tlm group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AYPageContentView;
@protocol AYPageContentViewDelegate <NSObject>

@optional
- (void)contentView:(AYPageContentView *)contentView didSEndScrollAtIndex:(NSUInteger)index;
- (void)contentView:(AYPageContentView *)contentView scrollFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex progress:(CGFloat)progress;

@end

@interface AYPageContentView : UIView

@property (nonatomic, weak) id<AYPageContentViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger currentIndex;  //default 0
@property (nonatomic, strong) NSArray<UIViewController *> *childViewControllers;

- (instancetype)initWithFrame:(CGRect)frame childViewControllers:(NSArray *)childViewControllers;
- (instancetype)initWithFrame:(CGRect)frame childViewControllers:(NSArray *)childViewControllers currentIndex:(NSUInteger)currentIndex;
- (void)scrollToIndex:(NSUInteger)index;

@end
