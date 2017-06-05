//
//  InterfaceController.m
//  WZZSwordManGame WatchKit Extension
//
//  Created by 王泽众 on 2017/3/13.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import "InterfaceController.h"
#import "WZZWatchConnectWatchManager.h"

@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSLog(@"IawakeWithContext");
    [WZZWatchConnectWatchManager manager];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    NSLog(@"IwillActivate");
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    NSLog(@"IdidDeactivate");
}

@end



