//
//  PressAndHoldGestureRecognizer.h
//  SogouInput
//
//  Created by Yaodong Liu on 14-7-1.
//

#import <UIKit/UIKit.h>

@interface PressAndHoldGestureRecognizer : UILongPressGestureRecognizer
@property (nonatomic, assign) NSTimeInterval reportInterval; // Default 0.5 seconds
@property (nonatomic, assign) CGFloat allowableMovementWhenRecognized; // Default 3 points
@end
