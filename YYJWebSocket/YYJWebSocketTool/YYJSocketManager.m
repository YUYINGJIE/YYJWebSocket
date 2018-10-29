//
//  YYJSocketManager.m
//  YYJWebSocket
//
//  Created by YYJ on 2018/10/29.
//  Copyright © 2018年 YYJ. All rights reserved.
//

#import "YYJSocketManager.h"
#import "SRWebSocket.h"
#import "HZWebSocketMessgeModel.h"
#import <MJExtension/MJExtension.h>

#define WebSocketMessageSuccessRecieve @"WebSocketMessage"


@interface YYJSocketManager ()<SRWebSocketDelegate>
@property (nonatomic,strong)SRWebSocket *webSocket;
@property (nonatomic,assign)HZSocketStatus HZ_socketStatus;
@property (nonatomic,weak)NSTimer *timer;
@property (nonatomic,copy)NSString *urlString;
@property(nonatomic,strong) dispatch_source_t timer2;
@property(nonatomic,strong)NSMutableDictionary*Dictionary;


@end

@implementation YYJSocketManager

{
    NSInteger _reconnectCounter;
    NSInteger _rereceveCounter;
    
}

+ (instancetype)shareManager{
    static YYJSocketManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.overtime = 3;
        instance.reconnectCount = 20;
        
    });
    return instance;
}

-(NSMutableDictionary*)Dictionary{
    
    if (_Dictionary==nil) {
        _Dictionary = [NSMutableDictionary dictionary];
        _Dictionary[@"msg"] = @"PING";
    }
    return _Dictionary;
}

-(void)loginwithUserhosid:(NSString*)hosid userid:(NSString*)userid{
    
    [self.webSocket close];
    self.webSocket.delegate = nil;
    [self stopTimer2];
    // 开启成功后重置重连计数器
    _reconnectCounter = 0;
    _rereceveCounter = 0;
    
    NSString *url = [NSString stringWithFormat:@"web服务地址"];
    
    [self HZ_open:url connect:^{
        NSLog(@"成功连接");
        
    } receive:^(id message, HZSocketReceiveType type) {
        if (type == HZSocketReceiveTypeForMessage) {
            NSLog(@"接收 类型1--%@",message);
            if ([message isEqualToString:@"PONG"]) {
            }
            else{
                
                NSDictionary*dict= [self dictionaryWithJsonString:message];
                HZWebSocketMessgeModel*model=[HZWebSocketMessgeModel mj_objectWithKeyValues:dict];
                if ([model.msg isEqualToString:@"PING"]) {
                }
                else if ([model.msg isEqualToString:@"PONG"]){
                }
                else{
                    [[NSNotificationCenter defaultCenter]postNotificationName:WebSocketMessageSuccessRecieve object:model];
                }
            }
        }
        else if (type == HZSocketReceiveTypeForPong){
            NSLog(@"接收 类型2--%@",message);
        }
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)HZ_open:(NSString *)urlStr connect:(HZSocketDidConnectBlock)connect receive:(HZSocketDidReceiveBlock)receive failure:(HZSocketDidFailBlock)failure{
    [YYJSocketManager shareManager].connect = connect;
    [YYJSocketManager shareManager].receive = receive;
    [YYJSocketManager shareManager].failure = failure;
    [self HZ_open:urlStr];
}

- (void)HZ_close:(HZSocketDidCloseBlock)close{
    [YYJSocketManager shareManager].close = close;
    [self HZ_close];
}

// Send a UTF8 String or Data.
- (void)HZ_send:(id)data{
    switch ([YYJSocketManager shareManager].HZ_socketStatus) {
        case HZSocketStatusConnected:
        case HZSocketStatusReceived:{
            NSLog(@"发送中。。。");
            [self.webSocket send:data];
            break;
        }
        case HZSocketStatusFailed:
            NSLog(@"发送失败");
            if (_rereceveCounter == 5) {
                _reconnectCounter=0;
                [self stopTimer2];
                [self HZ_reconnect];
            }
            else{
                _rereceveCounter ++;
            }
            break;
        case HZSocketStatusClosedByServer:
            NSLog(@"已经关闭");
            if (_rereceveCounter == 5) {
                _reconnectCounter=0;
                [self stopTimer2];
                [self HZ_reconnect];
            }
            else{
                _rereceveCounter ++;
            }
            
            break;
        case HZSocketStatusClosedByUser:
            NSLog(@"已经关闭");
            if (_rereceveCounter == 5) {
                _reconnectCounter=0;
                [self stopTimer2];
                [self HZ_reconnect];
            }
            else{
                _rereceveCounter ++;
            }
            break;
    }
    
}

#pragma mark -- private method
- (void)HZ_open:(id)params{
    //    NSLog(@"params = %@",params);
    NSString *urlStr = nil;
    if ([params isKindOfClass:[NSString class]]) {
        urlStr = (NSString *)params;
    }
    else if([params isKindOfClass:[NSTimer class]]){
        NSTimer *timer = (NSTimer *)params;
        urlStr = [timer userInfo];
    }
    [YYJSocketManager shareManager].urlString = urlStr;
    [self.webSocket close];
    self.webSocket.delegate = nil;
    [self stopTimer2];
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    self.webSocket.delegate = self;
    
    [self.webSocket open];
}

- (void)HZ_close{
    
    [self.webSocket close];
    self.webSocket = nil;
    [self.timer invalidate];
    self.timer = nil;
    [self stopTimer2];
    
}

- (void)HZ_reconnect{
    // 计数+1
    if (_reconnectCounter < self.reconnectCount - 1) {
        _reconnectCounter ++;
        // 开启定时器
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.overtime target:self selector:@selector(HZ_open:) userInfo:self.urlString repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.timer = timer;
    }
    else{
        NSLog(@"Websocket Reconnected Outnumber ReconnectCount");
        [self stopTimer2];
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        return;
    }
    
}

#pragma mark -- SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"Websocket Connected");
    
    [YYJSocketManager shareManager].connect ? [YYJSocketManager shareManager].connect() : nil;
    [YYJSocketManager shareManager].HZ_socketStatus = HZSocketStatusConnected;
    // 开启成功后重置重连计数器
    _reconnectCounter = 0;
    [self startGCDTimer];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@":( Websocket Failed With Error %@", error);
    [YYJSocketManager shareManager].HZ_socketStatus = HZSocketStatusFailed;
    [YYJSocketManager shareManager].failure ? [YYJSocketManager shareManager].failure(error) : nil;
    // 重连
    [self HZ_reconnect];
    [self stopTimer2];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    //  NSLog(@":( Websocket Receive With message %@", message);
    [YYJSocketManager shareManager].HZ_socketStatus = HZSocketStatusReceived;
    [YYJSocketManager shareManager].receive ? [YYJSocketManager shareManager].receive(message,HZSocketReceiveTypeForMessage) : nil;
    _rereceveCounter=0;
    
    
    
}

-(void)startGCDTimer{
    
    NSTimeInterval period = 120.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer2, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer2, ^{
        
        //在这里执行事件
        NSString*jsonstr=[self.Dictionary mj_JSONString];
        [self HZ_send:jsonstr];
    });
    dispatch_resume(_timer2);
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
    
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"Closed Reason:%@  code = %zd",reason,code);
    if (reason) {
        [YYJSocketManager shareManager].HZ_socketStatus = HZSocketStatusClosedByServer;
        // 重连
        [self HZ_reconnect];
    }
    else{
        [YYJSocketManager shareManager].HZ_socketStatus = HZSocketStatusClosedByUser;
    }
    [YYJSocketManager shareManager].close ? [YYJSocketManager shareManager].close(code,reason,wasClean) : nil;
    self.webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    [YYJSocketManager shareManager].receive ? [YYJSocketManager shareManager].receive(pongPayload,HZSocketReceiveTypeForPong) : nil;
}
-(void)stopTimer2{
    if(_timer2){
        dispatch_source_cancel(_timer2);
        _timer2 = nil;
    }
}
- (void)dealloc{
    // Close WebSocket
    [self HZ_close];
}




@end
