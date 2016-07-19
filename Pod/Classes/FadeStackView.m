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
    self.currentIndex = needClear ? self.currentIndex : 0;
    [self generateCurrentView];
}

- (void)fadeToIndex:(NSInteger)index {
    if (index != self.currentIndex) {
        [self generateViewAtIndex:index];
        [self animateSwithView:self.currentView fromIndex:self.currentIndex toIndex:index];
        self.currentIndex = index;
    }
}

- (void)animateSwithView:(UIView *)view fromIndex:(NSInteger)formIndex toIndex:(NSInteger)toIndex {
    self.currentView.alpha = 1;
    self.nextView.alpha = 0;
    self.nextView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.currentView.alpha = 0;
        self.nextView.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.currentView removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(fadeStackView:didEndDisplayView:atIndex:)]) {
                [self.delegate fadeStackView:self didEndDisplayView:self.currentView atIndex:formIndex];
            }
            self.currentView = self.nextView;
            self.nextView = nil;
            self.currentView.alpha = 1;
            self.currentView.hidden = NO;
        }
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
            self.currentView.frame = [self cellRect];
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
            self.nextView.frame = [self cellRect];
            self.nextView.hidden = YES;
        }
    }
}

- (CGRect)cellRect {
    if ([self.datasource respondsToSelector:@selector(fadeStackViewCellRect:)]) {
        return [self.datasource fadeStackViewCellRect:self];
    } else {
        return [UIScreen mainScreen].bounds;
    }
}

- (UIView *)viewAtIndex:(NSInteger)index {
    return [self.datasource fadeStackView:self viewAtIndex:index];
}

@end
