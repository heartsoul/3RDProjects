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
    
    _indexCount = titles.count;
    _titles = [titles mutableCopy];
    NSRange first2Range, last2Range;
    first2Range.location = 0;
    first2Range.length = 2;
    last2Range.location = _indexCount-2;
    last2Range.length = 2;
    
    NSArray *first2 = [_titles subarrayWithRange:first2Range];
    NSArray *last2 = [_titles subarrayWithRange:last2Range];
    
    [_titles insertObjects:last2 atIndexes:[NSIndexSet indexSetWithIndexesInRange:first2Range]];
    [_titles addObjectsFromArray:first2];
    
    _scrollView.contentSize = CGSizeMake(_labelWidth*(_titles.count), _labelHeight);
    [self layoutIndexTitles];
}

- (void)scrollToIndex:(NSInteger)index {
    NSLog(@"scroll page %d -> %d", _currentLabelIndex, index);

    // switch offset: first <-> last
    if (_currentLabelIndex == _indexCount-1 && index == 0) {
        CGPoint firstLabelOffset = CGPointMake(_labelWidth*0, 0);
        [_scrollView setContentOffset:firstLabelOffset];
    } else if (_currentLabelIndex == 0 && index == _indexCount-1) {
        CGPoint lastLabelOffset = CGPointMake(_labelWidth*(_indexCount+1), 0);
        _scrollView.contentOffset = lastLabelOffset;        
    }
    
    CGPoint offset = _scrollView.contentOffset;
    offset.x = _labelWidth*(index+1);
    NSLog(@"%f -> %f", _scrollView.contentOffset.x, offset.x);
    [_scrollView setContentOffset:offset animated:YES];
    _currentLabelIndex = index;
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
//    if (scrollView.contentOffset.x > _labelWidth * (_indexCount+1)) {
//        CGPoint offset = scrollView.contentOffset;
//        offset.x -= _labelWidth*_indexCount;        
//        scrollView.contentOffset = offset;
//    }
//    else if (scrollView.contentOffset.x < _labelWidth*2) {
//        CGPoint offset = scrollView.contentOffset;
//        offset.x += _labelWidth*_indexCount;
//        scrollView.contentOffset = offset;        
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"end scroll dragging");    
    [self adjust];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"end scroll animation");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {    // called when scroll view grinds to a halt
    NSLog(@"end scroll decelerating");
    [self adjust];
}

- (void)adjust {
    NSUInteger posIndex = _scrollView.contentOffset.x / _labelWidth;
    CGFloat distance = _scrollView.contentOffset.x - posIndex * _labelWidth;
    if (distance > _labelWidth/2)
        posIndex += 1;
    
    NSLog(@"\n\nstop %f at pos: %d, page: %d", _scrollView.contentOffset.x, posIndex, posIndex-3);

    int pageIndex = posIndex-3;
    if (pageIndex < 0 || pageIndex > _indexCount)
        return;
    
    _currentLabelIndex = pageIndex;    
    if ([self.indexScrollController respondsToSelector:@selector(didIndexScrolledToIndex:)])
        [self.indexScrollController didIndexScrolledToIndex:pageIndex+1];

}
@end
