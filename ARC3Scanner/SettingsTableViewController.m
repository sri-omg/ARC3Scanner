//
//  SettingsTableViewController.m
//  ARC3Scanner
//
//  Created by Adam Overholtzer on 1/8/15.
//  Copyright (c) 2015 SRI. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "ScannerViewController.h"

@interface SettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *reorderCornersSwitch;
@property (weak, nonatomic) IBOutlet UISlider *mapZoomSlider;
@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL reorderCorners = [[NSUserDefaults standardUserDefaults] boolForKey:kReorderCornersKey];
    self.reorderCornersSwitch.on = reorderCorners;
    
    CGFloat mapZoom = [[NSUserDefaults standardUserDefaults] floatForKey:kMapZoomDegreesKey];
    self.mapZoomSlider.value = mapZoom;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)didToggleReorderCorners:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.reorderCornersSwitch.on forKey:kReorderCornersKey];
}

- (IBAction)didChangeMapZoomSlider:(id)sender {
    [[NSUserDefaults standardUserDefaults] setFloat:self.mapZoomSlider.value forKey:kMapZoomDegreesKey];
}

#pragma mark - Table view data source


@end
