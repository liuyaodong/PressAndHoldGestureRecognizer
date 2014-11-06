//
//  PressAndHoldGestureRecognizer.m
//  SogouInput
//
//  Created by Yaodong Liu on 14-7-1.
//

#import "PressAndHoldGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface TargetAndActionPair : NSObject
@property (nonatomic, readonly) id target;
@property (nonatomic, readonly) SEL action;
+ (TargetAndActionPair *)pairWithTargte:(id)target action:(SEL)action;
@end

@implementation TargetAndActionPair
{
    __weak id  _target;
    SEL _action;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TargetAndActionPair class]] && [((TargetAndActionPair *)object).target isEqual:self.target] && ((TargetAndActionPair *)object).action == self.action) {
        return YES;
    }
    return [super isEqual:object];
}

- (id)target
{
    return _target;
}

- (SEL)action
{
    return _action;
}

- (NSUInteger)hash
{
    return [[NSString stringWithFormat:@"%@%@", self.target, NSStringFromSelector(self.action)] hash];
}

+ (TargetAndActionPair *)pairWithTargte:(id)target action:(SEL)action
{
    TargetAndActionPair *pair = [[TargetAndActionPair alloc] init];
    pair->_action = action;
    pair->_target = target;
    return pair;
}

@end

@interface PressAndHoldGestureRecognizer ()
@end

@implementation PressAndHoldGestureRecognizer
{
    NSTimer                     *_repeatedlyReportTimer;
    NSMutableSet                *_targetsAndActions;
    CGPoint                     _beginLocation;
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:nil action:NULL];
    if (self) {
        _targetsAndActions = [NSMutableSet set];
        if (target && action) {
            [_targetsAndActions addObject:[TargetAndActionPair pairWithTargte:target action:action]];
        }
        _reportInterval = 0.5f;
        _allowableMovementWhenRecognized = 3.0f;
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action
{
    if (target && action) {
        [_targetsAndActions addObject:[TargetAndActionPair pairWithTargte:target action:action]];
    }
}

- (void)removeTarget:(id)target action:(SEL)action
{
    NSMutableSet *pairsToRemove = [_targetsAndActions mutableCopy];
    
    for (TargetAndActionPair *pair in _targetsAndActions) {
        if (target && pair.target != target) {
            [pairsToRemove removeObject:pair];
        }
        if (action && pair.action != action) {
            [pairsToRemove removeObject:pair];
        }
    }

    [_targetsAndActions minusSet:pairsToRemove];
    [super removeTarget:target action:action];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _beginLocation = [[touches anyObject] locationInView:self.view];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        CGPoint newLocation = [[touches anyObject] locationInView:self.view];
        CGFloat dx = newLocation.x - _beginLocation.x;
        CGFloat dy = newLocation.y - _beginLocation.y;
        if (sqrt(dx * dx + dy * dy) > self.allowableMovementWhenRecognized ) {
            self.state = UIGestureRecognizerStateEnded;
        }
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)setState:(UIGestureRecognizerState)state
{
    if (state == UIGestureRecognizerStateBegan) {
        _repeatedlyReportTimer = [NSTimer scheduledTimerWithTimeInterval:self.reportInterval target:self selector:@selector(invokeMethods) userInfo:nil repeats:YES];
    }
    [super setState:state];
}

- (void)reset
{
    [_repeatedlyReportTimer invalidate];
    _repeatedlyReportTimer = nil;
    [super reset];
    
    // Notify the ended or cancelled state
    if (self.state == UIGestureRecognizerStateCancelled || self.state == UIGestureRecognizerStateEnded) {
        [self invokeMethods];
    }
}

- (void)invokeMethods
{
    NSSet *targetsAndActions = [_targetsAndActions copy];
    for (TargetAndActionPair *pair in targetsAndActions) {
        
        if (!pair.target) {
            [_targetsAndActions removeObject:pair];
            return;
        }
        
        NSMethodSignature *methodSignature = [pair.target methodSignatureForSelector:pair.action];
        IMP imp = [pair.target methodForSelector:pair.action];
        if (methodSignature.numberOfArguments == 0) {
            void (*func)(id, SEL) = (void *)imp;
            func(pair.target, pair.action);
        } else {
            void (*func)(id, SEL, PressAndHoldGestureRecognizer *) = (void *)imp;
            func(pair.target, pair.action, self);
        }
    }
}

@end
