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

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSMutableArray *)services
{
    if (!_services) {
    }
    return _services;
}

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
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                          target:self
                                                        selector:@selector(_searchTimerTriggered)
                                                        userInfo:nil
                                                         repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.searchTimer forMode:NSRunLoopCommonModes];
}

- (void)stopSearch
{
    [self.browser stop];
}


- (void)_searchTimerTriggered
{
    [self stopSearch];
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"netServiceBrowserWillSearch:");
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"netServiceBrowserDidStopSearch:");
    
    [self.searchTimer invalidate];
    self.searchTimer = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchFinished)]) {
        [self.delegate searchFinished];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"netServiceBrowser:didNotSearch:");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    NSLog(@"netServiceBrowser:didFindDomain:moreComing:");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"netServiceBrowser:didFindService:moreComing:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(foundService:moreComing:)]) {
        [self.services addObject:aNetService];
        [self.delegate foundService:aNetService moreComing:moreComing];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    NSLog(@"netServiceBrowser:didRemoveDomain:moreComing:");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"netServiceBrowser:didRemoveService:moreComing:");
}


@end
