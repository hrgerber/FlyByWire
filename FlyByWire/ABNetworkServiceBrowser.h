//
//  ABFlyByWireNetworkServiceBrowser.h
//  FlyByWireServer
//
//  Created by Retief Gerber on 2013/11/27.
//  Copyright (c) 2013 abductive. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ABNetworkServiceBrowserDelegate <NSObject>

@optional
- (void)foundService:(NSNetService *)service moreComing:(BOOL)moreComing;
- (void)removedService:(NSNetService *)service moreComing:(BOOL)moreComing;
- (void)foundNothing;
- (void)searchFinished;

@end

@interface ABNetworkServiceBrowser : NSObject <NSNetServiceBrowserDelegate>

@property (strong, nonatomic) NSMutableArray *services;

@property (strong, nonatomic) id<ABNetworkServiceBrowserDelegate> delegate;


- (void)startSearch;
- (void)stopSearch;

@end
