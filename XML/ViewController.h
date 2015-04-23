//
//  ViewController.h
//  XML
//
//  Created by lifangli on 15/1/7.
//  Copyright (c) 2015年 lifangli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Map.h"

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    UIBackgroundTaskIdentifier backgroundTask;
}

-(void)startBackgroundTask;

@property (nonatomic,strong) UITableView *listTableView;

@end

//http://mappackdownload.map.baidu.com/data/099/Bei_Jing_Shi_131_hv_baidu.zip

/*附件为地图列表xml及图片
 字段说明：
 id 顺序
 image 图片名称（为0表示为目录项）
 title 地图名称
 description 地图描述
 packageName 解压文件夹名称（也用来当作从服务器获取下载链接的地图id）
 fileInitSize 地图大小
 
 测试下载时可以先写死下载地址（用下面的百度地图zip），后期再和服务器进行接口对接获取下载地址。
 
 百度北京地图包下载地址（24M）
 http://mappackdownload.map.baidu.com/data/099/Bei_Jing_Shi_131_hv_baidu.zip
 
 功能需求描述：
 开始下载，暂停下载，取消下载；解压地图； 删除已下载完成的地图。
 下载进度要能够保存（下次进入软件能够继续未完成的下载）
 网络不可用、非Wifi下载。。。各种情况有不同的提示或响应
 地图列表xml要根据当前语言加载，附件中是中文的，以后会提供city_list_en.xml，city_list_cn.xml，city_list_fr.xml 。。。。
 
 其他细节我需要时间整理一下，再补充给你
 不明白随时问我*/