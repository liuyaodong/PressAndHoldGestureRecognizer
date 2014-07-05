//
//  ViewController.m
//  PressAndHoldGestureRecognizerDemo
//
//  Created by Yaodong Liu on 14-7-5.
//

#import "ViewController.h"
#import "PressAndHoldGestureRecognizer.h"


@interface ViewController ()
@end

@implementation ViewController
{
    NSInteger                   _count;
    UILabel                     *_label;
}

- (void)viewDidLoad
{
    PressAndHoldGestureRecognizer *gestureRecognizer = [[PressAndHoldGestureRecognizer alloc] initWithTarget:self action:@selector(repeatedAction:)];
    gestureRecognizer.minimumPressDuration = 0.3f;
    gestureRecognizer.reportInterval = 1.0f;
    gestureRecognizer.allowableMovementWhenRecognized = 10.0f;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    _count = 0;
    _label = [[UILabel alloc] init];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.text = @"Press and hold";
    _label.font = [UIFont systemFontOfSize:30.0f];
    _label.textColor = [UIColor orangeColor];
    [self.view addSubview:_label];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
}

- (void)repeatedAction:(PressAndHoldGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        _count++;
        _label.text = [NSString stringWithFormat:@"%d", _count];
        [UIView animateWithDuration:gestureRecognizer.reportInterval / 2.0f animations:^{
            _label.transform = CGAffineTransformMakeScale(3.0f, 3.0f);
            _label.alpha = 0.0f;
        }completion:^(BOOL finished){
            _label.alpha = 1.0f;
            _label.transform = CGAffineTransformIdentity;
        }];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        _count = 0;
    }
}


@end
