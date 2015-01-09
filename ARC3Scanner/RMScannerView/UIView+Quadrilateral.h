
#import <UIKit/UIKit.h>

@interface UIView (Quadrilateral)

//Set's frame to bounding box of quad and applies transform
- (void)transformToFitQuadTopLeft:(CGPoint)tl bottomLeft:(CGPoint)bl bottomRight:(CGPoint)br topRight:(CGPoint)tr rotation:(CGFloat)rotation;

@end
