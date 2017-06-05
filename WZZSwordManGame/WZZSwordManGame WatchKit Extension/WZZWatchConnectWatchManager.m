//
//  WZZWatchConnectWatchManager.m
//  WZZSwordManGame
//
//  Created by 王泽众 on 2017/3/13.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import "WZZWatchConnectWatchManager.h"
@import WatchConnectivity;

static WZZWatchConnectWatchManager * manager;

@interface WZZWatchConnectWatchManager ()<WCSessionDelegate>
{
    WCSession * mainSession;
    NSTimer * timer;
}

@end

@implementation WZZWatchConnectWatchManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WZZWatchConnectWatchManager alloc] init];
        if ([WCSession isSupported]) {
            manager->mainSession = [WCSession defaultSession];
            manager->mainSession.delegate = manager;
            [manager->mainSession activateSession];
            manager->timer = [NSTimer scheduledTimerWithTimeInterval:0.01f repeats:YES block:^(NSTimer * _Nonnull timer) {
                [manager->mainSession sendMessage:@{@"msg":@"1"} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                    NSLog(@"rep:%@", replyMessage);
                } errorHandler:^(NSError * _Nonnull error) {
                    NSLog(@"err:%@", error);
                }];
            }];
        }
    });
    return manager;
}

#pragma mark - 手表会话代理

@end
