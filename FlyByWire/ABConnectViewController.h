//
//  ABConnectViewController.h
//  FlyByWire
//
//  Created by abductive on 2013/11/19.
//  Copyright (c) 2013 Retief Gerber. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABNetworkController.h"

@interface ABConnectViewController : UIViewController <ABNetworkControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *serverIPAddress;
@property (strong, nonatomic) ABNetworkController *networkController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectingActivity;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;


@end
