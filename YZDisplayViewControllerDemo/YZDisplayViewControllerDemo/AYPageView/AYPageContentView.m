//
//  AYPageContentView.m
//  YZDisplayViewControllerDemo
//
//  Created by alpha yu on 04/04/2018.
//  Copyright © 2018 tlm group. All rights reserved.
//

#import "AYPageContentView.h"
#import "YZFlowLayout.h"
#import "UIView+Frame.h"

static NSString * const CellIndentifier = @"CellIndentifier";


@interface AYPageContentView ()

@property (nonatomic, assign) CGFloat startOffsetX;
@property (nonatomic, strong) UICollectionView *contentScrollView;

@end

@implementation AYPageContentView

- (instancetype)initWithFrame:(CGRect)frame childViewControllers:(NSArray *)childViewControllers currentIndex:(NSUInteger)currentIndex {
    self = [super initWithFrame:frame];
    if (self) {
//        [self initParams];
//        _titles = titles;
        
        
        _childViewControllers = childViewControllers;
        
        self.currentIndex = currentIndex;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self setUpUI];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentScrollView.frame = self.bounds;
    self.contentScrollView.backgroundColor = self.backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.contentScrollView.backgroundColor = backgroundColor;
}

- (void)setUpUI {
    [self addSubview:self.contentScrollView];
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        YZFlowLayout *layout = [[YZFlowLayout alloc] init];
        
        _contentScrollView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.bounces = YES;
        _contentScrollView.delegate = (id<UICollectionViewDelegate>)self;
        _contentScrollView.dataSource = (id<UICollectionViewDataSource>)self;
        _contentScrollView.scrollsToTop = NO;
        _contentScrollView.backgroundColor = self.backgroundColor;
        
        [_contentScrollView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellIndentifier];
    }
    
    return _contentScrollView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.childViewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIndentifier forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIViewController *vc = self.childViewControllers[indexPath.row];
    vc.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:vc.view];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _startOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.childViewControllers.count == 0) {
        return;
    }
    
    [self updateUI:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self contentViewDidEndScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self contentViewDidEndScroll:scrollView];
    }
}

- (void)contentViewDidEndScroll:(UIScrollView *)scrollView {
    CGFloat width = CGRectGetWidth(scrollView.frame);
    NSInteger index = (scrollView.contentOffset.x + width * 0.5) / width;
    
    
    if (index == _currentIndex) {
        return;
    }
    _currentIndex = index;
    
    if ([_delegate respondsToSelector:@selector(contentView:didSEndScrollAtIndex:)]) {
        [_delegate contentView:self didSEndScrollAtIndex:index];
    }
}



- (void)updateUI:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0.0
        || scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.bounds.size.width) {
        return;
    }
    
    CGFloat progress = 0.0;
    NSInteger fromIndex = 0;
    NSInteger toIndex = 0;
    
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width);
    
    progress = (scrollView.contentOffset.x - scrollView.bounds.size.width * index) / scrollView.bounds.size.width;
    if (progress == 0.0) {
        return;
    }
    
    if (scrollView.contentOffset.x > _startOffsetX) {   //左滑动
        fromIndex = index;
        toIndex = index + 1;
        if (toIndex > self.childViewControllers.count) {
            return;
        }
    } else {
        fromIndex = index + 1;
        toIndex = index;
        progress = 1 - progress;
        if (toIndex < 0) {
            return;
        }
    }

    if ([_delegate respondsToSelector:@selector(contentView:scrollFromIndex:toIndex:progress:)]) {
        [_delegate contentView:self scrollFromIndex:fromIndex toIndex:toIndex progress:progress];
    }
}

#pragma mark - public
- (void)scrollToIndex:(NSUInteger)index {
    _currentIndex = index;
    self.contentScrollView.contentOffset = CGPointMake(index * self.contentScrollView.yz_width, 0);
}
@end
