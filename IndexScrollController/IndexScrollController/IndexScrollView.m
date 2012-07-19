//
//  IndexScrollView.m
//  IndexScrollController
//
//  Created by zheng yan on 12-7-19.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "IndexScrollView.h"

@implementation IndexScrollView
@synthesize indexScrollController = _indexScrollController;
@synthesize titles = _titles;
@synthesize scrollView = _scrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect labelFrame = frame;
        labelFrame.size.width = frame.size.width/3;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.delegate = self;
        [self addSubview:_scrollView];

        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;        
        
        _labelWidth = self.scrollView.bounds.size.width/3;
        _labelHeight = self.scrollView.bounds.size.height;
    }
    return self;
}

- (void)setTitles:(NSArray *)titles {
    if (titles.count < 3)
        return;
    
    if (_titles)
        [_titles release];
    
    _titles = [titles mutableCopy];
    NSRange first2Range, last2Range;
    first2Range.location = 0;
    first2Range.length = 2;
    last2Range.location = _titles.count-2;
    last2Range.length = 2;
    
    NSArray *first2 = [_titles subarrayWithRange:first2Range];
    NSArray *last2 = [_titles subarrayWithRange:last2Range];
    
    [_titles insertObjects:last2 atIndexes:[NSIndexSet indexSetWithIndexesInRange:first2Range]];
    [_titles addObjectsFromArray:first2];
    
    _scrollView.contentSize = CGSizeMake(_labelWidth*(_titles.count), _labelHeight);
    [self layoutIndexTitles];
}

- (void)scrollToIndex:(NSInteger)index {
    CGPoint offset = _scrollView.contentOffset;
    offset.x = _labelWidth*(index+1);
    [_scrollView setContentOffset:offset animated:YES];
}

- (void)layoutIndexTitles {
    for (UIView *view in self.scrollView.subviews)
        [view removeFromSuperview];
    
    int i = 0;
    
    for (id title in self.titles) {  
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_labelWidth*i, 0, _labelWidth, _labelHeight)];
        NSLog(@"title: %@: %@", title, label);

        label.text = (NSString *)title;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:20];
        
        [self.scrollView addSubview:label];
        [label release];
        i++;
    }
}
     
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int count = self.titles.count;
    
    if (scrollView.contentOffset.x > _labelWidth * (count-3)) {
        CGPoint offset = scrollView.contentOffset;
        offset.x -= _labelWidth*(count-4);        
        scrollView.contentOffset = offset;
    }
    else if (scrollView.contentOffset.x < _labelWidth/2) {
        CGPoint offset = scrollView.contentOffset;
        offset.x += _labelWidth*count;
        scrollView.contentOffset = offset;        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

@end
