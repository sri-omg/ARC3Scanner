//
//  ARC3Helper.m
//  ARC3Scanner
//
//  Created by Adam Overholtzer on 1/9/15.
//  Copyright (c) 2015 SRI. All rights reserved.
//

#import "ARC3Helper.h"

@implementation ARC3Helper

+ (NSString *)customPhotoFilePath {
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir  = [documentPaths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:kPhotoFileName];
}

+ (BOOL)customPhotoExists {
    NSString  *pngfile = [ARC3Helper customPhotoFilePath];
    NSLog(@"%@", pngfile);
    return [[NSFileManager defaultManager] fileExistsAtPath:pngfile];
}

+ (UIImage *)customPhotoImage {
    if ([ARC3Helper customPhotoExists]) {
        NSString  *pngfile = [ARC3Helper customPhotoFilePath];
        NSData *imageData = [NSData dataWithContentsOfFile:pngfile];
        return [UIImage imageWithData:imageData];
    } else {
        return nil;
    }
}

+ (UIImage *)imageByDrawingBoundingCirlceOnImage:(UIImage *)image {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kScannedImageSize, kScannedImageSize), NO, image.scale);
    
    // get the context for CoreGraphics and clip it
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *boundingCircle = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, kScannedImageSize, kScannedImageSize)
                                                              cornerRadius:MAX(kScannedImageSize, kScannedImageSize)];
    CGContextAddPath(ctx, boundingCircle.CGPath);
    CGContextClip(ctx);
    
    // draw original image into the context
    [image drawInRect:CGRectMake(0, 0, kScannedImageSize, kScannedImageSize)];
    
    // draw border
    CGFloat borderWidth = [[NSUserDefaults standardUserDefaults] floatForKey:kBorderWidthKey];
    if (borderWidth > 0) {
        CGFloat borderWhiteness = [[NSUserDefaults standardUserDefaults] floatForKey:kBorderWhitenessKey];
        CGContextSetLineWidth(ctx, borderWidth);
        [[UIColor colorWithWhite:borderWhiteness alpha:1] setStroke];
        CGContextStrokeEllipseInRect(ctx, boundingCircle.bounds);
        CGContextSetLineWidth(ctx, 1);
    }
    
    // draw overlay text
    NSString *text = [[NSUserDefaults standardUserDefaults] stringForKey:kPhotoTextOverlayKey];
    if (text.length) {
        // draw N for north
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        CGRect rect = CGRectMake(0, 3*kScannedImageSize/4, kScannedImageSize, kScannedImageSize/2);
        [text drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15],
                                               NSParagraphStyleAttributeName:paragraphStyle,
                                               NSForegroundColorAttributeName:[UIColor whiteColor],
                                               NSBackgroundColorAttributeName:[UIColor colorWithWhite:0 alpha:0.5]}];
    }
    
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    
    return retImage;
}

+ (UIImage *)imageByDrawingCircle:(CGRect)circleRect onMapImage:(UIImage *)image {
    
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
    CGFloat borderWidth = [[NSUserDefaults standardUserDefaults] floatForKey:kBorderWidthKey];
    if (borderWidth > 0) {
        CGFloat borderWhiteness = [[NSUserDefaults standardUserDefaults] floatForKey:kBorderWhitenessKey];
        CGContextSetLineWidth(ctx, borderWidth);
        [[UIColor colorWithWhite:borderWhiteness alpha:1] setStroke];
        CGContextStrokeEllipseInRect(ctx, boundingCircle.bounds);
        CGContextSetLineWidth(ctx, 1);
    }
    
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
    [@"N" drawAtPoint:CGPointMake(image.size.width/2, 0) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
    
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    
    return retImage;
}


@end
