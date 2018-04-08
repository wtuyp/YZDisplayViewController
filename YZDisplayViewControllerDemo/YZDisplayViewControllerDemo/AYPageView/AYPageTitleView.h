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

IB_DESIGNABLE
@interface AYPageTitleView : UIView

@property (nonatomic, weak) id<AYPageTitleViewDelegate> delegate;
@property (nonatomic, assign) IBInspectable NSUInteger currentIndex;  //default 0
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, readonly) NSMutableArray<UILabel *> *titleLabels;

@property (nonatomic, assign) IBInspectable BOOL isTitleViewScrollEnable; //default YES
@property (nonatomic, assign) IBInspectable CGFloat titleViewHeight;  //default 44.0
@property (nonatomic, strong) IBInspectable UIColor *titleViewBackgroundColor;    //default whiteColor

@property (nonatomic, strong) IBInspectable UIColor *titleColor;  //default blackColor
@property (nonatomic, strong) IBInspectable UIColor *titleSelectedColor;  //default rgb 0.13 0.67 0.93
@property (nonatomic, assign) IBInspectable CGFloat titleFontSize;    //default 15.0
@property (nonatomic, assign) IBInspectable CGFloat titleMargin;  //default 20.0

@property (nonatomic, assign) IBInspectable BOOL isTitleScaleEnable;
@property (nonatomic, assign) IBInspectable CGFloat maximumScaleFactor;   //default 1.2

@property (nonatomic, assign) IBInspectable BOOL isShowLineView;
@property (nonatomic, strong) IBInspectable UIColor *lineViewColor;   //default same to titleSelectedColor
@property (nonatomic, assign) IBInspectable CGFloat lineViewHeight;   //default 2.0
@property (nonatomic, assign) IBInspectable CGFloat lineViewWidth;    //default 0, that line width is equal to title width

@property (nonatomic, assign) IBInspectable BOOL isShowCoverView;
@property (nonatomic, strong) IBInspectable UIColor *coverViewColor;  //default lightGrayColor
@property (nonatomic, assign) IBInspectable CGFloat coverMargin;  //default 6.0
@property (nonatomic, assign) IBInspectable CGFloat coverViewHeight;  //default 26.0
@property (nonatomic, assign) IBInspectable CGFloat coverViewRadius;  //default 13.0

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles currentIndex:(NSUInteger)currentIndex;

- (void)reload;

- (void)clickTitleAtIndex:(NSUInteger)index;
- (void)moveFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex progress:(CGFloat)progress;

@end
