//
//  ContentController.h
//  TableScroller
//
//  Created by zheng yan on 12-7-17.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ContentController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *controllerList;
@property (nonatomic, retain) UIPageControl *pageControl;
@end
