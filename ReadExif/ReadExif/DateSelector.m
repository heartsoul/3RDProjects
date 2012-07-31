//
//  DateSelectorViewController.m
//  ReadExif
//
//  Created by zheng yan on 12-6-12.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "DateSelector.h"

@interface DateSelector ()

@end

@implementation DateSelector
@synthesize tableView = _tableView;
@synthesize datePicker = _datePicker;
@synthesize dataSource = _dataSource;
@synthesize currentDate = _currentDate;
@synthesize delegate = _delegate;

- (id)init {
    self = [super initWithNibName:@"DateSelector" bundle:nil];
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
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    self.currentDate = [NSDate date];
    [self.datePicker setDate:self.currentDate animated:NO];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setDatePicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // auto layout
    CGFloat pickerHeight = self.datePicker.bounds.size.height;
    CGFloat viewHeight = self.view.bounds.size.height;
    
    CGRect pickerFrame = self.datePicker.frame;
    pickerFrame.origin.y = viewHeight-pickerHeight;
    self.datePicker.frame = pickerFrame;
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = viewHeight-pickerHeight;
    self.tableView.frame = tableFrame;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_tableView release];
    [_datePicker release];
    [super dealloc];
}

- (IBAction)dateSelectAction:(id)sender {
    self.currentDate = [self.datePicker date];
}

#pragma mark - TableView DataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dateCell"];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"dateCell"];
    
    NSString *text = [NSString stringWithFormat:@"%d minutes ago", [[self.dataSource objectAtIndex:indexPath.row] intValue]];
    cell.textLabel.text = text;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self dataSource] count];
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor orangeColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int minutes = [[self.dataSource objectAtIndex:indexPath.row] intValue];
    self.currentDate = [NSDate dateWithTimeInterval:minutes*-60 sinceDate:[NSDate date]];
    [self.datePicker setDate:self.currentDate animated:YES];
}

- (void)doneAction:(id)sender {
    [self.delegate didDateSelected:self];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
