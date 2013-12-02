//
//  ABNetworkController.m
//  FlyByWire
//
//  Created by Retief Gerber on 2013/11/19.
//  Copyright (c) 2013 abductive. All rights reserved.
//

#import "ABNetworkController.h"

@interface ABNetworkController ()

@property (strong, nonatomic) NSNetService *service;

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@end

@implementation ABNetworkController

@synthesize service = _service;

@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;

@synthesize delegate = _delegate;

- (void)initNetworkCommunicationWithService:(NSNetService *)service
{
    [service getInputStream:&(_inputStream) outputStream:&(_outputStream)];
    
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
    NSInteger len;
	
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
