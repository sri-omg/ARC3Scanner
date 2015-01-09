//
//  SettingsTableViewController.m
//  ARC3Scanner
//
//  Created by Adam Overholtzer on 1/8/15.
//  Copyright (c) 2015 SRI. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "ARC3Helper.h"

typedef NS_ENUM(NSInteger, ScannerSettingsSections) {
    ScannerSettingsSectionBorders,
    ScannerSettingsSectionMap,
    ScannerSettingsSectionPhoto,
    ScannerSettingsSectionAdvanced,
};

typedef NS_ENUM(NSInteger, ScannerSettingsPhotoRows) {
    ScannerSettingsPhotoRowDefault,
    ScannerSettingsPhotoRowCustom,
    ScannerSettingsPhotoRowText,
};

@interface SettingsTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *reorderCornersSwitch;
@property (weak, nonatomic) IBOutlet UISlider *borderWidthSlider;
@property (weak, nonatomic) IBOutlet UISlider *borderColorSlider;
@property (weak, nonatomic) IBOutlet UITextField *photoTextField;
@property (weak, nonatomic) IBOutlet UISlider *mapZoomSlider;
@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL reorderCorners = [[NSUserDefaults standardUserDefaults] boolForKey:kReorderCornersKey];
    self.reorderCornersSwitch.on = reorderCorners;
    
    CGFloat mapZoom = [[NSUserDefaults standardUserDefaults] floatForKey:kMapZoomDegreesKey];
    self.mapZoomSlider.value = mapZoom;
    
    self.borderWidthSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:kBorderWidthKey];
    self.borderColorSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:kBorderWhitenessKey];
    
    self.photoTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kPhotoTextOverlayKey];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:self.photoTextField.text forKey:kPhotoTextOverlayKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - IBActions

- (IBAction)didToggleReorderCorners:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.reorderCornersSwitch.on forKey:kReorderCornersKey];
}

- (IBAction)didChangeMapZoomSlider:(id)sender {
    [[NSUserDefaults standardUserDefaults] setFloat:self.mapZoomSlider.value forKey:kMapZoomDegreesKey];
}

- (IBAction)didChangeBorderColorSlider:(id)sender {
    [[NSUserDefaults standardUserDefaults] setFloat:self.borderColorSlider.value forKey:kBorderWhitenessKey];
}

- (IBAction)didChangeBorderWidthSlider:(id)sender {
    [[NSUserDefaults standardUserDefaults] setFloat:self.borderWidthSlider.value forKey:kBorderWidthKey];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ScannerSettingsSectionPhoto) {
        if (indexPath.row == ScannerSettingsPhotoRowCustom) {
            cell.imageView.image = [ARC3Helper customPhotoImage];
            cell.accessoryType = [ARC3Helper customPhotoExists]? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } else if (indexPath.row == ScannerSettingsPhotoRowDefault) {
            cell.accessoryType = ![ARC3Helper customPhotoExists]? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    if ([cell.contentView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell.contentView setPreservesSuperviewLayoutMargins:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ScannerSettingsSectionPhoto) {
        if (indexPath.row == ScannerSettingsPhotoRowCustom) {
            UIImagePickerController *ipc= [[UIImagePickerController alloc] init];
            ipc.delegate = self;
            ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:ipc animated:YES completion:nil];
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:[ARC3Helper customPhotoFilePath] error:nil];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:ScannerSettingsSectionPhoto] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *pngData = UIImagePNGRepresentation(image);
    if ([pngData writeToFile:[ARC3Helper customPhotoFilePath] atomically:YES]) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ScannerSettingsSectionPhoto] withRowAnimation:UITableViewRowAnimationNone];
        NSLog(@"wrote image");
    } else {
        NSLog(@"error writing image");
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end


