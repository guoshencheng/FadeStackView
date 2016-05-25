//
//  FadeStackView.h
//  renyan
//
//  Created by guoshencheng on 1/13/16.
//  Copyright © 2016 杭州自心科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FadeStackViewDatasource;
@protocol FadeStackViewDelegate;
@interface FadeStackView : UIView

@property (weak, nonatomic) id<FadeStackViewDatasource> datasource;
@property (weak, nonatomic) id<FadeStackViewDelegate> delegate;

- (void)reloadData;
- (void)fadeToIndex:(NSInteger)index;
- (UIView *)getCurrentView;
- (NSInteger)getCurrentIndex;

@end

@protocol FadeStackViewDelegate <NSObject>
@optional
- (void)fadeStackView:(FadeStackView *)fadeStackView didEndDisplayView:(UIView *)view atIndex:(NSInteger)index;
- (void)fadeStackView:(FadeStackView *)fadeStackView willRemoveViewFromCache:(UIView *)view;
- (UIView *)fadeStackView:(FadeStackView *)fadeStackView hitTestWithCurrentView:(UIView *)view touchPoint:(CGPoint)point touchView:(UIView *)touchView;
- (BOOL)fadeStackView:(FadeStackView *)fadeStackView shouldUseCell:(UIView *)cell atIndex:(NSInteger)index;

@end

@protocol FadeStackViewDatasource <NSObject>
@optional
- (UIView *)fadeStackView:(FadeStackView *)fadeStackView viewAtIndex:(NSInteger)index;
- (CGRect)fadeStackViewCellRect:(FadeStackView *)fadeStackView;
- (NSInteger)numberOfViewsInFadeStackView:(FadeStackView *)fadeStackView;

@end
