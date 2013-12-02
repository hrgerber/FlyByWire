//
//  ABNetworkServiceBrowser.m
//  FlyByWireServer
//
//  Created by Retief Gerber on 2013/11/27.
//  Copyright (c) 2013 abductive. All rights reserved.
//

#import "ABNetworkServiceBrowser.h"

@interface ABNetworkServiceBrowser()

@property (strong, nonatomic) NSNetServiceBrowser *browser;
@property (strong, nonatomic) NSTimer *searchTimer;

@end

@implementation ABNetworkServiceBrowser

@synthesize browser = _browser;
@synthesize services = _services;
@synthesize delegate = _delegate;
@synthesize searchTimer = _searchTimer;

- (NSNetServiceBrowser *)browser
{
    if (!_browser) {
        _browser = [[NSNetServiceBrowser alloc] init];
        [_browser setDelegate:self];
    }
    return _browser;
}

- (void)startSearch
{
    self.services = [[NSMutableArray alloc] init];
    [self.browser searchForServicesOfType:@"_flybywire._tcp" inDomain:@""];
}

- (void)stopSearch
{
    [self.browser stop];
    
    [self.searchTimer invalidate];
    self.searchTimer = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchFinished)])
    {
        [self.delegate searchFinished];
    }
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"netServiceBrowserWillSearch:");
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"netServiceBrowserDidStopSearch:");

    [self stopSearch];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"netServiceBrowser:didNotSearch:");
    [self stopSearch];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"netServiceBrowser:didFindService:moreComing:");
    
    // Only add new services, but this test might not be the correct way
    NSInteger index = [self _indexOfService:aNetService];
    if (index == -1)
    {
        [self.services addObject:aNetService];
        if (self.delegate && [self.delegate respondsToSelector:@selector(foundService:moreComing:)])
        {
            [self.delegate foundService:aNetService moreComing:moreComing];
        }
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"netServiceBrowser:didRemoveService:moreComing:");
    // Only remove services thats already in the list, but this test might not be the correct way
    NSInteger index = [self _indexOfService:aNetService];
    if (index != -1)
    {
        [self.services removeObjectAtIndex:index];
        if (self.delegate && [self.delegate respondsToSelector:@selector(removedService:moreComing:)])
        {
            [self.delegate removedService:aNetService moreComing:moreComing];
        }
    }
}

- (NSInteger)_indexOfService:(NSNetService *)service
{
    long len = [self.services count];
    for (long x=0; x<len; x++)
    {
        NSNetService *temp = [self.services objectAtIndex:x];
        if ([temp.name isEqualToString:service.name])
            return x;
    }
    return -1;
}

@end
