//
//  ViewController.h
//  ReadExif
//
//  Created by zheng yan on 12-4-26.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"
#import "RTNetwork/RTNetwork.h"
#import "ASIHTTPRequest.h"
#import "Book.h"
#import <EventKitUI/EventKitUI.h>
#import "DateSelector.h"
#import "NumSelector.h"

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate,ASIProgressDelegate, EKEventViewDelegate, EKEventEditViewDelegate, EKCalendarChooserDelegate, DateSelectorDelegate, NumSelectorDelegate>
{
    UIImagePickerController *picker;
}

- (IBAction)takePhoto:(id)sender;
- (IBAction)choosePhoto:(id)sender;
- (IBAction)fetchImage:(id)sender;
- (IBAction)addEvent:(id)sender;
- (IBAction)viewEvent:(id)sender;
- (IBAction)dateSelectAction:(id)sender;
- (IBAction)numSelectAction:(id)sender;


@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *gpsInfo;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) NSDictionary *metaData;
@property (retain, nonatomic) IBOutlet UIProgressView *progressBar;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) Book *book;
@end
