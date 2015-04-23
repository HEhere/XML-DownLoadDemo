//
//  AppUtil.h
//  Database
//
//  Created by qianfeng on 14-9-2.
//  Copyright (c) 2014年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtil : NSObject
+(NSString *)getAppPath;

+(NSString *)getCachesPath;

+ (NSString *)getDocumentPath;


@end
