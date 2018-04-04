//
//  AYPageTitleView.h
//
//  Created by alpha yu on 02/04/2018.
//  Copyright © 2018 yz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AYPageTitleView;
@protocol AYPageTitleViewDelegate <NSObject>

@optional
- (void)titleView:(AYPageTitleView *)titleView clickAtIndex:(NSUInteger)index;
- (void)titleView:(AYPageTitleView *)titleView repeatClickAtIndex:(NSUInteger)index;

@end


@interface AYPageTitleView : UIView

@property (nonatomic, weak) id<AYPageTitleViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, readonly) NSMutableArray<UILabel *> *titleLabels;

@property (nonatomic, assign) BOOL isTitleViewScrollEnable; //default YES
@property (nonatomic, assign) CGFloat titleViewHeight;
@property (nonatomic, strong) UIColor *titleViewBackgroundColor;

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *titleSelectedColor;
@property (nonatomic, assign) CGFloat titleFontSize;
@property (nonatomic, assign) CGFloat titleMargin;

@property (nonatomic, assign) BOOL isShowLineView;
@property (nonatomic, strong) UIColor *lineViewColor;
@property (nonatomic, assign) CGFloat lineViewHeight;
@property (nonatomic, assign) CGFloat lineViewWidth;


@property (nonatomic, assign) BOOL isScaleEnable;
@property (nonatomic, assign) CGFloat maximumScaleFactor;

@property (nonatomic, assign) BOOL isShowCoverView;
@property (nonatomic, strong) UIColor *coverViewColor;
@property (nonatomic, assign) CGFloat coverMargin;
@property (nonatomic, assign) CGFloat coverViewHeight;
@property (nonatomic, assign) CGFloat coverViewRadius;

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles currentIndex:(NSUInteger)currentIndex;

- (void)clickTitleAtIndex:(NSUInteger)index;
- (void)reload;

@end
