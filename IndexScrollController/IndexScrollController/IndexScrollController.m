//
//  IndexScrollController.m
//  IndexScrollController
//
//  Created by zheng yan on 12-7-18.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "IndexScrollController.h"
#import "ContentViewController.h"

@interface IndexScrollController ()

@end

@implementation IndexScrollController
@synthesize contentControllers = _contentControllers;
@synthesize indexScrollView = _indexScrollView;
@synthesize contentScrollView = _contentScrollView;
@synthesize jumpFromIndex = _jumpFromIndex;

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	        
    // 1. add content scroll view
    CGRect frame = self.view.bounds;
    frame.origin.y = INDEX_SCROLL_VIEW_HEIGHT;
    frame.size.height -= INDEX_SCROLL_VIEW_HEIGHT;
    _contentScrollView = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
    _contentScrollView.delegate = self;
    [self.view addSubview:_contentScrollView];
    
    _scrollViewWidth = _contentScrollView.bounds.size.width;
    _scrollViewHeight = _contentScrollView.bounds.size.height;
    _contentScrollView.contentSize = CGSizeMake(_scrollViewWidth * (self.contentControllers.count+2), _scrollViewHeight);    
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.scrollsToTop = NO;
    _contentScrollView.pagingEnabled = YES;    
    _contentScrollView.contentSize = CGSizeMake(_scrollViewWidth * (self.contentControllers.count+2), _scrollViewHeight);    
    
    // 2. add index scroll view
    if (!self.indexScrollView)
        _indexScrollView = [[[IndexScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, INDEX_SCROLL_VIEW_HEIGHT)] autorelease];
    
    [_indexScrollView setTitles:[_contentControllers valueForKeyPath:@"title"]];    
    [_indexScrollView setIndexScrollController:self];
    [self.view addSubview:_indexScrollView];
    
    // 3. show controller
    [self jumpToControllerIndex:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Private methods

- (void)jumpToControllerIndex:(NSUInteger)index {
    if (index >= self.contentControllers.count)
        return;
    
    NSLog(@"jump to controller: %d", index);
    
    currentPlaceIndex = index+1;    
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = _scrollViewWidth*currentPlaceIndex;
    
    self.contentScrollView.contentOffset = offset;
    [self pageChanged];
}

// paste controller's view in scrollview
- (void)placeController:(UIViewController *)controller atIndex:(int)index
{
    if (index < 0)
        return;
    if (index > self.contentControllers.count+1)
        return;
        
    CGRect frame = controller.view.frame;
    frame.origin.x = _scrollViewWidth*index;
    controller.view.frame = frame;
    [self.contentScrollView addSubview:controller.view];
//    NSLog(@"===== place controller %d at position %d, x: %f", [self.contentControllers indexOfObject:controller], index, frame.origin.x);
}

- (UIViewController *)controllerForPlaceIndex:(NSUInteger)placeIndex {    
    return [self.contentControllers objectAtIndex:[self controllerIndexFromPlaceIndex:placeIndex]];
}

- (NSUInteger)controllerIndexFromPlaceIndex:(NSUInteger)placeIndex {
    NSUInteger controllerIndex = (placeIndex+(self.contentControllers.count-1)) % self.contentControllers.count;
    return controllerIndex;
}

- (void)pageChanged {
    [self placeController:[self controllerForPlaceIndex:currentPlaceIndex] atIndex:currentPlaceIndex];
    if (!_jumpFromIndex)
        [self.indexScrollView scrollToIndex:[self controllerIndexFromPlaceIndex:currentPlaceIndex]];
    
    // place last controller's screenshot at the first placement
    int preIndex = currentPlaceIndex-1;
    if (preIndex <= 0) 
        [self placeController:[self.contentControllers lastObject] atIndex:preIndex];
    else
        [self placeController:[self controllerForPlaceIndex:preIndex] atIndex:preIndex];
    
    // place first controller's screenshot at the last palcement
    int nextIndex = currentPlaceIndex+1;
    if (nextIndex >= self.contentControllers.count+1)
        [self placeController:[self.contentControllers objectAtIndex:0] atIndex:nextIndex];
    else
        [self placeController:[self controllerForPlaceIndex:nextIndex] atIndex:nextIndex];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int count = self.contentControllers.count;
    
    if (scrollView.contentOffset.x > _scrollViewWidth * count+_scrollViewWidth/2) {
        CGPoint offset = scrollView.contentOffset;
        offset.x -= _scrollViewWidth*count;        
        scrollView.contentOffset = offset;
    }
    else if (scrollView.contentOffset.x < _scrollViewWidth/2) {
        CGPoint offset = scrollView.contentOffset;
        offset.x += _scrollViewWidth*count;
        scrollView.contentOffset = offset;        
    }
    	
    // change when more than 50% of the previous/next page is visible
    int placeIndex = floor((scrollView.contentOffset.x - _scrollViewWidth / 2) / _scrollViewWidth) + 1;    
    if (currentPlaceIndex != placeIndex) {
        currentPlaceIndex = placeIndex;
        [self pageChanged];
    }
}

#pragma mark - IndexScrollView Delegate
- (void)didIndexScrolledToIndex:(NSInteger)index {
    _jumpFromIndex = YES;
    [self jumpToControllerIndex:index];
    _jumpFromIndex = NO;
}

@end
