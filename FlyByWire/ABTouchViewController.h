//
//  ABViewController.h
//  FlyByWire
//
//  Created by Retief Gerber on 2013/11/19.
//  Copyright (c) 2013 abductive. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABTouchEvent.h"
#import "ABTouchView.h"

#import "ABNetworkController.h"

@interface ABTouchViewController : UIViewController <ABNetworkControllerDelegate>

@property (strong, nonatomic) IBOutlet ABTouchView *mainView;
@property (strong, nonatomic) ABNetworkController *networkController;

@end
