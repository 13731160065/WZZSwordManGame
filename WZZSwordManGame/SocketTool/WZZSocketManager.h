//
//  WZZSocketManager.h
//  WZZTcpDemo
//
//  Created by 王泽众 on 16/10/21.
//  Copyright © 2016年 wzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@interface WZZSocketServerManager : NSObject<AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket * serverSocket;

/**
 服务端单例
 */
+ (instancetype)sharedServerManager;

/**
 创建服务器
 */
- (BOOL)creatServerWithPort:(NSString *)port timeOut:(int)timeOut handleData:(void(^)(NSData * data))handleDataBlock;

@end

@interface WZZSocketClientManager : NSObject<AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket * clientSocket;

/**
 客户端单例
 */
+ (instancetype)sharedClientManager;

/**
 连接服务器
 */
- (BOOL)connectServerWithHost:(NSString *)host port:(NSString *)port;

/**
 关闭连接
 */
- (void)disconnectServer;

/**
 发送数据
 */
- (void)sendDate:(NSData *)data;

/**
 发送字符串
 */
- (void)sendString:(NSString *)string;

@end