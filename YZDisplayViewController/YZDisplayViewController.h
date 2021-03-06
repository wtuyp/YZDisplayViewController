//
//  YZDisplayViewController.h
//  BuDeJie
//
//  Created by yz on 15/12/1.
//  Copyright © 2015年 yz. All rights reserved.
//

#import <UIKit/UIKit.h>

// 颜色渐变样式
typedef enum : NSUInteger {
    YZTitleColorGradientStyleRGB , // RGB:默认RGB样式
    YZTitleColorGradientStyleFill, // 填充
} YZTitleColorGradientStyle;

@interface YZDisplayViewController : UIViewController

/** 整体内容View 包含标题和内容滚动视图 */
@property (nonatomic, strong) UIView *contentView;

/** 标题滚动视图 */
@property (nonatomic, strong) UIScrollView *titleScrollView;

/** 内容滚动视图 */
@property (nonatomic, strong) UICollectionView *contentScrollView;

/** 根据角标，选中对应的控制器 */
@property (nonatomic, assign) NSInteger selectIndex;

/**  刷新标题和整个界面，在调用之前，必须先确定所有的子控制器。 */
- (void)refreshDisplay;


/** 顶部标题样式 */
- (void)setUpTitleEffect:(void (^)(UIColor **titleScrollViewColor, UIColor **norColor, UIColor **selColor, UIFont **titleFont, CGFloat *titleHeight, CGFloat *titleWidth))titleEffectBlock;

/** 颜色渐变 */
- (void)setUpTitleGradient:(void (^)(YZTitleColorGradientStyle *titleColorGradientStyle, UIColor **norColor, UIColor **selColor))titleGradientBlock;

/** 字体缩放 */
- (void)setUpTitleScale:(void (^)(CGFloat *titleScale))titleScaleBlock;

/** 下标样式 */
- (void)setUpUnderLineEffect:(void (^)(BOOL *isUnderLineDelayScroll, CGFloat *underLineH, CGFloat *underLineWidth, UIColor **underLineColor, BOOL *isUnderLineEqualTitleWidth))underLineBlock;

/** 遮盖 **/
- (void)setUpCoverEffect:(void (^)(UIColor **coverColor, CGFloat *coverCornerRadius))coverEffectBlock;

@end
