//
//  RMOutlineBox.h
//  Scanner App
//
//  Created by iRare Media on 1/22/14.
//  Copyright (c) 2014 iRare Media. All rights reserved.
//

#if __has_feature(objc_modules)
    // We recommend enabling Objective-C Modules in your project Build Settings for numerous benefits over regular #imports. Read more from the Modules documentation: http://clang.llvm.org/docs/Modules.html
    @import Foundation;
    @import UIKit;
#else
    #import <Foundation/Foundation.h>
    #import <UIKit/UIKit.h>
#endif

/// Draws the outline of the scanned barcode
@interface RMOutlineBox : UIImageView

/// The corners of the scanned barcode
@property (nonatomic, strong) NSArray *corners;

@property (nonatomic) CGFloat rotation;
@property (nonatomic) BOOL reorderCorners;

@end
