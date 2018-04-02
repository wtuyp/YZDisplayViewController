//
//  YZDisplayViewController.m
//  BuDeJie
//
//  Created by yz on 15/12/1.
//  Copyright © 2015年 yz. All rights reserved.
//

#import "YZDisplayViewController.h"
#import "YZDisplayTitleLabel.h"
#import "YZDisplayViewHeader.h"
#import "UIView+Frame.h"
#import "YZFlowLayout.h"

static NSString * const CellIndentifier = @"CellIndentifier";

@interface YZDisplayViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) CGFloat startOffsetX;

/** 记录是否点击 */
@property (nonatomic, assign) BOOL isClickTitle;

/* 是否初始化 */
@property (nonatomic, assign) BOOL isInitial;

/** 计算上一次选中角标 */
@property (nonatomic, assign) NSInteger selIndex;


/** 标题滚动视图背景颜色 */
@property (nonatomic, strong) UIColor *titleScrollViewColor;

/** 标题高度 */
@property (nonatomic, assign) CGFloat titleHeight;

/** 标题宽度 */
@property (nonatomic, assign) CGFloat titleWidth;

/** 正常标题颜色 */
@property (nonatomic, strong) UIColor *norColor;

/** 选中标题颜色 */
@property (nonatomic, strong) UIColor *selColor;

/** 标题字体 */
@property (nonatomic, strong) UIFont *titleFont;

/** 字体缩放比例 */
@property (nonatomic, assign) CGFloat titleScale;

/** 标题间距 */
@property (nonatomic, assign) CGFloat titleMargin;

/** 所有标题数组 */
@property (nonatomic, strong) NSMutableArray *titleLabels;

/** 所有标题宽度数组 */
@property (nonatomic, strong) NSMutableArray *titleWidths;

/** 字体是否渐变 */
@property (nonatomic, assign) BOOL isShowTitleGradient;

/** 字体放大 */
@property (nonatomic, assign) BOOL isShowTitleScale;


/** 标题遮盖视图 */
@property (nonatomic, strong) UIView *coverView;

/** 是否显示遮盖 */
@property (nonatomic, assign) BOOL isShowTitleCover;

/** 颜色渐变样式 */
@property (nonatomic, assign) YZTitleColorGradientStyle titleColorGradientStyle;

/** 遮盖颜色 */
@property (nonatomic, strong) UIColor *coverColor;

/** 遮盖圆角半径 */
@property (nonatomic, assign) CGFloat coverCornerRadius;


/** 下标视图 */
@property (nonatomic, strong) UIView *underLine;

/** 是否需要下标 */
@property (nonatomic, assign) BOOL isShowUnderLine;

/** 下标宽度是否等于标题宽度 */
@property (nonatomic, assign) BOOL isUnderLineEqualTitleWidth;

/** 是否延迟滚动下标 */
@property (nonatomic, assign) BOOL isDelayScroll;

/** 下标颜色 */
@property (nonatomic, strong) UIColor *underLineColor;

/** 下标高度 */
@property (nonatomic, assign) CGFloat underLineHeight;

/** 下标宽度 */
@property (nonatomic, assign) CGFloat underLineWidth;

/** 开始颜色,取值范围0~1 */
@property (nonatomic, assign) CGFloat startR;
@property (nonatomic, assign) CGFloat startG;
@property (nonatomic, assign) CGFloat startB;

/** 完成颜色,取值范围0~1 */
@property (nonatomic, assign) CGFloat endR;
@property (nonatomic, assign) CGFloat endG;
@property (nonatomic, assign) CGFloat endB;

@end

@implementation YZDisplayViewController

#pragma mark - 初始化方法
- (instancetype)init
{
    if (self = [super init]) {
        [self initial];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initial];
}

- (void)initial {
    _titleHeight = 44.0;
    
    _norColor = [UIColor blackColor];
    _selColor = [UIColor redColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - 控制器view生命周期方法
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_isInitial == NO) {
        self.selectIndex = _selectIndex;
        
        _isInitial = YES;
        
        CGFloat statusH = [UIApplication sharedApplication].statusBarFrame.size.height;
        
        CGFloat titleY = !self.navigationController.isNavigationBarHidden ? (44.0 + statusH) : statusH;
        
        // 是否占据全屏
        if (_isfullScreen) {
            
            // 整体contentView尺寸
            self.contentView.frame = CGRectMake(0, 0, YZScreenW, YZScreenH);
            
            // 顶部标题View尺寸
            self.titleScrollView.frame = CGRectMake(0, titleY, YZScreenW, self.titleHeight);
            
            // 顶部内容View尺寸
            self.contentScrollView.frame = self.contentView.bounds;
            
            return;
        }
        
        if (self.contentView.frame.size.height == 0) {
            self.contentView.frame = CGRectMake(0, titleY, YZScreenW, YZScreenH - titleY);
        }
        
        // 顶部标题View尺寸
        self.titleScrollView.frame = CGRectMake(0, 0, YZScreenW, self.titleHeight);
        
        // 顶部内容View尺寸
        CGFloat contentY = CGRectGetMaxY(self.titleScrollView.frame);
        CGFloat contentH = self.contentView.yz_height - contentY;
        self.contentScrollView.frame = CGRectMake(0, contentY, YZScreenW, contentH);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isInitial == NO) {
        
        // 没有子控制器，不需要设置标题
        if (self.childViewControllers.count == 0) {
            return;
        }
        
        if (_titleColorGradientStyle == YZTitleColorGradientStyleFill || _titleWidth == 0) { // 填充样式才需要这样
            [self setUpTitleWidth];
        }
        [self setUpAllTitle];
    }
}

#pragma mark - 懒加载
- (UIFont *)titleFont
{
    if (_titleFont == nil) {
        _titleFont = [UIFont systemFontOfSize:15];
    }
    return _titleFont;
}

- (NSMutableArray *)titleWidths
{
    if (_titleWidths == nil) {
        _titleWidths = [NSMutableArray array];
    }
    return _titleWidths;
}

- (NSMutableArray *)titleLabels
{
    if (_titleLabels == nil) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}

- (UIView *)coverView
{
    if (_coverView == nil) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = _coverColor ?: [UIColor lightGrayColor];
        _coverView.layer.cornerRadius = _coverCornerRadius;
        
        [self.titleScrollView insertSubview:_coverView atIndex:0];
    }
    return _isShowTitleCover ? _coverView : nil;
}

- (UIView *)underLine
{
    if (_underLine == nil) {
        _underLine = [[UIView alloc] init];
        _underLine.backgroundColor = _underLineColor ?: [UIColor redColor];
        
        [self.titleScrollView insertSubview:_underLine atIndex:0];
    }
    return _isShowUnderLine ? _underLine : nil;
}

// 懒加载标题滚动视图
- (UIScrollView *)titleScrollView
{
    if (_titleScrollView == nil) {
        _titleScrollView = [[UIScrollView alloc] init];
        _titleScrollView.scrollsToTop = NO;
        _titleScrollView.backgroundColor = _titleScrollViewColor ?: [UIColor colorWithWhite:1 alpha:0.7];
        _titleScrollView.showsHorizontalScrollIndicator = NO;
        
        [self.contentView addSubview:_titleScrollView];
    }
    return _titleScrollView;
}

// 懒加载内容滚动视图
- (UIScrollView *)contentScrollView
{
    if (_contentScrollView == nil) {
        YZFlowLayout *layout = [[YZFlowLayout alloc] init];
        
        _contentScrollView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.bounces = NO;
        _contentScrollView.delegate = self;
        _contentScrollView.dataSource = self;
        _contentScrollView.scrollsToTop = NO;

        [_contentScrollView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellIndentifier];
        
        _contentScrollView.backgroundColor = self.view.backgroundColor;
        [self.contentView insertSubview:_contentScrollView belowSubview:self.titleScrollView];
    }
    
    return _contentScrollView;
}

// 懒加载整个内容view
- (UIView *)contentView
{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        [self.view addSubview:_contentView];
    }
    
    return _contentView;
}

#pragma mark - 属性setter方法
- (void)setNorColor:(UIColor *)norColor
{
    _norColor = norColor;
    
    [_norColor getRed:&_startR green:&_startG blue:&_startB alpha:nil];
}

- (void)setSelColor:(UIColor *)selColor
{
    _selColor = selColor;
    
    [_selColor getRed:&_endR green:&_endG blue:&_endB alpha:nil];
}

- (void)setIsShowTitleScale:(BOOL)isShowTitleScale
{
    if (_isShowUnderLine) {
        // 抛异常
        NSException *excp = [NSException exceptionWithName:@"YZDisplayViewControllerException" reason:@"字体放大效果和角标不能同时使用。" userInfo:nil];
        [excp raise];
    }
    
    _isShowTitleScale = isShowTitleScale;
}

- (void)setTitleScale:(CGFloat)titleScale {
    self.isShowTitleScale = YES;
    
    _titleScale = titleScale;
}

- (void)setIsShowUnderLine:(BOOL)isShowUnderLine
{
    if (_isShowTitleScale) {
        // 抛异常
        NSException *excp = [NSException exceptionWithName:@"YZDisplayViewControllerException" reason:@"字体放大效果和角标不能同时使用。" userInfo:nil];
        [excp raise];
    }
    
    _isShowUnderLine = isShowUnderLine;
}

- (void)setTitleScrollViewColor:(UIColor *)titleScrollViewColor
{
    _titleScrollViewColor = titleScrollViewColor;
    
    self.titleScrollView.backgroundColor = titleScrollViewColor;
}

- (void)setIsfullScreen:(BOOL)isfullScreen
{
    _isfullScreen = isfullScreen;
    
    self.contentView.frame = CGRectMake(0, 0, YZScreenW, YZScreenH);
    
}

// 一次性设置所有颜色渐变属性
- (void)setUpTitleGradient:(void (^)(YZTitleColorGradientStyle *titleColorGradientStyle, UIColor **norColor, UIColor **selColor))titleGradientBlock;
{
    _isShowTitleGradient = YES;
    UIColor *norColor;
    UIColor *selColor;
    if (titleGradientBlock) {
        titleGradientBlock(&_titleColorGradientStyle, &norColor, &selColor);
        if (norColor) {
            self.norColor = norColor;
        }
        if (selColor) {
            self.selColor = selColor;
        }
    }

    if (_titleColorGradientStyle == YZTitleColorGradientStyleFill && _titleWidth > 0) {
        @throw [NSException exceptionWithName:@"YZDisplayViewControllerException" reason:@"标题颜色填充不需要设置标题宽度" userInfo:nil];
    }
}

// 一次性设置所有遮盖属性
- (void)setUpCoverEffect:(void (^)(UIColor **, CGFloat *))coverEffectBlock
{
    _isShowTitleCover = YES;
    
    if (coverEffectBlock) {
        UIColor *color;

        coverEffectBlock(&color, &_coverCornerRadius);
        
        if (color) {
            _coverColor = color;
        }
    }
}

// 一次性设置所有字体缩放属性
- (void)setUpTitleScale:(void(^)(CGFloat *titleScale))titleScaleBlock
{
    self.isShowTitleScale = YES;

    if (titleScaleBlock) {
        titleScaleBlock(&_titleScale);
    }
}

// 一次性设置所有下标属性
- (void)setUpUnderLineEffect:(void(^)(BOOL *isUnderLineDelayScroll,CGFloat *underLineH,CGFloat *underLineWidth,UIColor **underLineColor,BOOL *isUnderLineEqualTitleWidth))underLineBlock
{
    if (_isShowTitleScale) {
        @throw [NSException exceptionWithName:@"YZDisplayViewControllerException" reason:@"当前框架下标和字体缩放不能一起用" userInfo:nil];
    }
    
    _isShowUnderLine = YES;

    if (underLineBlock) {
        UIColor *underLineColorTemp;
        underLineBlock(&_isDelayScroll, &_underLineHeight, &_underLineWidth, &underLineColorTemp, &_isUnderLineEqualTitleWidth);
        
        _underLineColor = underLineColorTemp;
    }
}

// 一次性设置所有标题属性
- (void)setUpTitleEffect:(void (^)(UIColor **titleScrollViewColor, UIColor **norColor, UIColor **selColor, UIFont **titleFont, CGFloat *titleHeight, CGFloat *titleWidth))titleEffectBlock {
   
    if (titleEffectBlock) {
        UIColor *titleScrollViewColor;
        UIColor *norColor;
        UIColor *selColor;
        UIFont *titleFont;
        
        titleEffectBlock(&titleScrollViewColor, &norColor, &selColor, &titleFont, &_titleHeight, &_titleWidth);
        
        if (norColor) {
            self.norColor = norColor;
        }
        if (selColor) {
            self.selColor = selColor;
        }
        if (titleScrollViewColor) {
            self.titleScrollViewColor = titleScrollViewColor;
        }
        if (titleFont) {
            _titleFont = titleFont;
        }
    }
    
    if (_titleColorGradientStyle == YZTitleColorGradientStyleFill && _titleWidth > 0) {
        @throw [NSException exceptionWithName:@"YZDisplayViewControllerException" reason:@"标题颜色填充不需要设置标题宽度" userInfo:nil];
    }
}

#pragma mark - 添加标题方法
// 计算所有标题宽度
- (void)setUpTitleWidth
{
    // 判断是否能占据整个屏幕
    NSUInteger count = self.childViewControllers.count;
    
    NSArray *titles = [self.childViewControllers valueForKeyPath:@"title"];
    
    [self.titleWidths removeAllObjects];
    
    CGFloat totalWidth = 0;
    
    // 计算所有标题的宽度
    for (NSString *title in titles) {
        
        if ([title isKindOfClass:[NSNull class]]) {
            // 抛异常
            NSException *excp = [NSException exceptionWithName:@"YZDisplayViewControllerException" reason:@"没有设置Controller.title属性，应该把子标题保存到对应子控制器中" userInfo:nil];
            [excp raise];
            
        }
        
        CGRect titleBounds = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
        
        CGFloat width = titleBounds.size.width;
        
        [self.titleWidths addObject:@(width)];
        
        totalWidth += width;
    }
    
    if (totalWidth > YZScreenW) {
        
        _titleMargin = margin;
        
        self.titleScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, _titleMargin);
        
        return;
    }
    
    CGFloat titleMargin = (YZScreenW - totalWidth) / (count + 1);
    
    _titleMargin = titleMargin < margin ? margin: titleMargin;
    
    self.titleScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, _titleMargin);
}


// 设置所有标题
- (void)setUpAllTitle
{
    // 遍历所有的子控制器
    NSUInteger count = self.childViewControllers.count;
    
    // 添加所有的标题
    CGFloat labelW = _titleWidth;
    CGFloat labelH = self.titleHeight;
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    
    for (int i = 0; i < count; i++) {
        UIViewController *vc = self.childViewControllers[i];
        
        UILabel *label = [[YZDisplayTitleLabel alloc] init];
        label.tag = i;
        label.textColor = self.norColor;
        label.font = self.titleFont;
        label.text = vc.title;
        
        if (_titleColorGradientStyle == YZTitleColorGradientStyleFill || _titleWidth == 0) { // 填充样式才需要
            labelW = [self.titleWidths[i] floatValue];
            
            UILabel *lastLabel = [self.titleLabels lastObject];
            labelX = _titleMargin + CGRectGetMaxX(lastLabel.frame);
        } else {
            labelX = i * labelW;
        }
        
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        // 监听标题的点击
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
        [label addGestureRecognizer:tap];
        
        // 保存到数组
        [self.titleLabels addObject:label];
        
        [_titleScrollView addSubview:label];
        
        if (i == _selectIndex) {
            [self titleClick:tap];
        }
    }
    
    // 设置标题滚动视图的内容范围
    UILabel *lastLabel = self.titleLabels.lastObject;
    _titleScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastLabel.frame), 0);
    _contentScrollView.contentSize = CGSizeMake(count * YZScreenW, 0);
    
}

#pragma mark - 更新标题效果
- (void)updateTitleColorGradientWithSourceLabel:(YZDisplayTitleLabel *)sourceLabel targetLabel:(YZDisplayTitleLabel *)targetLabel progress:(CGFloat)progress {
    if (_isShowTitleGradient == NO) {
        return;
    }
    
    // RGB渐变
    if (_titleColorGradientStyle == YZTitleColorGradientStyleRGB) {
        CGFloat deltaR = _endR - _startR;
        CGFloat deltaG = _endG - _startG;
        CGFloat deltaB = _endB - _startB;
        
        sourceLabel.textColor = [UIColor colorWithRed:_endR - progress * deltaR green:_endG - progress * deltaG blue:_endB - progress * deltaB alpha:1];
        targetLabel.textColor = [UIColor colorWithRed:_startR + progress * deltaR green:_startG + progress * deltaG blue:_startB + progress * deltaB alpha:1];
    }
    
    // 填充渐变
    if (_titleColorGradientStyle == YZTitleColorGradientStyleFill) {
        if (sourceLabel.index < targetLabel.index) {    //向左滑
            sourceLabel.textColor = self.selColor;
            sourceLabel.fillColor = self.norColor;
            sourceLabel.progress = progress;
            
            targetLabel.textColor = self.norColor;
            targetLabel.fillColor = self.selColor;
            targetLabel.progress = progress;
        } else if (sourceLabel.index > targetLabel.index) {//向右滑
            sourceLabel.textColor = self.norColor;
            sourceLabel.fillColor = self.selColor;
            sourceLabel.progress = 1 - progress;
            
            targetLabel.textColor = self.selColor;
            targetLabel.fillColor = self.norColor;
            targetLabel.progress = 1 - progress;
        }
    }
}

- (void)updateTitleScaleWithSourceLabel:(UILabel *)sourceLabel targetLabel:(UILabel *)targetLabel progress:(CGFloat)progress {
    if (!_isShowTitleScale) {
        return;
    }
    
    CGFloat maxScaleFactor = _titleScale ?: YZTitleTransformScale;
    CGFloat deltaScale = maxScaleFactor - 1.0;
    sourceLabel.transform = CGAffineTransformMakeScale(maxScaleFactor - progress * deltaScale, maxScaleFactor - progress * deltaScale);
    targetLabel.transform = CGAffineTransformMakeScale(1.0 + progress * deltaScale, 1.0 + progress * deltaScale);
}

- (void)updateUnderLineWithSourceLabel:(UILabel *)sourceLabel targetLabel:(UILabel *)targetLabel progress:(CGFloat)progress {
    if (_isClickTitle) {
        return;
    }
    
    CGFloat deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x;
    CGFloat deltaW = targetLabel.frame.size.width - sourceLabel.frame.size.width;
    self.underLine.yz_x = sourceLabel.frame.origin.x + progress * deltaX;
    self.underLine.yz_width = sourceLabel.frame.size.width + progress * deltaW;
}

- (void)updateCoverWithSourceLabel:(UILabel *)sourceLabel targetLabel:(UILabel *)targetLabel progress:(CGFloat)progress {
    if (_isClickTitle) {
        return;
    }
    
    CGFloat deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x;
    CGFloat deltaW = targetLabel.frame.size.width - sourceLabel.frame.size.width;
    self.coverView.yz_width = sourceLabel.yz_width + deltaW * progress + 10;    //TODO: 后续增加 cover margin 属性
    self.coverView.yz_x = sourceLabel.yz_x + deltaX * progress - 5;
}

#pragma mark - 标题点击处理
- (void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    
    if (self.titleLabels.count) {
        if (_selectIndex >= self.titleLabels.count) {
            @throw [NSException exceptionWithName:@"YZDisplayViewControllerException" reason:@"选中控制器的角标越界" userInfo:nil];
        }
        
        UILabel *label = self.titleLabels[selectIndex];
        [self titleClick:[label.gestureRecognizers firstObject]];
    }
}

// 标题按钮点击
- (void)titleClick:(UITapGestureRecognizer *)tap
{
    // 记录是否点击标题
    _isClickTitle = YES;
    
    // 获取对应标题label
    UILabel *label = (UILabel *)tap.view;
    
    // 获取当前角标
    NSInteger i = label.tag;
    
    // 选中label
    [self selectLabel:label];
    
    // 内容滚动视图滚动到对应位置
    CGFloat offsetX = i * YZScreenW;
    
    self.contentScrollView.contentOffset = CGPointMake(offsetX, 0); //不会触发 scrollView 代理
    
    // 添加控制器
    UIViewController *vc = self.childViewControllers[i];
    
    // 判断控制器的view有没有加载，没有就加载，加载完在发送通知
    if (vc.view) {
        // 发出通知点击标题通知
        [[NSNotificationCenter defaultCenter] postNotificationName:YZDisplayViewClickOrScrollDidFinshNote  object:vc];
        
        // 发出重复点击标题通知
        if (_selIndex == i) {
            [[NSNotificationCenter defaultCenter] postNotificationName:YZDisplayViewRepeatClickTitleNote object:vc];
        }
    }
    
    _selIndex = i;
    
    // 点击事件处理完成
    _isClickTitle = NO;
}

- (void)selectLabel:(YZDisplayTitleLabel *)label
{
    for (YZDisplayTitleLabel *labelView in self.titleLabels) {
        if (label == labelView) {
            continue;
        }
        
        if (_isShowTitleGradient) {
            labelView.transform = CGAffineTransformIdentity;
        }
        
        labelView.textColor = self.norColor;
        
        if (_isShowTitleGradient && _titleColorGradientStyle == YZTitleColorGradientStyleFill) {
            labelView.fillColor = self.norColor;
            labelView.progress = 1;
        }
    }
    
    // 修改标题选中颜色
    label.textColor = self.selColor;
    if (_isShowTitleGradient && _titleColorGradientStyle == YZTitleColorGradientStyleFill) {
        label.fillColor = self.norColor;
        label.progress = 0;
    }
    
    // 设置标题居中
    [self setLabelTitleCenter:label];
    
    // 标题缩放
    if (_isShowTitleScale) {
        CGFloat scaleTransform = _titleScale ?: YZTitleTransformScale;
        label.transform = CGAffineTransformMakeScale(scaleTransform, scaleTransform);
    }
    
    // 设置下标的位置
    [self setUpUnderLine:label];
    
    // 设置cover
    [self setUpCoverView:label];
}

// 设置蒙版
- (void)setUpCoverView:(UILabel *)label
{
    if (!_isShowTitleCover) {
        return;
    }
    
    // 获取文字尺寸
    CGRect titleBounds = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName : self.titleFont}
                                                  context:nil];
    
    CGFloat border = 5;
    CGFloat coverH = titleBounds.size.height + 2 * border;
    CGFloat coverW = titleBounds.size.width + 2 * border;
    
    self.coverView.yz_y = (label.yz_height - coverH) * 0.5;
    self.coverView.yz_height = coverH;
    
    // 点击时候需要动画
    [UIView animateWithDuration:0.25 animations:^{
        self.coverView.yz_width = coverW;
        self.coverView.yz_x = label.yz_x - border;
    }];
}

// 设置下标的位置
- (void)setUpUnderLine:(UILabel *)label
{
    if (!_isShowUnderLine) {
        return;
    }
    
    // 获取文字尺寸
    CGRect titleBounds = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    CGFloat underLineH = _underLineHeight ?: YZUnderLineH;
    
    self.underLine.yz_y = label.yz_height - underLineH;
    self.underLine.yz_height = underLineH;
    
    // 点击时候需要动画
    [UIView animateWithDuration:0.25 animations:^{
        if (_isUnderLineEqualTitleWidth) {
            self.underLine.yz_width = titleBounds.size.width;
        } else {
            if (_underLineWidth > 0.0) {
                self.underLine.yz_width = _underLineWidth;
            } else {
                self.underLine.yz_width = label.yz_width;
            }
        }
        self.underLine.yz_centerX = label.yz_centerX;
    }];
    
}

// 让选中的按钮居中显示
- (void)setLabelTitleCenter:(UILabel *)label
{
    // 设置标题滚动区域的偏移量
    CGFloat offsetX = label.center.x - YZScreenW * 0.5;
    
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    // 计算下最大的标题视图滚动区域
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - YZScreenW + _titleMargin;
    
    if (maxOffsetX < 0) {
        maxOffsetX = 0;
    }
    
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    
    // 滚动区域
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

#pragma mark - 刷新界面方法
// 更新界面
- (void)refreshDisplay
{
    if (self.childViewControllers.count == 0) {
        @throw [NSException exceptionWithName:@"YZDisplayViewControllerException" reason:@"请确定添加了所有子控制器" userInfo:nil];
    }
    
    // 清空之前所有标题
    [self.titleLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.titleLabels removeAllObjects];
    
    // 刷新表格
    [self.contentScrollView reloadData];
    
    // 重新设置标题
    if (_titleColorGradientStyle == YZTitleColorGradientStyleFill || _titleWidth == 0) {
        [self setUpTitleWidth];
    }
    
    [self setUpAllTitle];
    
    // 默认选中标题
    self.selectIndex = _selectIndex;
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.childViewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIndentifier forIndexPath:indexPath];
    
    // 移除之前的子控件
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 添加控制器
    UIViewController *vc = self.childViewControllers[indexPath.row];
    
//    vc.view.frame = self.contentScrollView.bounds;
    vc.view.frame = CGRectMake(0, 0, self.contentScrollView.yz_width, self.contentScrollView.yz_height);
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [cell.contentView addSubview:vc.view];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat itemWidth = CGRectGetWidth(scrollView.frame);
    NSInteger i = (scrollView.contentOffset.x + itemWidth * 0.5) / itemWidth;
    
    // 选中标题
    [self selectLabel:self.titleLabels[i]];
    
    // 取出对应控制器发出通知
    UIViewController *vc = self.childViewControllers[i];
    
    // 发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:YZDisplayViewClickOrScrollDidFinshNote object:vc];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        CGFloat itemWidth = CGRectGetWidth(scrollView.frame);
        NSInteger i = (scrollView.contentOffset.x + itemWidth * 0.5) / itemWidth;
        
        // 选中标题
        [self selectLabel:self.titleLabels[i]];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _startOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 点击和动画的时候不需要设置
    if (self.titleLabels.count == 0) {
        return;
    }
    
    [self updateUI:scrollView];
}

- (void)updateUI:(UIScrollView *)scrollView {
    CGFloat progress = 0.0;
    NSInteger targetIndex = 0;
    NSInteger sourceIndex = 0;

    NSInteger index = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width);
    
    progress = (scrollView.contentOffset.x - scrollView.bounds.size.width * index) / scrollView.bounds.size.width;
    if (progress == 0.0) {
        return;
    }
    
    if (scrollView.contentOffset.x > _startOffsetX) {   //左滑动
        sourceIndex = index;
        targetIndex = index + 1;
        if (targetIndex > self.childViewControllers.count) {
            return;
        }
    } else {
        sourceIndex = index + 1;
        targetIndex = index;
        progress = 1 - progress;
        if (targetIndex < 0) {
            return;
        }
    }
    
    if (progress > 0.998) {
        progress = 1.0;
    }
    
    [self updateTitleScrollViewWithSourceIndex:sourceIndex targetIndex:targetIndex progress:progress];
}


- (void)updateTitleScrollViewWithSourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex progress:(CGFloat)progress {
    if (sourceIndex > self.titleLabels.count - 1 || sourceIndex < 0) {
        return;
    }
    if (targetIndex > self.titleLabels.count - 1 || targetIndex < 0) {
        return;
    }
    
    YZDisplayTitleLabel *sourceLabel = self.titleLabels[sourceIndex];
    sourceLabel.index = sourceIndex;
    
    YZDisplayTitleLabel *targetLabel = self.titleLabels[targetIndex];
    targetLabel.index = targetIndex;
    
    [self updateTitleScaleWithSourceLabel:sourceLabel targetLabel:targetLabel progress:progress];
    
    if (!_isDelayScroll) {
        [self updateUnderLineWithSourceLabel:sourceLabel targetLabel:targetLabel progress:progress];
    }
    
    [self updateCoverWithSourceLabel:sourceLabel targetLabel:targetLabel progress:progress];
    
    [self updateTitleColorGradientWithSourceLabel:sourceLabel targetLabel:targetLabel progress:progress];
}

@end
