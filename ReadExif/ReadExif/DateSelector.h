//
//  DateSelectorViewController.h
//  ReadExif
//
//  Created by zheng yan on 12-6-12.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateSelectorDelegate <NSObject>
-(void)didDateSelected:(id)sender;
@end

@interface DateSelector : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)init;

@property (retain, nonatomic) NSArray *dataSource;
@property (retain, nonatomic) NSDate *currentDate;
@property (assign, nonatomic) id<DateSelectorDelegate> delegate;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)dateSelectAction:(id)sender;

@end
