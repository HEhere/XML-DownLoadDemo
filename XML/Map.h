//
//  Map.h
//  XML
//
//  Created by lifangli on 15/1/7.
//  Copyright (c) 2015年 lifangli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Map : NSObject

//图片名称（为0表示为目录项）
@property (nonatomic, strong) NSString *imageStr;

//地图名称
@property (nonatomic, strong) NSString *titleStr;

//地图描述
@property (nonatomic, strong) NSString *descriptionStr;

//解压文件夹名称
@property (nonatomic, strong) NSString *packageNameStr;

//地图大小
@property (nonatomic, assign) long long fileInitSize;

//地图ID
@property (nonatomic, strong) NSString * mapId;

//进度条的大小
@property (nonatomic, assign) double progressValue;
//是否正在下载
@property (nonatomic, assign) BOOL isDownload;
//是否是暂停状态
@property (nonatomic, assign) BOOL isPause;
//当前所在的cell的组
@property (nonatomic, strong) NSString *section;
//当前所在的cell的行
@property (nonatomic, strong) NSString *row;
//已经下载的地图的路径
@property (nonatomic, strong) NSString *filePath;

@end
