//
//  RMOutlineBox.m
//  Scanner App
//
//  Created by iRare Media on 1/22/14.
//  Copyright (c) 2014 iRare Media. All rights reserved.
//

#import "RMOutlineBox.h"
#import "UIView+Quadrilateral.h"

@interface RMOutlineBox ()
@property (nonatomic, strong) CAShapeLayer *outline;
@end

@implementation RMOutlineBox

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        // Initialization code
//        _outline = [CAShapeLayer new];
////        _outline.strokeColor = [[[UIColor redColor] colorWithAlphaComponent:0.8] CGColor];
////        _outline.lineWidth = 2.5;
//        _outline.fillColor = [[UIColor blueColor] CGColor];
//        _outline.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 6, 6) cornerRadius:3].CGPath;
//
////        UIImage* backgroundImage = [UIImage imageNamed:@"campus"];
////        _outline = [CALayer layer];
////        CGFloat nativeWidth = CGImageGetWidth(backgroundImage.CGImage);
////        CGFloat nativeHeight = CGImageGetHeight(backgroundImage.CGImage);
////        CGRect startFrame = CGRectMake(0.0, 0.0, nativeWidth, nativeHeight);
////        _outline.contents = (id)backgroundImage.CGImage;
////        _outline.anchorPoint = CGPointZero;
////        _outline.frame = startFrame;
//////
//        [self.layer addSublayer:_outline];
        
        
        self.autoresizingMask = UIViewAutoresizingNone;
        self.layer.masksToBounds = YES;
        
//        self.layer.shouldRasterize = YES;
//        self.layer.cornerRadius = 1000;
    }
    return self;
}

//- (UIImage *)image {
//    return [UIImage imageNamed:@"campus"];
//}

- (void)setCorners:(NSArray *)corners {
    if (self.reorderCorners) corners = [self reorderCorners:corners];
    
    if (![corners isEqualToArray:_corners]) {
        _corners = corners;
        self.layer.anchorPoint = CGPointZero;
        [self transformToFitQuadTopLeft:[corners[0] CGPointValue]
                             bottomLeft:[corners[1] CGPointValue]
                            bottomRight:[corners[2] CGPointValue]
                               topRight:[corners[3] CGPointValue]
         rotation:self.rotation];
//        self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
        
//        _outline.position = CGPointMake(CGRectGetMidX(self.bounds)-3,
//                                        CGRectGetMidY(self.bounds)-3);
    }
}

- (NSArray *)reorderCorners:(NSArray *)corners {
    NSMutableArray *newCorners = [NSMutableArray arrayWithCapacity:corners.count];
    __block NSUInteger index = 0;
    __block CGFloat smallestCorner = CGFLOAT_MAX;
    
    // find the smallest corner
    [corners enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGPoint point = [obj CGPointValue];
        CGFloat cornerSum = point.x + point.y;
        if (cornerSum < smallestCorner) {
            smallestCorner = cornerSum;
            index = idx;
        }
    }];
    
    // add the corners in order, starting with the smallest
    while (newCorners.count < corners.count) {
        [newCorners addObject:corners[index]];
        index++;
        if (index >= corners.count) {
            index = 0;
        }
    }
    return newCorners;
}



@end
