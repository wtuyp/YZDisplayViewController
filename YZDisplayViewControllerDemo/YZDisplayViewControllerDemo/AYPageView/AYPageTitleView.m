//
//  AYPageTitleView.m
//  YZDisplayViewControllerDemo
//
//  Created by alpha yu on 02/04/2018.
//  Copyright © 2018 yz. All rights reserved.
//

#import "AYPageTitleView.h"

#import "UIView+Frame.h"

@interface AYPageTitleView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) NSMutableArray<UILabel *> *titleLabels;

@property (nonatomic, assign) CGFloat startR;
@property (nonatomic, assign) CGFloat startG;
@property (nonatomic, assign) CGFloat startB;

@property (nonatomic, assign) CGFloat endR;
@property (nonatomic, assign) CGFloat endG;
@property (nonatomic, assign) CGFloat endB;

@end

@implementation AYPageTitleView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initParams];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initParams];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles {
    return [self initWithFrame:frame titles:titles currentIndex:0];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles currentIndex:(NSUInteger)currentIndex {
    self = [super initWithFrame:frame];
    if (self) {
        [self initParams];
        _titles = titles;
        
        self.currentIndex = currentIndex;
    }
    return self;
}

- (void)initParams {
    _isTitleViewScrollEnable = YES;
    
    _currentIndex = 0;
    
    _titleViewHeight = 44.0;
    _titleViewBackgroundColor = [UIColor whiteColor];
    
    self.titleColor = [UIColor blackColor];
    self.titleSelectedColor = [UIColor colorWithRed:0.13 green:0.67 blue:0.93 alpha:1.00];
    _titleFontSize = 15.0;
    _titleMargin = 20.0;
    
    _maximumScaleFactor = 1.2;
    
    _lineViewHeight = 3.0;
    _lineViewWidth = 0;
    
    _coverMargin = 6.0;
    _coverViewHeight = 26.0;
    _coverViewRadius = 13.0;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self setUpUI];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    self.scrollView.backgroundColor = _titleViewBackgroundColor;
    
    [self setUpLabelsLayout];
    [self setUpLineViewLayout];
    [self setUpCoverViewLayout];
}



- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
    }
    return _coverView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
    }
    return _lineView;
}

- (NSMutableArray<UILabel *> *)titleLabels {
    if (!_titleLabels) {
        _titleLabels = [[NSMutableArray alloc] init];
    }
    return _titleLabels;
}

- (void)setUpUI {
    [self addSubview:self.scrollView];
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.titleLabels removeAllObjects];
    
    [self setUpTitleLabels];
    [self setUpLineView];
    [self setUpCoverView];
}

- (void)setUpTitleLabels {
    for (NSInteger i = 0; i < _titles.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.tag = i;
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.scrollView addSubview:label];
        [self.titleLabels addObject:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = YES;
    }
}

- (void)setUpLineView {
    if (!_isShowLineView) {
        return;
    }

    [self.scrollView insertSubview:self.lineView atIndex:0];
}

- (void)setUpCoverView {
    if (!_isShowCoverView) {
        return;
    }

    [self.scrollView insertSubview:self.coverView atIndex:0];
}


#pragma mark - gesture
- (void)titleClick:(UITapGestureRecognizer *)tap {
    UILabel *targetLabel = (UILabel *)tap.view;
    [self updateTitle:targetLabel isRespondsDelegate:YES];
}

- (void)centerLabel:(UILabel *)label animated:(BOOL)animated {
    if (!_isTitleViewScrollEnable) {
        return;
    }
    
    CGFloat offsetX = label.center.x - self.scrollView.bounds.size.width * 0.5;
    
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    CGFloat maxOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    
    if (maxOffsetX < 0) {
        maxOffsetX = 0;
    }
    
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

- (void)updateTitle:(UILabel *)label isRespondsDelegate:(BOOL)flag {
    if (!label) {
        return;
    }
    
    if (label.tag == _currentIndex) {
        if (flag) {
            if ([_delegate respondsToSelector:@selector(titleView:repeatClickAtIndex:)]) {
                [_delegate titleView:self repeatClickAtIndex:_currentIndex];
            }
        }
        return;
    }
    
    UILabel *sourcelabel = self.titleLabels[_currentIndex];
    sourcelabel.textColor = _titleColor;
    label.textColor = _titleSelectedColor;
    
    _currentIndex = label.tag;
    
    if (flag) {
        if ([_delegate respondsToSelector:@selector(titleView:clickAtIndex:)]) {
            [_delegate titleView:self clickAtIndex:_currentIndex];
        }
    }
    
    [self centerLabel:label animated:YES];
    
    if (_isTitleScaleEnable) {
        [UIView animateWithDuration:0.27 animations:^{
            sourcelabel.transform = CGAffineTransformIdentity;
            label.transform = CGAffineTransformMakeScale(_maximumScaleFactor, _maximumScaleFactor);
        }];
    }
    
    if (_isShowLineView) {
        [UIView animateWithDuration:0.27 animations:^{
            self.lineView.yz_width = _lineViewWidth > 0 ? _lineViewWidth : label.yz_width;
            self.lineView.yz_centerX = label.yz_centerX;
        }];
    }
    
    if (_isShowCoverView) {
        CGFloat coverW = _isTitleViewScrollEnable ? (label.yz_width + _coverMargin * 2) : label.yz_width;
        CGFloat coverX = _isTitleViewScrollEnable ? (label.yz_x - _coverMargin) : label.yz_x;
        [UIView animateWithDuration:0.27 animations:^{
            self.coverView.yz_x = coverX;
            self.coverView.yz_width = coverW;
        }];
    }
}

#pragma mark - layout
- (void)setUpLabelsLayout {
    CGFloat labelX = 0.0;
    CGFloat labelW = 0.0;
    
    for (NSInteger i = 0; i < self.titleLabels.count; i++) {
        UILabel *label = self.titleLabels[i];
        
        if (_isTitleViewScrollEnable) {
            NSString *title = self.titles[i];
            label.text = _titles[i];
            label.textColor = (i == _currentIndex ? _titleSelectedColor : _titleColor);
            label.font = [UIFont systemFontOfSize:_titleFontSize];
            labelW = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : label.font} context:nil].size.width;
            labelX = i == 0 ? _titleMargin * 0.5 : (CGRectGetMaxX(self.titleLabels[i-1].frame) + _titleMargin);
        } else {
            labelW = self.bounds.size.width / (CGFloat)self.titleLabels.count;
            labelX = labelW * (CGFloat)i;
        }
        label.frame = CGRectMake(labelX, 0.0, labelW, self.frame.size.height);
    }
    
    if (_isTitleViewScrollEnable) {
        UILabel *lastLabel = self.titleLabels.lastObject;
        self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastLabel.frame) + _titleMargin * 0.5, self.scrollView.frame.size.height);
    }

    if (_currentIndex  + 1 > self.titleLabels.count) {
        return;
    }
    
    UILabel *label = self.titleLabels[_currentIndex];
    if (_isTitleScaleEnable) {
        label.transform = CGAffineTransformMakeScale(_maximumScaleFactor, _maximumScaleFactor);
    }

    if (_isTitleViewScrollEnable) {
        if (_currentIndex > 0) {
            [self centerLabel:label animated:NO];
        }
    }
}

- (void)setUpLineViewLayout {
    if (_currentIndex  + 1 > self.titleLabels.count) {
        return;
    }
    
    UILabel *label = self.titleLabels[_currentIndex];
    
    self.lineView.yz_width = _lineViewWidth > 0 ? _lineViewWidth : label.yz_width;
    self.lineView.yz_centerX = label.yz_centerX;
    self.lineView.yz_height = _lineViewHeight;
    self.lineView.yz_y = self.bounds.size.height - self.lineView.yz_height;
    
    self.lineView.backgroundColor = _lineViewColor ?: _titleSelectedColor;
}

- (void)setUpCoverViewLayout {
    if (_currentIndex  + 1 > self.titleLabels.count) {
        return;
    }
    
    UILabel *label = self.titleLabels[_currentIndex];
    
    CGFloat coverX = label.yz_x;
    CGFloat coverY = (self.scrollView.yz_height - _coverViewHeight) * 0.5;
    CGFloat coverW = label.yz_width;
    
    if (_isTitleViewScrollEnable) {
        coverX -= _coverMargin;
        coverW += 2 * _coverMargin;
    }
    
    self.coverView.frame = CGRectMake(coverX, coverY, coverW, _coverViewHeight);
    self.coverView.backgroundColor = _coverViewColor ?: [UIColor lightGrayColor];
    self.coverView.layer.cornerRadius = _coverViewRadius;
}

#pragma mark - setter
- (void)setTitles:(NSArray<NSString *> *)titles {
    _titles = titles;
    self.currentIndex = _currentIndex;
    
    [self reload];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    if (self.titles.count == 0) {
        _currentIndex = 0;
        return;
    }
    
    if (currentIndex + 1 > self.titles.count) {
        _currentIndex = self.titles.count - 1;
        return;
    }
    
    _currentIndex = currentIndex;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    [_titleColor getRed:&_startR green:&_startG blue:&_startB alpha:nil];
}

- (void)setTitleSelectedColor:(UIColor *)titleSelectedColor {
    _titleSelectedColor = titleSelectedColor;
    [_titleSelectedColor getRed:&_endR green:&_endG blue:&_endB alpha:nil];
}

#pragma mark - public
- (void)clickTitleAtIndex:(NSUInteger)index {
    if (index + 1 > self.titleLabels.count) {
        return;
    }
    
    UILabel *targetLabel = self.titleLabels[index];
    [self updateTitle:targetLabel isRespondsDelegate:NO];
}

- (void)moveFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex progress:(CGFloat)progress {
    if (fromIndex + 1 > self.titleLabels.count) {
        return;
    }
    if (toIndex + 1 > self.titleLabels.count) {
        return;
    }
    
    UILabel *fromLabel = self.titleLabels[fromIndex];
    UILabel *toLabel = self.titleLabels[toIndex];
    
    UILabel *currentLabel = self.titleLabels[_currentIndex];
    
    CGFloat deltaR = _endR - _startR;
    CGFloat deltaG = _endG - _startG;
    CGFloat deltaB = _endB - _startB;
    
    fromLabel.textColor = [UIColor colorWithRed:_endR - progress * deltaR green:_endG - progress * deltaG blue:_endB - progress * deltaB alpha:1];
    toLabel.textColor = [UIColor colorWithRed:_startR + progress * deltaR green:_startG + progress * deltaG blue:_startB + progress * deltaB alpha:1];
    currentLabel.textColor = _titleColor;
    
    if (_isTitleScaleEnable) {
        CGFloat deltaScale = _maximumScaleFactor - 1.0;
        fromLabel.transform = CGAffineTransformMakeScale(_maximumScaleFactor - progress * deltaScale, _maximumScaleFactor - progress * deltaScale);
        toLabel.transform = CGAffineTransformMakeScale(1.0 + progress * deltaScale, 1.0 + progress * deltaScale);
        currentLabel.transform = CGAffineTransformIdentity;
    }
    
    if (_isShowLineView) {
        if (_lineViewWidth == 0.0) {
            CGFloat deltaW = toLabel.yz_width - fromLabel.yz_width;
            self.lineView.yz_width = fromLabel.yz_width + progress * deltaW;
        }
        
        CGFloat deltaX = toLabel.yz_centerX - fromLabel.yz_centerX;
        self.lineView.yz_centerX = fromLabel.yz_centerX + progress * deltaX;
    }
    
    if (_isShowCoverView) {
        CGFloat deltaW = toLabel.yz_width - fromLabel.yz_width;
        CGFloat deltaX = toLabel.yz_centerX - fromLabel.yz_centerX;
        
        self.coverView.yz_width = _isTitleViewScrollEnable ? (fromLabel.yz_width + 2 * _coverMargin + deltaW * progress) : (fromLabel.yz_width + deltaW * progress);
        self.coverView.yz_centerX = fromLabel.yz_centerX + progress * deltaX;
    }
    
    _currentIndex = toIndex;
    
//    if (progress > 0.98) {  //移动中也居中
//        [self centerLabel:toLabel animated:YES];
//    }
}

- (void)reload {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.titleLabels removeAllObjects];
    
    [self setUpTitleLabels];
    [self setUpLineView];
    [self setUpCoverView];
    
    [self setNeedsLayout];
}

@end
