//
//  WZZSocketManager.m
//  WZZTcpDemo
//
//  Created by 王泽众 on 16/10/21.
//  Copyright © 2016年 wzz. All rights reserved.
//

#import "WZZSocketManager.h"

@implementation WZZSocketServerManager
{
    void (^_handleDataBlock)(NSData *);//返回数据block
}

static WZZSocketServerManager *_sinstance;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sinstance = [super allocWithZone:zone];
    });
    
    return _sinstance;
}

+ (instancetype)sharedServerManager
{
    if (_sinstance == nil) {
        _sinstance = [[WZZSocketServerManager alloc] init];
    }
    
    _sinstance->_serverSocket = [[AsyncSocket alloc] initWithDelegate:_sinstance];
    
    return _sinstance;
}

//创建服务器
- (BOOL)creatServerWithPort:(NSString *)port timeOut:(int)timeOut handleData:(void (^)(NSData *))handleDataBlock {
    if (_handleDataBlock != handleDataBlock) {
        _handleDataBlock = handleDataBlock;
    }
    [_serverSocket disconnect];
    NSError * err;
    [_serverSocket acceptOnPort:[port intValue] error:&err];
    [_serverSocket readDataWithTimeout:-1 tag:0];
    if (err) {
        NSLog(@"%@", err);
        return NO;
    }
    return YES;
}

#pragma mark - 服务端代理
//客户端将要连接3.
- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
    NSLog(@"将要连接s");
    return YES;
}

//客户端要连接，服务端为客户端开辟新套接字2.
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    _serverSocket = newSocket;
    [_serverSocket readDataWithTimeout:-1 tag:0];
    NSLog(@"\nserver IP:%@:%d\nclient IP:%@:%d", newSocket.localHost, newSocket.localPort, newSocket.connectedHost, newSocket.connectedPort);
}

//读到数据
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (_handleDataBlock) {
        _handleDataBlock(data);
    }
    [_serverSocket readDataWithTimeout:-1 tag:0];
}

//写数据
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"写数据");
}

@end

@implementation WZZSocketClientManager

static WZZSocketClientManager *_cinstance;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cinstance = [super allocWithZone:zone];
    });
    
    return _cinstance;
}

+ (instancetype)sharedClientManager
{
    if (_cinstance == nil) {
        _cinstance = [[WZZSocketClientManager alloc] init];
    }
    
    _cinstance->_clientSocket = [[AsyncSocket alloc] initWithDelegate:_cinstance];
    
    return _cinstance;
}

//连接服务器
- (BOOL)connectServerWithHost:(NSString *)host port:(NSString *)port {
    [_clientSocket disconnect];
    NSError * err;
    [_clientSocket connectToHost:host onPort:[port intValue] error:&err];
    if (err) {
        NSLog(@"%@", err);
        return NO;
    }
    return YES;
}

//取消连接
- (void)disconnectServer {
    [_clientSocket disconnect];
}

//发送文本
- (void)sendString:(NSString *)string {
    [self sendDate:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

//发送数据
- (void)sendDate:(NSData *)data {
    [_clientSocket writeData:data withTimeout:-1 tag:0];
}

#pragma mark - 客户端代理方法
//客户端将要连接服务端1.
- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
    NSLog(@"将要连接c");
    return YES;
}

//已经连接上服务端4.
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"已连接上:%@:%d", host, port);
}

//读到数据
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

//写数据
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"写数据");
}

@end
