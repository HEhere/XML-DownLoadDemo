//
//  Map.m
//  XML
//
//  Created by lifangli on 15/1/7.
//  Copyright (c) 2015年 lifangli. All rights reserved.
//

#import "Map.h"

@implementation Map

- (instancetype)init{
    self = [super init];
    if (self) {
        _progressValue = 0.0;
        _isDownload = NO;
        _isPause = NO;
    }
    return self;
}

@end
