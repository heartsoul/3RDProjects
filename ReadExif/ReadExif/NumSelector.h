//
//  NumSelector.h
//  ReadExif
//
//  Created by zheng yan on 12-6-12.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NumSelectorDelegate <NSObject>
-(void)didNumSelected:(id)sender;
@end

@interface NumSelector : UIViewController<UITextFieldDelegate, UIScrollViewDelegate>

- (id)init;

@property (retain, nonatomic) NSArray *dataSource;
@property (assign, nonatomic) NSInteger currentNum;
@property (assign, nonatomic) id<NumSelectorDelegate> delegate;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) UITextField *textField;

@end
