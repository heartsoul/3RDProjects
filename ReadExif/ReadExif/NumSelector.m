//
//  NumSelector.m
//  ReadExif
//
//  Created by zheng yan on 12-6-12.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "NumSelector.h"

@interface NumSelector ()

@end

@implementation NumSelector
@synthesize tableView = _tableView;
@synthesize textField = _textField;
@synthesize dataSource = _dataSource;
@synthesize currentNum = _currentNum;
@synthesize delegate = _delegate;

- (id)init {
    self = [super initWithNibName:@"NumSelector" bundle:nil];
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
    self.currentNum = 0;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // auto layout
    CGFloat textFiledHeight = self.textField.bounds.size.height;
    CGFloat viewHeight = self.view.bounds.size.height;
    
    CGRect pickerFrame = self.textField.frame;
    pickerFrame.origin.y = viewHeight-textFiledHeight;
    self.textField.frame = pickerFrame;
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = viewHeight-textFiledHeight;
    self.tableView.frame = tableFrame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_tableView release];
    [_textField release];
    [super dealloc];
}

#pragma mark - TableView DataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dateCell"];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"dateCell"];

    if (indexPath.row == self.dataSource.count) {
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)] autorelease];
        self.textField = [[[UITextField alloc] initWithFrame:CGRectMake(100, 0, 140, 40)] autorelease];
        [label setText:@"volumn:"];
        [self.textField setPlaceholder:@"number"];
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:self.textField];
        [self.textField setDelegate:self];
        [self.textField setKeyboardType:UIKeyboardTypeNumberPad];
        return cell;
    }

    NSString *text = [NSString stringWithFormat:@"%d minutes ago", [[self.dataSource objectAtIndex:indexPath.row] intValue]];
    cell.textLabel.text = text;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self dataSource] count]+1;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentNum = [[self.dataSource objectAtIndex:indexPath.row] intValue];
    [self.delegate didNumSelected:self];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.textField resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"offset y: %f", scrollView.contentOffset.y);
    NSLog(@"view   y: %f", self.navigationController.view.frame.origin.y);
    
    if (self.navigationController.view.frame.origin.y < -44 || self.navigationController.view.frame.origin.y > 0)
        return;

    CGRect frame = self.navigationController.view.frame;
    frame.origin.y -= scrollView.contentOffset.y;
    if (frame.origin.y < -44)
        frame.origin.y = -44;
    if (frame.origin.y > 0)
        frame.origin.y = 0;
    
    frame.size.height += scrollView.contentOffset.y;
    self.navigationController.view.frame = frame;
}

- (void)doneAction:(id)sender {
    self.currentNum = [self.textField.text intValue];
    [self.delegate didNumSelected:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {        // became first responder
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 220, 0);

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - Customize number board
- (void)keyboardWillShow:(NSNotification *)note {  
    // create custom button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setImage:[UIImage imageNamed:@"doneup.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"donedown.png"] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // locate keyboard view
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        // keyboard view found; add the custom button to it
        if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
            [keyboard addSubview:doneButton];
    }
}

@end
