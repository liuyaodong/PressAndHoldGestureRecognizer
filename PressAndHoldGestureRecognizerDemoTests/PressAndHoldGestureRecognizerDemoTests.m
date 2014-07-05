//
//  PressAndHoldGestureRecognizerDemoTests.m
//  PressAndHoldGestureRecognizerDemoTests
//
//  Created by Yaodong Liu on 14-7-5.
//

#import <XCTest/XCTest.h>
#import "PressAndHoldGestureRecognizer.h"

@interface StubObject : NSObject
@property (nonatomic) BOOL action1Invoked;
@property (nonatomic) BOOL action2Invoked;
@property (nonatomic) id sender;
- (void)someAction1;
- (void)someAction2:(id)sender;
@end

@implementation StubObject

- (void)someAction1
{
    self.action1Invoked = YES;
}

- (void)someAction2:(id)sender
{
    self.action2Invoked = YES;
    self.sender = sender;
}

@end

@interface PressAndHoldGestureRecognizer ()
- (void)invokeMethods;
@end

@interface PressAndHoldGestureRecognizerDemoTests : XCTestCase
@end

@implementation PressAndHoldGestureRecognizerDemoTests
{
    PressAndHoldGestureRecognizer            *_gesture;
    StubObject                               *_stub;
    BOOL                                     _action1Invoked;
    BOOL                                     _action2Invoked;
    id                                       _sender;
}

- (void)setUp
{
    [super setUp];
    _gesture = [[PressAndHoldGestureRecognizer alloc] init];
    _stub = [[StubObject alloc] init];
    _stub.action1Invoked = NO;
    _stub.action2Invoked = NO;
    _stub.sender = nil;
    _action1Invoked = NO;
    _action2Invoked = NO;
    _sender = nil;
}

- (void)tearDown
{
    _gesture = nil;
    _stub = nil;
    [super tearDown];
}

- (void)someAction1
{
    _action1Invoked = YES;
}

- (void)someAction2:(id)sender
{
    _action2Invoked = YES;
    _sender = sender;
}

- (void)testInitWithInvalidParameters
{
    PressAndHoldGestureRecognizer *g = nil;
    XCTAssertNoThrow(g = [[PressAndHoldGestureRecognizer alloc] initWithTarget:self action:NULL], @"");
    XCTAssertNotNil(g, @"");
    NSMutableSet *set = [g valueForKey:@"targetsAndActions"];
    XCTAssertNotNil(set, @"");
    XCTAssertEqual(set.count, (NSUInteger)0, @"");
    
    XCTAssertNoThrow(g = [[PressAndHoldGestureRecognizer alloc] initWithTarget:nil action:@selector(someAction1)], @"");
    XCTAssertNotNil(g, @"");
    set = [g valueForKey:@"targetsAndActions"];
    XCTAssertNotNil(set, @"");
    XCTAssertEqual(set.count, (NSUInteger)0, @"");
}

- (void)testTargetsAndActionsCanBeAddedSuccessfully
{
    NSMutableSet *set = [_gesture valueForKey:@"targetsAndActions"];
    XCTAssertEqual(set.count, (NSUInteger)0, @"");
    [_gesture addTarget:self action:@selector(someAction1)];
    XCTAssertEqual(set.count, (NSUInteger)1, @"");
    [_gesture addTarget:self action:@selector(someAction1)];
    XCTAssertEqual(set.count, (NSUInteger)1, @"Adding repetitive target and action pair should have no effect");
    [_gesture addTarget:self action:@selector(someAction2:)];
    XCTAssertEqual(set.count, (NSUInteger)2, @"");
    [_gesture addTarget:_stub action:@selector(someAction1)];
    XCTAssertEqual(set.count, (NSUInteger)3, @"");
    [_gesture addTarget:_stub action:@selector(someAction2:)];
    XCTAssertEqual(set.count, (NSUInteger)4, @"");
}

- (void)testTargetsAndActionsCanbeRemovedSuccessfully
{
    [self testTargetsAndActionsCanBeAddedSuccessfully];
    NSMutableSet *set = [_gesture valueForKey:@"targetsAndActions"];
    [_gesture removeTarget:_stub action:@selector(someAction1)];
    XCTAssertEqual(set.count, (NSUInteger)3, @"");
    [_gesture removeTarget:self action:@selector(someAction1)];
    XCTAssertEqual(set.count, (NSUInteger)2, @"");
    [_gesture removeTarget:self action:@selector(someAction2:)];
    XCTAssertEqual(set.count, (NSUInteger)1, @"");
}

- (void)testBatchRemoveTargets
{
    [self testTargetsAndActionsCanBeAddedSuccessfully];
    NSMutableSet *set = [_gesture valueForKey:@"targetsAndActions"];
    [_gesture removeTarget:self action:NULL];
    XCTAssertEqual(set.count, (NSUInteger)2, @"Since there are 2 actions of 'self' added");
    [_gesture removeTarget:_stub action:NULL];
    XCTAssertEqual(set.count, (NSUInteger)0, @"");
}

- (void)testBatchRemoveActions
{
    [self testTargetsAndActionsCanBeAddedSuccessfully];
    NSMutableSet *set = [_gesture valueForKey:@"targetsAndActions"];
    [_gesture removeTarget:nil action:@selector(someAction1)];
    XCTAssertEqual(set.count, (NSUInteger)2, @"");
    [_gesture removeTarget:nil action:@selector(someAction2:)];
    XCTAssertEqual(set.count, (NSUInteger)0, @"");
}

- (void)testBatchRemoveAllActionsAndTargets
{
    [self testTargetsAndActionsCanBeAddedSuccessfully];
    NSMutableSet *set = [_gesture valueForKey:@"targetsAndActions"];
    [_gesture removeTarget:nil action:NULL];
    XCTAssertEqual(set.count, (NSUInteger)0, @"");
}

- (void)testAddingInvalidTargetsAndActions
{
    NSMutableSet *set = [_gesture valueForKey:@"targetsAndActions"];
    [_gesture addTarget:nil action:NULL];
    XCTAssertEqual(set.count, (NSUInteger)0, @"");
    [_gesture addTarget:self action:NULL];
    XCTAssertEqual(set.count, (NSUInteger)0, @"adding a target without an action should be treated as an invalid pair");
    [_gesture addTarget:nil action:@selector(someAction1)];
    XCTAssertEqual(set.count, (NSUInteger)0, @"");
}

- (void)testActionsCanBeInvokedCorrectly
{
    [self testTargetsAndActionsCanBeAddedSuccessfully];
    [_gesture invokeMethods];
    XCTAssertTrue(_stub.action1Invoked, @"");
    XCTAssertTrue(_stub.action2Invoked, @"");
    XCTAssertEqualObjects(_stub.sender, _gesture, @"");
    XCTAssertTrue(_action1Invoked, @"");
    XCTAssertTrue(_action2Invoked, @"");
    XCTAssertEqualObjects(_sender, _gesture, @"");
}

@end
