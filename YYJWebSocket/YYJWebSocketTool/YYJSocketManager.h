//
//  YYJSocketManager.h
//  YYJWebSocket
//
//  Created by YYJ on 2018/10/29.
//  Copyright © 2018年 YYJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *
 *  socket状态
 */
typedef NS_ENUM(NSInteger,HZSocketStatus){
    HZSocketStatusConnected,// 已连接
    HZSocketStatusFailed,// 失败
    HZSocketStatusClosedByServer,// 系统关闭
    HZSocketStatusClosedByUser,// 用户关闭
    HZSocketStatusReceived// 接收消息
};
/**
 *
 *  消息类型
 */
typedef NS_ENUM(NSInteger,HZSocketReceiveType){
    HZSocketReceiveTypeForMessage,
    HZSocketReceiveTypeForPong
};

/**
 *
 *  连接成功回调
 */
typedef void(^HZSocketDidConnectBlock)();
/**
 *  @author 孔凡列
 *
 *  失败回调
 */
typedef void(^HZSocketDidFailBlock)(NSError *error);
/**
 *
 *  关闭回调
 */
typedef void(^HZSocketDidCloseBlock)(NSInteger code,NSString *reason,BOOL wasClean);
/**
 *
 *  消息接收回调
 */
typedef void(^HZSocketDidReceiveBlock)(id message ,HZSocketReceiveType type);

@interface YYJSocketManager : NSObject
/**
 *
 *  连接回调
 */
@property (nonatomic,copy)HZSocketDidConnectBlock connect;
/**
 *
 *  接收消息回调
 */
@property (nonatomic,copy)HZSocketDidReceiveBlock receive;
/**
 *
 *  失败回调
 */
@property (nonatomic,copy)HZSocketDidFailBlock failure;
/**
 *
 *  关闭回调
 */
@property (nonatomic,copy)HZSocketDidCloseBlock close;
/**
 *
 *  当前的socket状态
 */
@property (nonatomic,assign,readonly)HZSocketStatus HZ_socketStatus;
/**
 *
 *  超时重连时间，默认1秒
 */
@property (nonatomic,assign)NSTimeInterval overtime;
/**
 *  @author Clarence
 *  可自定义 自行设置
 *  重连次数,默认5次
 */
@property (nonatomic, assign)NSUInteger reconnectCount;
/**
 *
 *  单例调用
 */
+ (instancetype)shareManager;
/**
 *
 *  开启socket
 *
 *  @param urlStr  服务器地址
 *  @param connect 连接成功回调
 *  @param receive 接收消息回调
 *  @param failure 失败回调
 */
- (void)HZ_open:(NSString *)urlStr connect:(HZSocketDidConnectBlock)connect receive:(HZSocketDidReceiveBlock)receive failure:(HZSocketDidFailBlock)failure;
/**
 *
 *  关闭socket
 *
 *  @param close 关闭回调
 */
- (void)HZ_close:(HZSocketDidCloseBlock)close;
/**
 *
 *  发送消息，NSString 或者 NSData
 *
 *  @param data Send a UTF8 String or Data.
 */
- (void)HZ_send:(id)data;
-(void)loginwithUserhosid:(NSString*)hosid userid:(NSString*)userid;
-(void)stopTimer2;


@end

NS_ASSUME_NONNULL_END
