//
//  ABNetworkController.h
//  FlyByWire
//
//  Created by Retief Gerber on 2013/11/19.
//  Copyright (c) 2013 abductive. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ABNetworkControllerDelegate <NSObject>

@optional
- (void)connectedToServer;
- (void)unableToConnect;
- (void)connectionClosed;
- (void)receivedMessage:(NSString *)msg;

@end

@interface ABNetworkController : NSObject <NSStreamDelegate>

@property (assign, nonatomic) id<ABNetworkControllerDelegate> delegate;

- (void)initNetworkCommunicationWithService:(NSNetService *)service;
- (void)terminateNetworkCommunication;

- (void)sendMessage:(NSString *)msg;

@end
