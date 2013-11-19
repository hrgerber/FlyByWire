//
//  ABConnectViewController.m
//  FlyByWire
//
//  Created by abductive on 2013/11/19.
//  Copyright (c) 2013 Retief Gerber. All rights reserved.
//

#import "ABConnectViewController.h"

#import "ABViewController.h"

@implementation ABConnectViewController


@synthesize networkController = _networkController;


- (void)viewDidAppear:(BOOL)animated
{
    // Make sure you are the delegate
    self.networkController.delegate = self;
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
    [self.view endEditing:YES];
    self.connectBtn.enabled = false;
    [self.connectingActivity startAnimating];
    [self.networkController initNetworkCommunication:self.serverIPAddress.text];
}

- (IBAction)diconnectAction:(id)sender
{
    [self.view endEditing:YES];
    [self.networkController terminateNetworkCommunication];
    self.connectBtn.enabled = true;
    self.disconnectBtn.enabled = false;
}

- (void)connectedToServer
{
    [self.connectingActivity stopAnimating];
    self.disconnectBtn.enabled = true;
    // push new view
    [self performSegueWithIdentifier:@"ShowTouch" sender:self];
}

- (void)unableToConnect
{
    [self.connectingActivity stopAnimating];
    self.connectBtn.enabled = true;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowTouch"])
    {
        ABViewController *controller = [segue destinationViewController];
        self.networkController.delegate = controller;
        controller.networkController = self.networkController;
    }
}

@end
