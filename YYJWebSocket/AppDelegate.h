//
//  AppDelegate.h
//  YYJWebSocket
//
//  Created by huahaniOSCode on 2018/10/29.
//  Copyright © 2018年 HuaHan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

