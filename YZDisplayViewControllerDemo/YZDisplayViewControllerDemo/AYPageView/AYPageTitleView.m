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

@end

@implementation AYPageTitleView

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
    
    _titleColor = [UIColor blackColor];
    _titleSelectedColor = [UIColor colorWithRed:0.13 green:0.67 blue:0.93 alpha:1.00];
    _titleFontSize = 15.0;
    _titleMargin = 20.0;
    
    _maximumScaleFactor = 1.2;
    
    _lineViewHeight = 3;
    _lineViewWidth = 0;
    
    _coverMargin = 6;
    _coverViewHeight = 26;
    _coverViewRadius = 13;
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
    if (!targetLabel) {
        return;
    }
    
    if (targetLabel.tag == _currentIndex) {
        if ([_delegate respondsToSelector:@selector(titleView:repeatClickAtIndex:)]) {
            [_delegate titleView:self repeatClickAtIndex:_currentIndex];
        }
        return;
    }
    
    UILabel *sourcelabel = self.titleLabels[_currentIndex];
    sourcelabel.textColor = _titleColor;
    targetLabel.textColor = _titleSelectedColor;
    
    _currentIndex = targetLabel.tag;

    if ([_delegate respondsToSelector:@selector(titleView:clickAtIndex:)]) {
        [_delegate titleView:self clickAtIndex:_currentIndex];
    }

    [self centerLabel:targetLabel animated:YES];
    
    if (_isScaleEnable) {
        [UIView animateWithDuration:0.27 animations:^{
            sourcelabel.transform = CGAffineTransformIdentity;
            targetLabel.transform = CGAffineTransformMakeScale(_maximumScaleFactor, _maximumScaleFactor);
        }];
    }
    
    if (_isShowLineView) {
        [UIView animateWithDuration:0.27 animations:^{
            self.lineView.yz_width = _lineViewWidth > 0 ? _lineViewWidth :  targetLabel.yz_width;
            self.lineView.yz_centerX = targetLabel.yz_centerX;
        }];
    }
    
    if (_isShowCoverView) {
        CGFloat coverX = _isTitleViewScrollEnable ? (targetLabel.yz_x - _coverMargin) : targetLabel.yz_x;
        CGFloat coverW = _isTitleViewScrollEnable ? (targetLabel.yz_width + _coverMargin * 2) : targetLabel.yz_width;
        [UIView animateWithDuration:0.27 animations:^{
            self.coverView.yz_x = coverX;
            self.coverView.yz_width = coverW;
        }];
    }
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
    if (_isScaleEnable) {
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

#pragma mark - public
- (void)clickTitleAtIndex:(NSUInteger)index {
    if (index + 1 > self.titleLabels.count) {
        return;
    }
    
    UILabel *targetLabel = self.titleLabels[index];
    [self titleClick:targetLabel.gestureRecognizers.firstObject];
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
