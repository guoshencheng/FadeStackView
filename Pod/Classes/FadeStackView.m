//
//  FadeStackView.m
//  renyan
//
//  Created by guoshencheng on 1/13/16.
//  Copyright © 2016 杭州自心科技. All rights reserved.
//

#import "FadeStackView.h"

@interface FadeStackView()

@property (strong, nonatomic) UIView *currentView;
@property (strong, nonatomic) UIView *nextView;
@property (assign, nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) NSMutableArray *stack;
@property (strong, nonatomic) NSMutableDictionary *cache;

@end

@implementation FadeStackView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    CGPoint screenPoint = [self convertPoint:point toView:self.superview];
    if ([self.delegate respondsToSelector:@selector(fadeStackView:hitTestWithCurrentView:touchPoint:touchView:)]) {
        return [self.delegate fadeStackView:self hitTestWithCurrentView:self.currentView touchPoint:screenPoint touchView:view];
    }
    return view;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupAndClearIfNeed:NO];
    }
    return self;
}

- (void)awakeFromNib {
    [self setupAndClearIfNeed:NO];
}

- (void)reloadData {
    [self setupAndClearIfNeed:YES];
}

- (void)setupAndClearIfNeed:(BOOL)needClear {
    !needClear ? :[self clear];
    self.cache = [NSMutableDictionary dictionary];
    self.stack = [NSMutableArray array];
    self.currentIndex = needClear ? self.currentIndex : 0;
    [self generateCurrentView];
}

- (void)fadeToIndex:(NSInteger)index {
    if (index != self.currentIndex) {
        [self cacheView:self.currentView atIndex:self.currentIndex];
        [self generateViewAtIndex:index];
        [self animateSwithView:self.currentView fromIndex:self.currentIndex toIndex:index];
        self.currentIndex = index;
    }
}

- (UIView *)dequeueViewAtIndex:(NSInteger)index {
    UIView *cell = [self.cache objectForKey:[NSString stringWithFormat:@"%@", @(index)]];
    BOOL useCell = YES;
    if ([self.delegate respondsToSelector:@selector(fadeStackView:shouldUseCell:atIndex:)]) {
        useCell = [self.delegate fadeStackView:self shouldUseCell:cell atIndex:index];
    }
    if (cell && useCell) {
        return cell;
    } else {
        return nil;
    }
}

- (void)cacheView:(UIView *)view atIndex:(NSInteger)index {
    if (!view) return;
    [self.cache setObject:view forKey:[NSString stringWithFormat:@"%@", @(index)]];
    NSInteger removed = [self addIndex:index];
    if (removed != -1) [self removeCellFormCacheAtIndex:removed];
}

- (void)animateSwithView:(UIView *)view fromIndex:(NSInteger)formIndex toIndex:(NSInteger)toIndex {
    self.currentView.alpha = 1;
    self.nextView.alpha = 0;
    self.nextView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.currentView.alpha = 0;
        self.nextView.alpha = 1;
    } completion:^(BOOL finished) {
        [self.currentView removeFromSuperview];
        self.currentView = self.nextView;
        self.nextView = nil;
    }];
}

- (UIView *)getCurrentView {
    return self.currentView;
}

- (NSInteger)getCurrentIndex {
    return self.currentIndex;
}

- (void)clear {
    [self.currentView removeFromSuperview];
    self.currentView = nil;
    [self.nextView removeFromSuperview];
    self.nextView = nil;
}

- (void)generateCurrentView {
    if (self.currentIndex < [self.datasource numberOfViewsInFadeStackView:self]) {
        self.currentView = [self viewAtIndex:self.currentIndex];
        if (self.currentView) {
            [self addSubview:self.currentView];
            self.currentView.frame = [UIScreen mainScreen].bounds;
        }
    }
}

- (void)generateViewAtIndex:(NSInteger)index {
    if (self.nextView) {
        [self.currentView removeFromSuperview];
        self.currentView = self.nextView;
        self.nextView = nil;
    }
    if (index < [self.datasource numberOfViewsInFadeStackView:self] && index >= 0) {
        self.nextView = [self viewAtIndex:index];
        if (self.nextView) {
            [self insertSubview:self.nextView atIndex:0];
            self.nextView.frame = [UIScreen mainScreen].bounds;
            self.nextView.hidden = YES;
        }
    }
}

- (NSInteger)addIndex:(NSInteger)index {
    if ([self.stack containsObject:@(index)]) {
        [self.stack removeObject:@(index)];
    }
    if (index != 0) {
        [self.stack addObject:@(index)];
    }
    if (self.stack.count > 3) {
        NSInteger removed = [[self.stack firstObject] integerValue];
        [self.stack removeObjectAtIndex:0];
        return removed;
    } else {
        return -1;
    }
}

- (UIView *)viewAtIndex:(NSInteger)index {
    return [self.datasource fadeStackView:self viewAtIndex:index];
}

- (void)removeCellFormCacheAtIndex:(NSInteger)index {
    UIView *cell = [self.cache objectForKey:[NSString stringWithFormat:@"%@", @(index)]];
    if ([self.delegate respondsToSelector:@selector(fadeStackView:willRemoveViewFromCache:)]) {
        [self.delegate fadeStackView:self willRemoveViewFromCache:cell];
    }
    [self.cache removeObjectForKey:[NSString stringWithFormat:@"%@", @(index)]];
}

@end
