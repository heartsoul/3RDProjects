//
//  HHViewController.m
//  test
//
//  Created by Eric on 12-2-16.
//  Copyright (c) 2012年 Tian Tian Tai Mei Net Tech (Bei Jing) Lt.d. All rights reserved.
//

#import "HHViewController.h"
#import "HHFullScreenViewController.h"
#import "WiAdView.h"
@implementation HHViewController
@synthesize tableView;

- (void)dealloc
{
    [tableView release];
    [super dealloc]; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static int i = 0;
    static NSString *CellIdentif = @"friends-cell";
    UITableViewCell *cell =(UITableViewCell *)[TableView dequeueReusableCellWithIdentifier:CellIdentif];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentif] autorelease];
    }
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
	
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [subviews release];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",i]];
    button.frame = CGRectMake(250.0, 5.0, image.size.width, image.size.height);
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView  addSubview:button];
   // cell.imageView.image = [UIImage imageNamed:@"sms_share.png"];
    cell.textLabel.text = @"点击后面的图片看动画";
    i++;
    if (i == 8)
    {
        i = 0;
    }
    return cell;
}

- (void)buttonDown:(id)sender
{
    kIsAdShow;
    UIButton *button = (UIButton *)sender;
    CGRect frame =[self.view.window convertRect:self.view.window.frame
                                       fromView:button];
   
    viewController = [[HHFullScreenViewController alloc] 
                      initWithNibName:@"HHFullScreenViewController" bundle:nil];
    
    UIView *toview = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,300, 300)];
    toview.clipsToBounds = NO;
    toview.autoresizesSubviews = YES;
    
    [[toview layer] setShadowOffset:CGSizeMake(4, 4)];
    [[toview layer] setShadowRadius:4];
    [[toview layer] setShadowOpacity:1.0];
    [[toview layer] setShadowColor:[UIColor blackColor].CGColor];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(5,142, 290,50);
    [button1 setTitle:@"点我" forState:UIControlStateNormal];
    [toview addSubview:button1];
    toview.backgroundColor = [UIColor blueColor];
    [button1 addTarget:viewController action:@selector(viewDismiss:)  forControlEvents:UIControlEventTouchUpInside];
    [viewController setFromView:button toView:toview withX:frame.origin.x withY:frame.origin.y];
    [toview release];
    [viewController startFirstAnimation];
    [self.view.window addSubview:viewController.view];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor  = [UIColor blueColor];
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0.0,-800,320,800)];
    tempView.backgroundColor = [UIColor blueColor];
    
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(20.0, 720.0, 60, 69)];
    imageview.image = [UIImage imageNamed:@"6.png"];
    [tempView addSubview:imageview];
    
    [tableView addSubview:tempView];
    [tableView release];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.contentInset = UIEdgeInsetsMake(100.0f, 0.0f, 0.0f, 0.0f);
    
    WiAdView* adView = [WiAdView adViewWithResId:@"4844096a1364e610" style:kWiAdViewStyleBanner320_50];
    adView.center = CGPointMake(160.0,20);
    adView.delegate = self;
    adView.refreshInterval = 31;
    adView.adBgColor = [UIColor colorWithRed:1.0f green:(CGFloat)0x66/255 blue:(CGFloat)0x33/255 alpha:1.0f];
    [self.view addSubview:adView];
    [adView requestAd];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"request-close.png"]];
    [self.view addSubview:imageView];
    imageView.center = CGPointMake(310,adView.center.y);
    
    /*
    UIView *headview = [[UIView alloc]initWithFrame:CGRectMake(0.0,0.0,320, 70)];
    headview.backgroundColor = [UIColor clearColor];
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 60, 69)];
    imageview.image = [UIImage imageNamed:@"6.png"];
    [headview addSubview:imageview];
    tableView.tableHeaderView = headview;
    [imageview release];
     */
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
