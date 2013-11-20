//
//  ABNetworkController.m
//  FlyByWire
//
//  Created by abductive on 2013/11/19.
//  Copyright (c) 2013 Retief Gerber. All rights reserved.
//

#import "ABNetworkController.h"

@implementation ABNetworkController

@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize delegate = _delegate;

- (void)initNetworkCommunication:(NSString *)host
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, 8000, &readStream, &writeStream);
    
    self.inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    self.outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
    
    self.outputStream.delegate = self;
    self.inputStream.delegate = self;
}

- (void)terminateNetworkCommunication
{
    [self.inputStream close];
    [self.outputStream close];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    uint8_t buffer[1024];
    int len;
	
    switch (eventCode) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
            if (aStream == self.outputStream)
            {
                if ([self.delegate respondsToSelector:@selector(connectedToServer)])
                    [self.delegate connectedToServer];
            }
			break;
            
		case NSStreamEventHasBytesAvailable:
            len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
            if (len > 0) {
                NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                if ([self.delegate respondsToSelector:@selector(receivedMessage:)])
                    [self.delegate receivedMessage:output];
            }
			break;
            
		case NSStreamEventErrorOccurred:
            if (aStream == self.outputStream)
            {
                if ([self.delegate respondsToSelector:@selector(unableToConnect)])
                    [self.delegate unableToConnect];
            }
			break;
            
		case NSStreamEventEndEncountered:
            if ([self.delegate respondsToSelector:@selector(connectionClosed)])
                [self.delegate connectionClosed];
            break;
            
            
        case NSStreamEventNone:
            NSLog(@"None event");
            break;
            
        
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Space available");
            break;
            
		default:
			NSLog(@"Unknown event");
	}
}

- (void)threadedSendMessage:(NSString *)msg
{
    NSData *data = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:[data bytes]  maxLength:[data length]];

}
- (void)sendMessage:(NSString *)msg
{
    // This will ensure the send messages while handling a received message does not block
    // TODO: Figure out if there is a better way to do this
    [self performSelectorInBackground:@selector(threadedSendMessage:) withObject:msg];
}


@end
