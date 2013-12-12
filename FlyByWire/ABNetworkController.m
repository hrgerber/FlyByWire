//
//  ABNetworkController.m
//  FlyByWire
//
//  Created by Retief Gerber on 2013/11/19.
//  Copyright (c) 2013 abductive. All rights reserved.
//

#import "ABNetworkController.h"

#import <netinet/tcp.h>
#import <netinet/in.h>

@interface ABNetworkController ()

@property (strong, nonatomic) NSNetService *service;

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@property (strong, nonatomic) NSOperationQueue *transmitQueue;

@end

@implementation ABNetworkController

@synthesize service = _service;

@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;

@synthesize delegate = _delegate;

@synthesize transmitQueue = _transmitQueue;

- (void)initNetworkCommunicationWithService:(NSNetService *)service
{
    self.transmitQueue = [[NSOperationQueue alloc] init];
    [self.transmitQueue setMaxConcurrentOperationCount:10];
    
    [service getInputStream:&(_inputStream) outputStream:&(_outputStream)];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    self.outputStream.delegate = self;
    self.inputStream.delegate = self;
    
    [self.inputStream open];
    [self.outputStream open];
    

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
                // Disable Nagle's algorithm to improve network responsiveness
                CFDataRef nativeSocket = CFWriteStreamCopyProperty((CFWriteStreamRef)self.outputStream, kCFStreamPropertySocketNativeHandle);
                CFSocketNativeHandle *sock = (CFSocketNativeHandle *)CFDataGetBytePtr(nativeSocket);
                setsockopt(*sock, IPPROTO_TCP, TCP_NODELAY, &(int){ 1 }, sizeof(int));

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

- (void)_sendMessageOperation:(NSString *)msg
{
    NSData *data = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:[data bytes]  maxLength:[data length]];

}
- (void)sendMessage:(NSString *)msg
{
    // This will ensure the send messages while handling a received message does not block
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(_sendMessageOperation:)
                                                                              object:msg];
    [operation setThreadPriority:1.0];
    [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    
    [self.transmitQueue addOperation:operation];
}


@end
