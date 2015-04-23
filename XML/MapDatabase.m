//
//  MapDatabase.m
//  nav
//
//  Created by lifangli on 15/1/12.
//  Copyright (c) 2015年 erlinyou.com. All rights reserved.
//

#import "MapDatabase.h"
#import "FMDatabase.h"
#import "AppUtil.h"
#import "Map.h"

@implementation MapDatabase
{
    FMDatabase *_fmdb;
    FMDatabase *_fmdb1;
}

static MapDatabase *_shareMapDatabase;
+(MapDatabase *)shareMapDatabase
{
    if (!_shareMapDatabase) {
        _shareMapDatabase = [[MapDatabase alloc]init];
    }
    return _shareMapDatabase;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mapList=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)createMapDatabase
{
    NSString *path = [NSString stringWithFormat:@"%@demo4.db",[AppUtil getCachesPath]];
    _fmdb = [[FMDatabase alloc]initWithPath:path];
    NSLog(@"path=%@",path);
    if ([_fmdb open]) {
        NSLog(@"数据库打开成功");
    }
    else {
        NSLog(@"数据库打开失败");
    }
}

-(void)createTable;
{
    [_fmdb open];
    [_fmdb executeUpdateWithFormat:@"create table Map(MapNum integer primary key autoincrement,MapImageStr text,MapSize integer,MapId integer,MapDescription text,MapTitle text,MapName text)"];
    
    [_fmdb close];
}

-(void)insertMapWithMapNum:(NSInteger)num andMapImageStr:(NSString *)imageStr andMapTitle:(NSString *)title andMapDescription:(NSString *)description andMapSize:(long long)size andMapId:(NSInteger)idStr andMapName:(NSString *)name
{
    [_fmdb open];
    [_fmdb executeUpdate:@"insert into Map(MapNum,MapImageStr,MapTitle,MapDescription,MapSize,MapId,MapName) values(?,?,?,?,?,?,?)",[NSNumber numberWithInteger:num],imageStr,title,description,[NSNumber numberWithLongLong:size],[NSNumber numberWithInteger:idStr],name];
    [_fmdb close];
}

-(void)deleteMapWithMapId:(NSInteger)mapId
{
    [_fmdb open];//[_fmdb executeUpdate:@"delete from Article where Articletitle=?",title];
    BOOL isSuccess = [_fmdb executeUpdate:@"delete from Map where MapId=?",[NSNumber numberWithInteger:mapId]];
    if (isSuccess) {
        NSLog(@"删除成功");
    }else{
        NSLog(@"删除失败");
    }
    [_fmdb close];
}

-(void)selectALLMapWith:(NSMutableArray *)array
{
    [_fmdb open];
    //结果集
    FMResultSet *res = [_fmdb executeQuery:@"select * from Map"];
    //每一次循环是一行数据
    while ([res next]) {
        Map *map = [[Map alloc] init];
        map.imageStr = [res stringForColumn:@"MapImageStr"];
        map.titleStr = [res stringForColumn:@"MapTitle"];
        map.descriptionStr = [res stringForColumn:@"MapDescription"];
        map.fileInitSize = [[res stringForColumn:@"MapSize"] integerValue];
        map.mapId = [res stringForColumn:@"MapId"];
        map.packageNameStr = [res stringForColumn:@"MapName"];
        NSLog(@"111");
        NSLog(@"222");
        if(map!=nil){
            [array addObject:map];
        }
    }
    [_fmdb close];
}

-(void)createMapDatabase1
{
    NSString *path = [NSString stringWithFormat:@"%@demo5.db",[AppUtil getCachesPath]];
    _fmdb1 = [[FMDatabase alloc]initWithPath:path];
    NSLog(@"path=%@",path);
    if ([_fmdb1 open]) {
        NSLog(@"数据库打开成功");
    }
    else {
        NSLog(@"数据库打开失败");
    }
}

-(void)createTable1;
{
    [_fmdb1 open];
    [_fmdb1 executeUpdateWithFormat:@"create table Map1(MapNum integer primary key autoincrement,MapImageStr text,MapSize integer,MapId integer,MapDescription text,MapTitle text,MapName text,MapFilePath text)"];
    
    [_fmdb1 close];
}

-(void)insertMap1WithMapImageStr:(NSString *)imageStr andMapTitle:(NSString *)title andMapDescription:(NSString *)description andMapSize:(long long)size andMapId:(NSInteger)idStr andMapName:(NSString *)name andFilePath:(NSString *)filePath
{
    [_fmdb1 open];
    [_fmdb1 executeUpdate:@"insert into Map1(MapImageStr,MapTitle,MapDescription,MapSize,MapId,MapName,MapFilePath) values(?,?,?,?,?,?,?)",imageStr,title,description,[NSNumber numberWithLongLong:size],[NSNumber numberWithInteger:idStr],name,filePath];
    [_fmdb1 close];
}

-(void)deleteMap1WithMapId:(NSInteger)mapId
{
    [_fmdb1 open];
    [_fmdb1 executeUpdate:@"delete from Map1 where MapId=?",[NSNumber numberWithInteger:mapId]];
    [_fmdb1 close];
}

-(void)selectALLMap1With:(NSMutableArray *)array
{
    [_fmdb1 open];
    //结果集
    FMResultSet *res = [_fmdb1 executeQuery:@"select * from Map1"];
    //每一次循环是一行数据
    while ([res next]) {
        Map *map = [[Map alloc] init];
        map.imageStr = [res stringForColumn:@"MapImageStr"];
        map.titleStr = [res stringForColumn:@"MapTitle"];
        map.descriptionStr = [res stringForColumn:@"MapDescription"];
        map.fileInitSize = [[res stringForColumn:@"MapSize"] integerValue];
        map.mapId = [res stringForColumn:@"MapId"];
        map.packageNameStr = [res stringForColumn:@"MapName"];
        if(map!=nil){
            [array addObject:map];
        }
    }
    [_fmdb1 close];
}

@end
