//
//  ABNetworkBrowserViewController.h
//  FlyByWire
//
//  Created by Retief Gerber on 2013/11/28.
//  Copyright (c) 2013 abductive. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABNetworkServiceBrowser.h"
#import "ABNetworkController.h"
#import "ABTouchViewController.h"

typedef NS_ENUM(NSInteger, ABNetworkBrowserViewControllerState) {
    ABNetworkBrowserViewControllerStateSearching,
    ABNetworkBrowserViewControllerStateReady,
    ABNetworkBrowserViewControllerStateConnecting,
    ABNetworkBrowserViewControllerStateConfiguring,
    ABNetworkBrowserViewControllerStateConnected,
    ABNetworkBrowserViewControllerStateError
};

typedef NS_ENUM(NSInteger, ABNetworkBrowserViewControllerEvent) {
    ABNetworkBrowserViewControllerEventSearchAction,
    ABNetworkBrowserViewControllerEventConnectAction,
    ABNetworkBrowserViewControllerEventDisconnectAction,
    ABNetworkBrowserViewControllerEventCancelAction,
    ABNetworkBrowserViewControllerEventSearchResult,
    ABNetworkBrowserViewControllerEventSearchDone,
    ABNetworkBrowserViewControllerEventSearchError,
    ABNetworkBrowserViewControllerEventConnectDone,
    ABNetworkBrowserViewControllerEventConnectError,
    ABNetworkBrowserViewControllerEventConnectEstablished,
    ABNetworkBrowserViewControllerEventConfigure,
    ABNetworkBrowserViewControllerEventConfigureFailed,
};

@interface ABNetworkBrowserViewController : UIViewController <ABNetworkControllerDelegate, ABNetworkServiceBrowserDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) ABNetworkServiceBrowser *serviceBrowser;

@property (strong, nonatomic) ABNetworkController *networkController;

@property (weak, nonatomic) IBOutlet UIPickerView *servicePicker;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectingActivity;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) ABTouchViewController *touchViewController;

@end
