//
//  ABConnectViewController.m
//  FlyByWire
//
//  Created by abductive on 2013/11/19.
//  Copyright (c) 2013 Retief Gerber. All rights reserved.
//

#import "ABConnectViewController.h"

#import "ABViewController.h"

typedef NS_ENUM(NSInteger, ABConnectViewControllerState) {
    ABConnectViewControllerStateReady,
    ABConnectViewControllerStateConnecting,
    ABConnectViewControllerStateConfiguring,
    ABConnectViewControllerStateConnected
};

typedef NS_ENUM(NSInteger, ABConnectViewControllerEvent) {
    ABConnectViewControllerEventConnectAction,
    ABConnectViewControllerEventDisconnectAction,
    ABConnectViewControllerEventCancelAction,
    ABConnectViewControllerEventConnected,
    ABConnectViewControllerEventConnectionFailed,
    ABConnectViewControllerEventConfigure,
    ABConnectViewControllerEventConfigureFailed,
    ABConnectViewControllerEventEstablished
};


@interface ABConnectViewController()

@property (assign, nonatomic) ABConnectViewControllerState controllerState;

@end

@implementation ABConnectViewController

@synthesize networkController = _networkController;
@synthesize controllerState = _controllerState;

- (void)viewDidAppear:(BOOL)animated
{
    // Make sure you are the delegate
    self.networkController.delegate = self;
    
    // TODO: It is likely that more stream states needs to be handled here
    if (self.networkController.outputStream.streamStatus == NSStreamStatusClosed)
    {
        [self connectionClosed];
    }
}

- (ABNetworkController *)networkController
{
    if(!_networkController)
    {
        _networkController = [[ABNetworkController alloc] init];
        _networkController.delegate = self;
    }
    return _networkController;
}

- (IBAction)connectAction:(id)sender
{
    // TODO: Server IP address requires validation
    
    // Update UI
    [self _updateUIOnMainThreadForEvent:ABConnectViewControllerEventConnectAction];
    
    // Start connection
    [self.networkController initNetworkCommunication:self.serverIPAddress.text];
}

- (IBAction)disconnectAction:(id)sender
{
    // Update UI
    [self _updateUIOnMainThreadForEvent:ABConnectViewControllerEventDisconnectAction];
    
    // Stop connection
    [self.networkController terminateNetworkCommunication];
}

- (IBAction)cancelAction:(id)sender
{
    // Update UI
    [self _updateUIOnMainThreadForEvent:ABConnectViewControllerEventCancelAction];
    
    // Stop connection
    [self.networkController terminateNetworkCommunication];
    
}

- (void)connectedToServer
{
    sleep(1);

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
    NSString *msg = [NSString stringWithFormat:@"bounds:%.0f:%.0f", width, height];
    
    // Update UI
    [self _updateUIOnMainThreadForEvent:ABConnectViewControllerEventConnected];
    
    [self.networkController sendMessage:msg];
}

- (void)unableToConnect
{
    // Update UI
    [self _updateUIOnMainThreadForEvent:ABConnectViewControllerEventConnectionFailed];
}

- (void)connectionClosed
{
    // Update UI
    [self _updateUIOnMainThreadForEvent:ABConnectViewControllerEventConnectionFailed];
    
    // Dismiss touch controller as connectivity has been lost
    [self.touchViewController dismissViewControllerAnimated:YES completion:nil];
    self.touchViewController = nil;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowTouch"])
    {
        self.touchViewController = [segue destinationViewController];
        self.touchViewController.networkController = self.networkController;
    }
}

- (void)receivedMessage:(NSString *)msg
{
    if ([msg isEqualToString:@"configured"]) {
        // Update UI
        [self _updateUIOnMainThreadForEvent:ABConnectViewControllerEventEstablished];
        
        // Segue to the touch view controller
        [self performSegueWithIdentifier:@"ShowTouch" sender:self];
    }
}

- (void)_updateUIOnMainThreadForEvent:(ABConnectViewControllerEvent)event
{
    [self performSelectorOnMainThread:@selector(_updateUIForEventNumber:) withObject:[NSNumber numberWithInt:event] waitUntilDone:NO];
}

- (void)_updateUIForEventNumber:(NSNumber *)number
{
    ABConnectViewControllerEvent event = [number intValue];
    switch (self.controllerState)
    {
        case ABConnectViewControllerStateReady:
            if (event == ABConnectViewControllerEventConnectAction)
            {
                [self.view endEditing:YES];

                self.connectBtn.enabled = false;
                self.cancelBtn.hidden = false;
                [self.connectingActivity startAnimating];
                
                self.controllerState = ABConnectViewControllerStateConnecting;
            }
            else {
                NSLog(@"Invalid event %d in controller state ABConnectViewControllerStateReady", event);
            }
            break;
            
        case ABConnectViewControllerStateConnecting:
            if (event == ABConnectViewControllerEventConnected)
            {
                self.disconnectBtn.enabled = true;
                self.cancelBtn.hidden = true;
                self.statusLabel.hidden = false;
                
                self.controllerState = ABConnectViewControllerStateConfiguring;
            }
            else if ((event == ABConnectViewControllerEventConnectionFailed) ||
                     (event == ABConnectViewControllerEventCancelAction))
            {
                [self.view endEditing:YES];
                
                self.connectBtn.enabled = true;
                self.cancelBtn.hidden = true;
                [self.connectingActivity stopAnimating];
                
                self.controllerState = ABConnectViewControllerStateReady;
            }
            else {
                NSLog(@"Invalid event %d in controller state ABConnectViewControllerStateConnecting", event);
            }
            break;
        case ABConnectViewControllerStateConfiguring:
            if ((event == ABConnectViewControllerEventConnectionFailed) ||
                (event == ABConnectViewControllerEventCancelAction))
            {
                self.connectBtn.enabled = true;
                self.disconnectBtn.enabled = false;
                self.statusLabel.hidden = true;
                [self.connectingActivity stopAnimating];

                self.controllerState = ABConnectViewControllerStateReady;
            }
            else if (event == ABConnectViewControllerEventEstablished)
            {
                self.statusLabel.hidden = true;
                [self.connectingActivity stopAnimating];
                
                self.controllerState = ABConnectViewControllerStateConnected;
            }
            else {
                NSLog(@"Invalid event %d in controller state ABConnectViewControllerStateConfiguring", event);
            }
            break;
        case ABConnectViewControllerStateConnected:
            if ((event == ABConnectViewControllerEventDisconnectAction) ||
                (event == ABConnectViewControllerEventConnectionFailed) ||
                (event == ABConnectViewControllerEventCancelAction))
            {
                self.connectBtn.enabled = true;
                self.disconnectBtn.enabled = false;
                
                self.controllerState = ABConnectViewControllerStateReady;
            }
            else {
                NSLog(@"Invalid event %d in controller state ABConnectViewControllerStateConnected", event);
            }
            break;

        default:
            break;
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        if (self.controllerState == ABConnectViewControllerStateConnected)
        {
            // Segue to the touch view controller
            [self performSegueWithIdentifier:@"ShowTouch" sender:self];            
        }
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
