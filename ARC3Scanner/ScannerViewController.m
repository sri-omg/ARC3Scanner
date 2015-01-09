//
//  ViewController.m
//  ARC3Scanner
//
//  Created by Adam Overholtzer on 12/19/14.
//  Copyright (c) 2014 SRI. All rights reserved.
//

#import "ScannerViewController.h"
@import MapKit;
@import CoreLocation;

@interface ScannerViewController () <CLLocationManagerDelegate> {
    BOOL _showMapImage;
    UIImage *_shadyPersonImage;
}
@property (weak, nonatomic) IBOutlet RMScannerView *scannerView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showMapImage = YES;
    
    _shadyPersonImage = [UIImage imageNamed: @"shady.jpg"];
    
//    [self.scannerView setVerboseLogging:YES];
    
    [self.scannerView setAnimateScanner:NO];
    [self.scannerView setDisplayCodeOutline:YES];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kReorderCornersKey: @YES,
                                                              kMapZoomDegreesKey: @(0.0035),
                                                              }];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self startMapping];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.scannerView.isCaptureSessionInProgress) {
        [self.scannerView startCaptureSession]; // Start the capture
    }
    
    BOOL reorderCorners = [[NSUserDefaults standardUserDefaults] boolForKey:kReorderCornersKey];
    [[self.scannerView overlayImageView] setReorderCorners:!reorderCorners];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [self.scannerView stopCaptureSession];
}

#pragma mark - RMScannerViewDelegate

- (void)didScanCode:(NSString *)scannedCode onCodeType:(NSString *)codeType {
    NSLog(@"scanned %@: %@", codeType, scannedCode);
    if ([scannedCode hasSuffix:@".com"]) {
        _showMapImage = NO;
        [[self.scannerView overlayImageView] setImage:_shadyPersonImage];
        [[self.scannerView overlayImageView] setRotation:0];
    } else {
        if (!_showMapImage) {
            _showMapImage = YES;
            [[self.scannerView overlayImageView] setImage:nil];
            [self locationManager:self.locationManager didUpdateLocations:@[self.locationManager.location]];
        }
        _showMapImage = YES;
    }
}

- (BOOL)shouldEndSessionAfterFirstSuccessfulScan {
    return NO;
}

- (void)errorGeneratingCaptureSession:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Capture Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Shucks" otherButtonTitles:nil] show];
}

#pragma mark - Mapping


- (void)startMapping {
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusDenied) {
        [self startMapping];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if (!_showMapImage) return;
    
    CLLocation *location = locations.lastObject;
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.mapType = MKMapTypeStandard;
    options.showsBuildings = YES;
    options.showsPointsOfInterest = NO;
    options.size = CGSizeMake(300, 300);
    
    CGFloat mapZoom = [[NSUserDefaults standardUserDefaults] floatForKey:kMapZoomDegreesKey];
    MKCoordinateSpan span;
    span.latitudeDelta = mapZoom;
    span.longitudeDelta = mapZoom;
    MKCoordinateRegion region;
    region.span = span;
    region.center = location.coordinate;
    options.region = region;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        if( error ) {
            NSLog( @"An error occurred: %@", error );
        } else {
            CGPoint userPoint = [snapshot pointForCoordinate:location.coordinate];
            CGRect circle = CGRectMake(userPoint.x-location.horizontalAccuracy,
                                       userPoint.y-location.horizontalAccuracy,
                                       location.horizontalAccuracy*2,
                                       location.horizontalAccuracy*2);
            [[self.scannerView overlayImageView] setImage:[self imageByDrawingCircle:circle onImage:snapshot.image]];
        }
    }];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (_showMapImage) [[self.scannerView overlayImageView] setRotation:radians(-newHeading.trueHeading)];
//    NSLog(@"rotating %f", newHeading.trueHeading);
}

static inline double radians (double degrees) {return degrees * M_PI/180;}

- (UIImage *)imageByDrawingCircle:(CGRect)circleRect onImage:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    // get the context for CoreGraphics and clip it
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *boundingCircle = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, image.size.width, image.size.height)
                                                              cornerRadius:MAX(image.size.width, image.size.height)];
    CGContextAddPath(ctx, boundingCircle.CGPath);
    CGContextClip(ctx);
    
    // draw original image into the context
    [image drawAtPoint:CGPointZero];
    
    // draw border
    [[[UIColor whiteColor] colorWithAlphaComponent:1] setStroke];
    CGContextStrokeEllipseInRect(ctx, boundingCircle.bounds);
    
    // draw circle
    [[[UIColor blueColor] colorWithAlphaComponent:0.0666] setFill];
    CGContextFillEllipseInRect(ctx, circleRect);
    [[[UIColor blueColor] colorWithAlphaComponent:0.25] setStroke];
    CGContextStrokeEllipseInRect(ctx, circleRect);
    
    // draw center point
    CGRect centerPoint = CGRectMake(CGRectGetMidX(circleRect)-4, CGRectGetMidY(circleRect)-4, 8, 8);
    [[UIColor blueColor] setFill];
    CGContextFillEllipseInRect(ctx, centerPoint);
    [[UIColor whiteColor] setStroke];
    CGContextStrokeEllipseInRect(ctx, centerPoint);
    
    // draw N for north
    [[UIColor blackColor] setFill];
    [@"N" drawAtPoint:CGPointMake(image.size.width/2, 0) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10]}];
    
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    
    return retImage;
}


@end
