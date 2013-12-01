//
//  ABTouchView.m
//  FlyByWire
//
//  Created by Retief Gerber on 2013/11/19.
//  Copyright (c) 2013 abductive. All rights reserved.
//

#import "ABTouchView.h"

@implementation ABTouchView

@synthesize touch = _touch;

static CGFloat red[] = {1.0,0.0,0.0,1.0};
static CGFloat blue[] = {0.0,0.0,1.0,1.0};
static CGFloat green[] = {0.0,1.0,0.0,1.0};
static CGFloat black[] = {0.0,0.0,0.0,1.0};

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(ABTouchEvent*)touch {
    if (!_touch) {
        _touch = [[ABTouchEvent alloc] init];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        _touch.point = CGPointMake(screenRect.size.width/2, screenRect.size.height/2);
    }
    return _touch;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 3);

    switch (self.touch.type) {
        case ABTouchEventTypeNone:
            CGContextSetFillColor(context, black);
            break;
        case ABTouchEventTypeBegan:
            CGContextSetFillColor(context, blue);
            break;
        case ABTouchEventTypeMoved:
            CGContextSetFillColor(context, green);
            break;
        case ABTouchEventTypeEnded:
            CGContextSetFillColor(context, red);
            break;
        default:
            break;
    }
    
    CGContextBeginPath(context);
    CGContextAddEllipseInRect(context, CGRectMake(self.touch.point.x-25, self.touch.point.y-25, 50, 50));
    CGContextDrawPath(context, kCGPathFill);
    
}

@end
