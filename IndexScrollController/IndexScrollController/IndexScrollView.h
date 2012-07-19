//
//  IndexScrollView.h
//  IndexScrollController
//
//  Created by zheng yan on 12-7-19.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INDEX_SCROLL_VIEW_HEIGHT 40

@protocol IndexScrollViewDelegate <NSObject>
- (void)didIndexScrolledToIndex:(NSInteger)index;
@end

@interface IndexScrollView : UIView<UIScrollViewDelegate> {
    CGFloat _labelWidth;
    CGFloat _labelHeight;
}

@property (nonatomic, retain) NSMutableArray *titles;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, assign) id<IndexScrollViewDelegate> indexScrollController;

- (void)scrollToIndex:(NSInteger)index;

@end
