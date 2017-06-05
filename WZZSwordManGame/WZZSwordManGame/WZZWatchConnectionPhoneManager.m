//
//  WZZWatchConnectionPhoneManager.m
//  WZZSwordManGame
//
//  Created by 王泽众 on 2017/3/13.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import "WZZWatchConnectionPhoneManager.h"
@import WatchConnectivity;

static WZZWatchConnectionPhoneManager * manager;

@interface WZZWatchConnectionPhoneManager ()<WCSessionDelegate>
{
    WCSession * mainSession;
}

@end

@implementation WZZWatchConnectionPhoneManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WZZWatchConnectionPhoneManager alloc] init];
        if ([WCSession isSupported]) {
            manager->mainSession = [WCSession defaultSession];
            manager->mainSession.delegate = manager;
            [manager->mainSession activateSession];
        }
    });
    return manager;
}

#pragma mark - 手表会话代理
- (void)sessionReachabilityDidChange:(WCSession *)session {
    switch (session.activationState) {
        case WCSessionActivationStateNotActivated:
        {
            NSLog(@"不活动");
        }
            break;
        case WCSessionActivationStateActivated:
        {
            NSLog(@"活动");
        }
            break;
        case WCSessionActivationStateInactive:
        {
            NSLog(@"闲置");
        }
            break;
            
        default:
            break;
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    NSString * msg = message[@"msg"];
    NSLog(@"msg:%@", msg);
    
}

@end
