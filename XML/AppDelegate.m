//
//  AppDelegate.m
//  XML
//
//  Created by lifangli on 15/1/7.
//  Copyright (c) 2015年 lifangli. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Reachability.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self startNetMonitor];
    
    return YES;
}


-(void)startNetMonitor
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    [[Reachability reachabilityForInternetConnection]startNotifier];
    [self updateInterfaceWithReachability:[Reachability reachabilityForInternetConnection]];
}

// 连接改变
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}

//处理连接改变后的情况
- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    //对连接改变做出响应的处理动作。
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status!=ReachableViaWiFi)
    {
        
        //处理系列下载
        //这里应该是把你的下载  置为暂停
    }
    else
    {
        
        //处理系列下载
        //这里可以是把下载  继续下载

    }
}


-(void)applicationWillTerminate:(UIApplication *)application
{
    //这是程序即将被杀死时  做一些 数据保存工资，也可以把你正下在的文件 置为暂停
    
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    //程序进入后天要做的工作
    
    //可以在这里把你的下载 放到后台继续下载
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}



- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    return UIInterfaceOrientationMaskAll;
}

@end
