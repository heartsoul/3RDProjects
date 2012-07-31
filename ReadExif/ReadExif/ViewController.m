//
//  ViewController.m
//  ReadExif
//
//  Created by zheng yan on 12-4-26.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "ViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "ImageIO/ImageIO.h"
#import "RTCoreDataManager.h"
#import "DateSelector.h"
#import "NumSelector.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize scrollView;
@synthesize gpsInfo;
@synthesize imageView;
@synthesize metaData;
@synthesize progressBar;
@synthesize locationManager;
@synthesize book;

- (void)viewDidLoad
{
    [self.scrollView setContentSize:CGSizeMake(320, 460)];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.progressBar setProgress:0];
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, 100, 40)];
    [testLabel setText:@"AUTO BOUNDS"];
    [testLabel setBackgroundColor:[UIColor clearColor]];
    [self.imageView addSubview:testLabel];
    
    [super viewDidLoad];
    
    // set gradient background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor orangeColor] CGColor],(id)[[UIColor blueColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    
//    gradient.startPoint = CGPointMake(0.0, 0.0);
//    gradient.startPoint = CGPointMake(1.0, 1.0);

    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // demo code: frame vs bounds
    UIView *blackLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIView *orangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)]; 
    orangeLabel.bounds = CGRectMake(0, 0, 50, 50);
    blackLabel.backgroundColor = [UIColor blackColor];
    orangeLabel.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:blackLabel];
    [self.view addSubview:orangeLabel];
}

- (void)viewDidUnload
{
    [self setGpsInfo:nil];
    [self setImageView:nil];
    [self setImageView:nil];
    [self setProgressBar:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)dealloc {
    [gpsInfo release];
    [imageView release];
    [progressBar release];
    [scrollView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)choosePhoto:(id)sender {
    UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
    [picker setDelegate:self];
    [self presentModalViewController:picker animated:YES];
}

- (IBAction)fetchImage:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"in async");
    });
    self.book = [NSEntityDescription
                 insertNewObjectForEntityForName:@"Book"
                 inManagedObjectContext:[[RTCoreDataManager sharedInstance] managedObjectContext]];

    [self.imageView setImage:nil];
    [[RTRequestProxy sharedInstance] fetchImage:[NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Shanghai_Skyscape.jpg/800px-Shanghai_Skyscape.jpg"] target:self action:@selector(onImageFetched:)];
    
    [[[RTCoreDataManager sharedInstance] managedObjectContext] deleteObject:self.book];
//    [[RTCoreDataManager sharedInstance] saveContext];
}

- (IBAction)addEvent:(id)sender {
//    EKEventEditViewController *eventViewController = [[EKEventEditViewController alloc] init];
//    EKEvent *event = [EKEvent eventWithEventStore:[[EKEventStore alloc] init]];
    
    EKEventEditViewController* controller = [[EKEventEditViewController alloc] init];
    controller.eventStore = [[EKEventStore alloc] init];
    controller.editViewDelegate = self;
    [self presentModalViewController: controller animated:YES];
    [controller release];
}

- (IBAction)viewEvent:(id)sender {
    EKEventViewController *eventViewController = [[EKEventViewController alloc] init];
    eventViewController.event = [EKEvent eventWithEventStore:[[EKEventStore alloc] init]];
    eventViewController.allowsEditing = YES;
    eventViewController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:eventViewController];
    [self presentModalViewController:nav animated:YES];
    [eventViewController release];
}

- (IBAction)takePhoto:(id)sender {
    [self.locationManager startUpdatingLocation];

    picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = NO;
    UIView *overlay = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    UIButton *shotButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 0, 50, 50)];
    UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 0, 50, 50)];
    
    [overlay addSubview:shotButton];
    [overlay addSubview:dismissButton];
    
    [shotButton setTitle:@"Shot" forState:UIControlStateNormal];
    [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];

    [shotButton addTarget:self action:@selector(takeShot:) forControlEvents:UIControlEventTouchUpInside];
    [dismissButton addTarget:self action:@selector(dismissShot:) forControlEvents:UIControlEventTouchUpInside];
    
    picker.cameraOverlayView = overlay;

    [picker setDelegate:self];
    [self presentModalViewController:picker animated:YES];
}

- (void)takeShot:(id)sender {
    [picker takePicture];
}

- (void)dismissShot:(id)sender {
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey: UIImagePickerControllerOriginalImage];
    NSLog(@"photo info: %@", info);
    
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) { // from camera
        CLLocation *location = self.locationManager.location;
        [self.locationManager stopUpdatingLocation];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        NSDictionary *gpsInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:[self getGPSDictionaryForLocation:location], @"{GPS}", nil];
        [library writeImageDataToSavedPhotosAlbum:imageData metadata:gpsInfoDict completionBlock:^(NSURL *assetURL, NSError *error) {
            NSLog(@"write image finished:%@", assetURL);

            [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                NSDictionary *metadataDict = [representation metadata]; 
                self.metaData = [metadataDict objectForKey:@"{GPS}"];
//                NSLog(@"%@",metadataDict);
                NSString *lat = [[metadataDict objectForKey:@"{GPS}"] objectForKey:@"Latitude"];
                NSString *lng = [[metadataDict objectForKey:@"{GPS}"] objectForKey:@"Longitude"];
                [self.gpsInfo setText:[NSString stringWithFormat:@"%@; %@", lat, lng]];
            } failureBlock:^(NSError *error) {
                NSLog(@"%@",[error description]);
            }];

        }]; 
            
    } else {    // from library
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSDictionary *metadataDict = [representation metadata]; 
            self.metaData = [metadataDict objectForKey:@"{GPS}"];
//            NSLog(@"%@",metadataDict);
            NSString *lat = [[metadataDict objectForKey:@"{GPS}"] objectForKey:@"Latitude"];
            NSString *lng = [[metadataDict objectForKey:@"{GPS}"] objectForKey:@"Longitude"];
            [self.gpsInfo setText:[NSString stringWithFormat:@"%@; %@", lat, lng]];
            
        } failureBlock:^(NSError *error) {
            NSLog(@"%@",[error description]);
        }];
    }
    [library release];
    
    UIImage *smallImage = [self imageWithImage:image scaledToSize:CGSizeMake(640, 640)];
    NSLog(@"before resize: width: %f, height: %f", image.size.width, image.size.height);
    NSLog(@"after resize:  width: %f, height: %f", smallImage.size.width, smallImage.size.height);

    [self.imageView setImage:smallImage];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:NSLocalizedString(@"yyyyMMddHHmmss",nil)];
    NSString *fileName = [NSString stringWithFormat:@"/test_%@.jpg", [formatter stringFromDate:date]];
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingString:fileName];
    
    NSData *smallImageData = UIImageJPEGRepresentation(smallImage, .7);
    [smallImageData writeToFile:filePath atomically:YES];
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSLog(@"file size: %d", [[attrs objectForKey:@"NSFileSize"] intValue]);

    [self.imageView setImage:[UIImage imageWithContentsOfFile:filePath]];

//    [picker dismissModalViewControllerAnimated:YES];
}


//FOR CAMERA IMAGE

- (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location {
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];
    
    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];
    
    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
    [formatter release];
    
    // Latitude
    CGFloat latitude = location.coordinate.latitude;
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } else {
        [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    
    // Longitude
    CGFloat longitude = location.coordinate.longitude;
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } else {
        [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    
    // Altitude
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } else {
            [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        }
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }
    
    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setObject:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }
    
    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setObject:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }
    
    return gps;
}

// resize 
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (void) uploadImage:(UIImage *)image {
    
}

// ASI http download progress
- (void)setProgress:(float)newProgress {
    self.progressBar.progress = newProgress;
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength {
    NSLog(@"download progress: %lld", newLength);
}

- (void)onImageFetched:(RTNetworkResponse *)response {
    self.progressBar.progress = 1.0f;

    // network error
    if ([response status] != RTNetworkResponseStatusSuccess) {
        NSLog(@"RTNetwork error");
        return;
    }
    
    id status = [[response content] objectForKey:@"status"];
    if (status && [[(NSString *)status uppercaseString] isEqualToString:@"OK"]) {
        NSString *imagePath = [[response content] objectForKey:@"imagePath"];
        //        NSLog(@"imagePath:%@", imagePath);
        [self.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, nil, nil);
    }
}

#pragma mark - Event delegate methods
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_2) {
    [controller dismissModalViewControllerAnimated:YES];
}

/**
 Returns the URL to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];    
    NSLog(@"document dir: %@", documentDir);
    return documentDir;
}

- (IBAction)dateSelectAction:(id)sender {    
    [self crash];

    DateSelector *selector = [[DateSelector alloc] init];
    [selector setDataSource:[NSArray arrayWithObjects:[NSNumber numberWithInt:5],
                             [NSNumber numberWithInt:10],
                             [NSNumber numberWithInt:20],
                             [NSNumber numberWithInt:30],
                             [NSNumber numberWithInt:40],
                             [NSNumber numberWithInt:50],
                             [NSNumber numberWithInt:60], 
                             nil]];
    [selector setDelegate:self];
//    [selector setCurrentDate:[NSDate date]];
    [self.navigationController pushViewController:selector animated:YES];
}

- (IBAction)numSelectAction:(id)sender {
//    [self crash];
//    CGRect bound = self.imageView.bounds;
//    bound.origin.x -= 10;
//    bound.origin.y -= 10;
//    self.imageView.bounds = bound;
////    [self.view setNeedsLayout];
//    return;
    
    NumSelector *selector = [[NumSelector alloc] init];
    [selector setDataSource:[NSArray arrayWithObjects:[NSNumber numberWithInt:5],
                             [NSNumber numberWithInt:10],
                             [NSNumber numberWithInt:20],
                             [NSNumber numberWithInt:30],
                             [NSNumber numberWithInt:40],
                             [NSNumber numberWithInt:50],
                             [NSNumber numberWithInt:60], 
                          [NSNumber numberWithInt:90], 
                             nil]];
    [selector setDelegate:self];
    [self.navigationController pushViewController:selector animated:YES];
}

- (void)didDateSelected:(id)sender {
    NSLog(@"date selected: %@", [sender currentDate]);
    self.gpsInfo.text = [[sender currentDate] description];
}

- (void)didNumSelected:(id)sender {
    NSLog(@"number selected: %d", [sender currentNum]);
    self.gpsInfo.text = [NSString stringWithFormat:@"%d", [sender currentNum]];
}


- (void)crash {
    return;
    
    NSArray *emptyArray = [NSArray array];
    [emptyArray objectAtIndex:2];
    
    [self notSuchSelector];
}

@end
