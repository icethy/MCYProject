//
//  MCYRequestManager.h
//  MCYProject
//
//  Created by machunyan on 2017/8/28.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *NetStatusChangeNotification;
extern NSString *NetStatusChangeStatusKey;

typedef NS_ENUM(NSUInteger, MCYNetStatus) {
    MCYNetStatusUnKnown = 1,
    MCYNetStatusNotReachable,
    MCYNetStatusWIFI,
    MCYNetStatusWWAN
};


@class MCYRequest;
@interface MCYRequestManager : NSObject

@property (nonatomic,assign,readonly) MCYNetStatus currentStatus;
@property (nonatomic,assign,readonly) BOOL reachable;


+ (MCYRequestManager *)sharedManager;

- (void)addRequest:(MCYRequest*)request;

- (void)cancelRequest:(MCYRequest*)request;

- (void)cancelAllRequest;

@end
