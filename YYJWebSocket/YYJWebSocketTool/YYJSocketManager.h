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
typedef NS_ENUM(NSInteger,YYJSocketStatus){
    YYJSocketStatusConnected,// 已连接
    YYJSocketStatusFailed,// 失败
    YYJSocketStatusClosedByServer,// 系统关闭
    YYJSocketStatusClosedByUser,// 用户关闭
    YYJSocketStatusReceived// 接收消息
};
/**
 *
 *  消息类型
 */
typedef NS_ENUM(NSInteger,YYJSocketReceiveType){
    YYJSocketReceiveTypeForMessage,
    YYJSocketReceiveTypeForPong
};

/**
 *
 *  连接成功回调
 */
typedef void(^YYJSocketDidConnectBlock)();
/**
 *  @author 孔凡列
 *
 *  失败回调
 */
typedef void(^YYJSocketDidFailBlock)(NSError *error);
/**
 *
 *  关闭回调
 */
typedef void(^YYJSocketDidCloseBlock)(NSInteger code,NSString *reason,BOOL wasClean);
/**
 *
 *  消息接收回调
 */
typedef void(^YYJSocketDidReceiveBlock)(id message ,YYJSocketReceiveType type);

@interface YYJSocketManager : NSObject
/**
 *
 *  连接回调
 */
@property (nonatomic,copy)YYJSocketDidConnectBlock connect;
/**
 *
 *  接收消息回调
 */
@property (nonatomic,copy)YYJSocketDidReceiveBlock receive;
/**
 *
 *  失败回调
 */
@property (nonatomic,copy)YYJSocketDidFailBlock failure;
/**
 *
 *  关闭回调
 */
@property (nonatomic,copy)YYJSocketDidCloseBlock close;
/**
 *
 *  当前的socket状态
 */
@property (nonatomic,assign,readonly)YYJSocketStatus YYJ_socketStatus;
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
- (void)YYJ_open:(NSString *)urlStr connect:(YYJSocketDidConnectBlock)connect receive:(YYJSocketDidReceiveBlock)receive failure:(YYJSocketDidFailBlock)failure;
/**
 *
 *  关闭socket
 *
 *  @param close 关闭回调
 */
- (void)YYJ_close:(YYJSocketDidCloseBlock)close;
/**
 *
 *  发送消息，NSString 或者 NSData
 *
 *  @param data Send a UTF8 String or Data.
 */
- (void)YYJ_send:(id)data;
-(void)loginwithUserhosid:(NSString*)hosid userid:(NSString*)userid;
-(void)stopTimer2;


@end

NS_ASSUME_NONNULL_END
