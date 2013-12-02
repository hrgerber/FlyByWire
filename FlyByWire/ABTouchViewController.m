//
//  ABViewController.m
//  FlyByWire
//
//  Created by Retief Gerber on 2013/11/19.
//  Copyright (c) 2013 abductive. All rights reserved.
//

#import "ABTouchViewController.h"
#import "ABTouchEvent.h"

@interface ABTouchViewController ()

@end

@implementation ABTouchViewController

@synthesize networkController = _networkController;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(ABTouchEvent *)_createTouchEvent:(UITouch *)touch type:(ABTouchEventType)type
{
    ABTouchEvent *touchEvent = [[ABTouchEvent alloc] init];
    
    touchEvent.point = [touch locationInView:self.mainView];
    touchEvent.type = type;
    
    return touchEvent;
}

- (void)_displayTouchEvent:(ABTouchEvent *)touchEvent
{
    self.mainView.touch = touchEvent;
    [self.mainView setNeedsDisplay];
}

- (void)_transmitTouchEvent:(ABTouchEvent *)touchEvent
{
    NSString *msg = [NSString stringWithFormat:@"T%02lu:B%02d:X%04d:Y%04d.", touchEvent.type, 0, (int)touchEvent.point.x, (int)touchEvent.point.y];
    [self.networkController sendMessage:msg];
}

- (void)_handleTouchEvent:(UITouch *)touch type:(ABTouchEventType)type
{
    ABTouchEvent *touchEvent = [self _createTouchEvent:touch type:type];
    
    [self _displayTouchEvent:touchEvent];
    [self _transmitTouchEvent:touchEvent];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _handleTouchEvent:[touches anyObject] type:ABTouchEventTypeMoved];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _handleTouchEvent:[touches anyObject] type:ABTouchEventTypeBegan];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _handleTouchEvent:[touches anyObject] type:ABTouchEventTypeEnded];
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];

    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        // Put in code here to handle shake
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

 - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // TODO: This code is repeated in ABNetworkBrowserViewController, need a utility lib for this
    CGFloat width;
    CGFloat height;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        width = screenRect.size.height;
        height = screenRect.size.width;
    } else {
        width = screenRect.size.width;
        height = screenRect.size.height;
    }
    NSString *msg = [NSString stringWithFormat:@"B%02d:D%02d:W%04d:H%04d.", 0, 1, (int)width, (int)height];

    [self.networkController sendMessage:msg];
}

@end
