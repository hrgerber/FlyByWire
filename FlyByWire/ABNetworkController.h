//
//  ABNetworkController.h
//  FlyByWire
//
//  Created by abductive on 2013/11/19.
//  Copyright (c) 2013 Retief Gerber. All rights reserved.
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

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@property (assign, nonatomic) id<ABNetworkControllerDelegate> delegate;

- (void)initNetworkCommunication:(NSString *)host;
- (void)terminateNetworkCommunication;

- (void)sendMessage:(NSString *)msg;

@end
