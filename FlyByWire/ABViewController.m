//
//  ABViewController.m
//  FlyByWire
//
//  Created by abductive on 2013/11/19.
//  Copyright (c) 2013 Retief Gerber. All rights reserved.
//

#import "ABViewController.h"
#import "ABTouchEvent.h"

@interface ABViewController ()

@end

@implementation ABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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

-(void)_displayTouchEvent:(ABTouchEvent *)touchEvent
{
    self.mainView.touch = touchEvent;
    [self.mainView setNeedsDisplay];
}

-(void)_transmitTouchEvent:(ABTouchEvent *)touchEvent
{
    
}

-(void)_handleTouchEvent:(UITouch *)touch type:(ABTouchEventType)type
{
    ABTouchEvent *touchEvent = [self _createTouchEvent:touch type:type];
    
    [self _displayTouchEvent:touchEvent];
    [self _transmitTouchEvent:touchEvent];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _handleTouchEvent:[touches anyObject] type:ABTouchEventTypeMoved];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _handleTouchEvent:[touches anyObject] type:ABTouchEventTypeBegan];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _handleTouchEvent:[touches anyObject] type:ABTouchEventTypeEnded];
}

@end
