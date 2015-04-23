//
//  AppUtil.m
//  Database
//
//  Created by qianfeng on 14-9-2.
//  Copyright (c) 2014年 qianfeng. All rights reserved.
//

#import "AppUtil.h"

@implementation AppUtil
+(NSString *)getAppPath
{
    NSString *appPath= [[NSBundle mainBundle] resourcePath];
    return appPath;
}

+(NSString *)getCachesPath
{
    NSString *cachesPath = [NSString stringWithFormat:@"%@/Library/Caches/",NSHomeDirectory()];
    return cachesPath;
}

+(NSString *)getDocumentPath{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

@end
