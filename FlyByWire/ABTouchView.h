//
//  ABTouchView.h
//  FlyByWire
//
//  Created by abductive on 2013/11/19.
//  Copyright (c) 2013 Retief Gerber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTouchEvent.h"

@interface ABTouchView : UIView

@property (strong, nonatomic) ABTouchEvent *touch;

@end
