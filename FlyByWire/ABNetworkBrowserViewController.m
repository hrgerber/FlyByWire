//
//  ABNetworkBrowserViewController.m
//  FlyByWire
//
//  Created by Retief Gerber on 2013/11/28.
//  Copyright (c) 2013 abductive. All rights reserved.
//

#import "ABNetworkBrowserViewController.h"

@interface ABNetworkBrowserViewController ()

@property (assign, nonatomic) ABNetworkBrowserViewControllerState controllerState;

@end


@implementation ABNetworkBrowserViewController

@synthesize networkController = _networkController;
@synthesize serviceBrowser = _serviceBrowser;
@synthesize controllerState = _controllerState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (ABNetworkController*)networkController
{
    if (!_networkController) {
        _networkController = [[ABNetworkController alloc] init];
        _networkController.delegate = self;
    }
    return _networkController;
}

- (ABNetworkServiceBrowser *)serviceBrowser
{
    if (!_serviceBrowser) {
        _serviceBrowser = [[ABNetworkServiceBrowser alloc] init];
        _serviceBrowser.delegate = self;
    }
    return _serviceBrowser;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.serviceBrowser startSearch];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.serviceBrowser stopSearch];
}

- (void)foundService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    [self.servicePicker reloadAllComponents];
    
    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventSearchResult];
}

- (void)removedService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    [self.servicePicker reloadAllComponents];
    
    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventSearchResult];    
}

- (void)foundNothing
{
    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventSearchError];
}

- (void)searchFinished
{
    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventSearchDone];
}

- (IBAction)searchAction:(id)sender {

    [self.serviceBrowser stopSearch];
    [self.serviceBrowser startSearch];

    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventSearchAction];
}

- (IBAction)connectAction:(id)sender
{
    NSNetService *service = [self.serviceBrowser.services objectAtIndex:[self.servicePicker selectedRowInComponent:0]];
    
    // Start connection
    [self.networkController initNetworkCommunicationWithService:service];

    // Update UI
    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventConnectAction];

}

- (IBAction)disconnectAction:(id)sender
{
    // Stop connection
    [self.networkController terminateNetworkCommunication];
    
    // Update UI
    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventDisconnectAction];
}

- (IBAction)cancelAction:(id)sender
{
    // Stop connection
    [self.networkController terminateNetworkCommunication];

    // Update UI
    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventCancelAction];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.serviceBrowser.services count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSNetService *service = [self.serviceBrowser.services objectAtIndex:row];
    return service.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.controllerState == ABNetworkBrowserViewControllerStateConnected)
    {
        [self disconnectAction:nil];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowNetTouch"])
    {
        self.touchViewController = [segue destinationViewController];
        self.touchViewController.networkController = self.networkController;
    }
}

- (void)_updateUIOnMainThreadForEvent:(ABNetworkBrowserViewControllerEvent)event
{
    // NOTE: The next line is for easier debugging, when needed
    //[self _updateUIForEventNumber:[NSNumber numberWithInt:event]];
    [self performSelectorOnMainThread:@selector(_updateUIForEventNumber:) withObject:[NSNumber numberWithInt:event] waitUntilDone:NO];
}

- (void)_updateUIForEventNumber:(NSNumber *)number
{
    ABNetworkBrowserViewControllerEvent event = [number intValue];
    switch (self.controllerState)
    {
        case ABNetworkBrowserViewControllerStateSearching:
            if (event == ABNetworkBrowserViewControllerEventSearchResult)
            {
                self.connectBtn.enabled = true;
            }
            else if (event == ABNetworkBrowserViewControllerEventSearchDone)
            {
                self.controllerState = ABNetworkBrowserViewControllerStateReady;
            }
        // NOTE: Do not change the order of these two cases they rely on one another
        case ABNetworkBrowserViewControllerStateReady:
            if (event == ABNetworkBrowserViewControllerEventConnectAction)
            {
                [self.view endEditing:YES];
                
                self.connectBtn.enabled = false;
                self.cancelBtn.hidden = false;
                [self.connectingActivity startAnimating];
                self.statusLabel.text = @"connecting...";
                self.statusLabel.hidden = NO;
                
                self.controllerState = ABNetworkBrowserViewControllerStateConnecting;
            }
            else if (event == ABNetworkBrowserViewControllerEventSearchResult)
            {
                // Handled in ABNetworkBrowserViewControllerStateSearching
            }
            else if (event == ABNetworkBrowserViewControllerEventSearchAction)
            {
                self.controllerState = ABNetworkBrowserViewControllerStateSearching;
            }
            else if (event == ABNetworkBrowserViewControllerEventSearchDone)
            {
                // Nothing to do
            }
            else {
                NSLog(@"Invalid event %lu in controller state ABNetworkBrowserViewControllerStateReady", event);
            }
            break;
            
        case ABNetworkBrowserViewControllerStateConnecting:
            if (event == ABNetworkBrowserViewControllerEventConnectDone)
            {
                self.connectBtn.hidden = true;
                self.disconnectBtn.hidden = false;
                self.statusLabel.hidden = false;
                self.statusLabel.text = @"configuring...";
                
                self.controllerState = ABNetworkBrowserViewControllerStateConfiguring;
            }
            else if ((event == ABNetworkBrowserViewControllerEventConnectError) ||
                     (event == ABNetworkBrowserViewControllerEventCancelAction))
            {
                [self.view endEditing:YES];
                
                self.connectBtn.enabled = true;
                self.cancelBtn.hidden = true;
                [self.connectingActivity stopAnimating];
                
                self.controllerState = ABNetworkBrowserViewControllerStateReady;
            }
            else if (event == ABNetworkBrowserViewControllerEventSearchDone)
            {
                // Nothing to do
            }
            else {
                NSLog(@"Invalid event %lu in controller state ABNetworkBrowserViewControllerStateConnecting", event);
            }
            break;
        case ABNetworkBrowserViewControllerStateConfiguring:
            if ((event == ABNetworkBrowserViewControllerEventConnectError) ||
                (event == ABNetworkBrowserViewControllerEventCancelAction))
            {
                self.connectBtn.hidden = false;
                self.connectBtn.enabled = true;
                self.disconnectBtn.hidden = true;
                self.statusLabel.hidden = true;
                self.cancelBtn.hidden = true;
                [self.connectingActivity stopAnimating];
                
                self.controllerState = ABNetworkBrowserViewControllerStateReady;
            }
            else if (event == ABNetworkBrowserViewControllerEventConnectEstablished)
            {
                self.statusLabel.hidden = true;
                [self.connectingActivity stopAnimating];
                self.cancelBtn.hidden = true;
                
                self.controllerState = ABNetworkBrowserViewControllerStateConnected;
            }
            else if (event == ABNetworkBrowserViewControllerEventSearchDone)
            {
                // Nothing to do
            }
            else {
                NSLog(@"Invalid event %lu in controller state ABNetworkBrowserViewControllerStateConfiguring", event);
            }
            break;
        case ABNetworkBrowserViewControllerStateConnected:
            if ((event == ABNetworkBrowserViewControllerEventDisconnectAction) ||
                (event == ABNetworkBrowserViewControllerEventConnectError) ||
                (event == ABNetworkBrowserViewControllerEventCancelAction))
            {
                self.connectBtn.hidden = false;
                self.connectBtn.enabled = true;
                self.disconnectBtn.hidden = true;
                
                self.controllerState = ABNetworkBrowserViewControllerStateReady;
            }
            else if (event == ABNetworkBrowserViewControllerEventConnectEstablished)
            {
                // Nothing to do
            }
            else if ((event == ABNetworkBrowserViewControllerEventSearchResult) ||
                     (event == ABNetworkBrowserViewControllerEventSearchDone))
            {
                // Nothing to do
            }
            else {
                NSLog(@"Invalid event %lu in controller state ABNetworkBrowserViewControllerStateConnected", event);
            }
            break;
        case ABNetworkBrowserViewControllerStateError:
            
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
        if (self.controllerState == ABNetworkBrowserViewControllerStateConnected)
        {
            // Segue to the touch view controller
            [self performSegueWithIdentifier:@"ShowNetTouch" sender:self];
        }
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
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
    NSString *msg = [NSString stringWithFormat:@"B%02d:D%02d:W%04d:H%04d.", 0, 1, (int)width, (int)height];
    
    [self.networkController sendMessage:msg];

    // Update UI
    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventConnectDone];
}

- (void)unableToConnect
{
    // Update UI
    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventConnectError];
}

- (void)connectionClosed
{
    
    // Dismiss touch controller as connectivity has been lost
    [self.touchViewController dismissViewControllerAnimated:YES completion:nil];
    self.touchViewController = nil;

    // Update UI
    [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventConnectError];
}

- (void)receivedMessage:(NSString *)msg
{
    if (self.controllerState == ABNetworkBrowserViewControllerStateConnected)
    {
        return;
    }
    
    if ([msg isEqualToString:@"ACK"])
    {
        sleep(1);
        // Update UI
        [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventConnectEstablished];
        
        // Segue to the touch view controller
        [self performSegueWithIdentifier:@"ShowNetTouch" sender:self];
    }
    else if ([msg isEqualToString:@"ERR"])
    {
        [self _updateUIOnMainThreadForEvent:ABNetworkBrowserViewControllerEventConnectError];
    }
}

@end
