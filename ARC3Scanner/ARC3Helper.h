//
//  ARC3Helper.h
//  ARC3Scanner
//
//  Created by Adam Overholtzer on 1/9/15.
//  Copyright (c) 2015 SRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kReorderCornersKey @"reorder-corners"
#define kMapZoomDegreesKey @"map-zoom"

#define kBorderWhitenessKey @"border-whiteness"
#define kBorderWidthKey @"border-width"

#define kPhotoFileName @"custom-shady"

#define kPhotoTextOverlayKey @"custom-shady"

#define kScannedImageSize 300
//#define kScannedImageBorderWidth 16

@interface ARC3Helper : NSObject

+ (NSString *)customPhotoFilePath;
+ (BOOL)customPhotoExists;
+ (UIImage *)customPhotoImage;

+ (UIImage *)imageByDrawingBoundingCirlceOnImage:(UIImage *)image;
+ (UIImage *)imageByDrawingCircle:(CGRect)circleRect onMapImage:(UIImage *)image;

@end
