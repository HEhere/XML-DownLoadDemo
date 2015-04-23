//
//  MapDatabase.h
//  nav
//
//  Created by lifangli on 15/1/12.
//  Copyright (c) 2015年 erlinyou.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapDatabase : NSObject

@property (nonatomic, strong) NSMutableArray *mapList;

+(MapDatabase *)shareMapDatabase;

-(void)createMapDatabase;
-(void)createTable;
-(void)insertMapWithMapNum:(NSInteger)num andMapImageStr:(NSString *)imageStr andMapTitle:(NSString *)title andMapDescription:(NSString *)description andMapSize:(long long)size andMapId:(NSInteger)idStr andMapName:(NSString *)name;
-(void)deleteMapWithMapId:(NSInteger)mapId;
-(void)selectALLMapWith:(NSMutableArray *)array;

-(void)createMapDatabase1;
-(void)createTable1;

//插入已经下载好的地图数据
-(void)insertMap1WithMapImageStr:(NSString *)imageStr andMapTitle:(NSString *)title andMapDescription:(NSString *)description andMapSize:(long long)size andMapId:(NSInteger)idStr andMapName:(NSString *)name andFilePath:(NSString *)filePath;
-(void)deleteMap1WithMapId:(NSInteger)mapId;
-(void)selectALLMap1With:(NSMutableArray *)array;

@end
