//
//  ABTouchEvent.h
//  FlyByWire
//
//  Created by abductive on 2013/11/19.
//  Copyright (c) 2013 Retief Gerber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, ABTouchEventType) {
    ABTouchEventTypeNone,
    ABTouchEventTypeBegan,
    ABTouchEventTypeMoved,
    ABTouchEventTypeEnded
};

@interface ABTouchEvent : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) ABTouchEventType type;

@end
