//
//  ContentController.m
//  TableScroller
//
//  Created by zheng yan on 12-7-17.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "ContentController.h"
#import "MyTableViewController.h"

@implementation ContentController
@synthesize scrollView = _scrollView;
@synthesize controllerList = _controllerList;
@synthesize pageControl = _pageControl;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    _scrollView.contentSize = CGSizeMake(320*5, 480);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.delegate = self;
    
    self.pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(60, 400, 200, 10)] autorelease];
    _pageControl.hidden = NO;
    _pageControl.numberOfPages = 5;
    
    [self.view addSubview:_scrollView];
    [self.view addSubview:_pageControl];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
    
    NSLog(@"page:%d", page);
    [self tilePage];
}

- (void)tilePage {
    MyTableViewController *controller = [[MyTableViewController alloc] init];
    controller.view.frame = CGRectMake(320*self.pageControl.currentPage, 0, 320, 460);
    [self.scrollView addSubview:controller.view];
}

@end
