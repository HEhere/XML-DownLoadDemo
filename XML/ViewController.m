//
//  ViewController.m
//  XML
//
//  Created by lifangli on 15/1/7.
//  Copyright (c) 2015年 lifangli. All rights reserved.
//

#import "ViewController.h"
#import "GDataXMLNode.h"
#import "DownLoadXibCell.h"
#import "SSZipArchive.h"
#import "MapDatabase.h"
#import "DownloadManager.h"

#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height

@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray *_dataList;
    NSMutableArray *_downLoadList;
    NSInteger index;
    NSInteger longPressIndex;
    MapDatabase *_mapDb;
    unsigned long long tempSize;
    
    //下载管理类
    DownloadManager *_dlManager;
    int w;
    int h;
    UIView *view;
    UILabel *label1;
    UILabel *label2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //初始化
    _dlManager = [DownloadManager shareDownloadManager];
    _dataList = [[NSMutableArray alloc] init];
    _downLoadList = [[NSMutableArray alloc] init];
    
    _mapDb = [MapDatabase shareMapDatabase];
    [_mapDb createMapDatabase];
    [_mapDb createTable];
    
    [_mapDb selectALLMapWith:_dataList];
    if (!_dataList || !_dataList.count) {
        [self analysisXML];
        [_mapDb selectALLMapWith:_dataList];
    }
    
    //恢复上次的任务
    [self renewDownTask];
    
    [_mapDb createMapDatabase1];
    [_mapDb createTable1];
    [_mapDb selectALLMap1With:_downLoadList];
    
    _listTableView = [[UITableView alloc] init];
    _listTableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
    _listTableView.delegate=self;
    _listTableView.dataSource=self;
    [self.view addSubview:_listTableView];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
     if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        _listTableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
         /*view.frame = CGRectMake(0, 0, WIDTH, 30);
         label1.frame = CGRectMake(0, 0, WIDTH, 30);
         label2.frame = CGRectMake(WIDTH-140, 10, 115, 20);*/
    }else
    {
        _listTableView.frame = CGRectMake(0, 20, WIDTH, HEIGHT-20);
        /*view.frame = CGRectMake(0, 0, WIDTH, 30);
        label1.frame = CGRectMake(0, 0, WIDTH, 30);
        label2.frame = CGRectMake(WIDTH-140, 10, 115, 20);*/
    }
    [_listTableView reloadData];
}

-(void)startBackgroundTask
{
    UIApplication *application = [UIApplication sharedApplication];
    //通知系统, 我们需要后台继续执行一些逻辑
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        //超过系统规定的后台运行时间, 则暂停后台逻辑
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    //判断如果申请失败了, 返回
    if (backgroundTask == UIBackgroundTaskInvalid) {
        NSLog(@"beginground error");
        return;
    }
    
    //已经成功向系统争取了一些后台运行时间, 实现一些逻辑, 如网络处理
    //some code
    //Map *map = [_dataList objectAtIndex:index];
    //map.isDownload = YES;
}

- (void)requestFinished
{
    if (backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self startBackgroundTask];
}


//解析本地xml
-(void)analysisXML
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"city_list" ofType:@"xml"];
    NSString* xmlStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithXMLString:xmlStr options:0 error:nil];
    
    GDataXMLElement *rootElement = [doc rootElement];
    NSArray *cityList = [rootElement elementsForName:@"city"];
    
    for(GDataXMLElement *city in cityList){
        Map* map = [[Map alloc] init];
        GDataXMLElement *image=[[city elementsForName:@"image"] objectAtIndex:0];
        map.imageStr=[image stringValue];
        
        GDataXMLElement *title=[[city elementsForName:@"title"] objectAtIndex:0];
        map.titleStr=[title stringValue];
        
        GDataXMLElement *description=[[city elementsForName:@"description"] objectAtIndex:0];
        map.descriptionStr=[description stringValue];
        
        GDataXMLElement *packageName=[[city elementsForName:@"packageName"] objectAtIndex:0];
        map.packageNameStr=[packageName stringValue];
        
        GDataXMLElement *fileInitSize=[[city elementsForName:@"fileInitSize"] objectAtIndex:0];
        map.fileInitSize=[[fileInitSize stringValue] longLongValue];
        
        GDataXMLNode *mapId=[city attributeForName:@"id"];
        NSLog(@"mapID ========= %@",[mapId stringValue]);
        map.mapId= [mapId stringValue];
        
        [_mapDb insertMapWithMapNum:[map.mapId intValue]-1 andMapImageStr:map.imageStr andMapTitle:map.titleStr andMapDescription:map.descriptionStr andMapSize:map.fileInitSize andMapId:[map.mapId intValue] andMapName:map.packageNameStr];
    }
    
}

- (void)renewDownTask{
    for (Map *subMap in _dataList) {
        NSLog(@"map.id ======= %@",subMap.mapId);
        if ([[NSUserDefaults standardUserDefaults] objectForKey:subMap.mapId]) {
            NSString *progress = [[NSUserDefaults standardUserDefaults] objectForKey:subMap.mapId];
            if (progress && progress.length>0) {
                subMap.isDownload = NO;
                subMap.isPause = YES;
            }
        }
    }
}

//获取文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

- (void)downloadWithURL:(NSString *)urlStr andInfoMap:(Map *)map andCell:(DownLoadXibCell *)cell{
    
    //开始下载任务
    [_dlManager starRequestTask:urlStr andFileName:map.packageNameStr andKey:map.mapId underway:^(long long downloadByte, long long totalByte) {
        
        cell.progressView.progress = downloadByte/(double)totalByte;
        cell.descriptionLabel.text = [NSString stringWithFormat:@"下载中 %.1f MB / %ld MB",cell.progressView.progress*map.fileInitSize ,(long)map.fileInitSize];
        NSLog(@"downloadByte ===== %lld",downloadByte);
        NSLog(@"totalByte ===== %lld",totalByte);
        
    }];
    
    //删除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self name:map.mapId object:nil];
    //注册观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:map.mapId object:nil];
}

#pragma mark --------------------------------- tableView的协议方法 ---------------------------------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return [_downLoadList count];
    }
    else
        return [_dataList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName=@"cell";
    
    DownLoadXibCell* cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DownLoadXibCell" owner:self options:nil] lastObject];
        //删除事件
        [cell.cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.cancelBtn.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.descriptionLabel.frame = CGRectMake(68, 25, WIDTH-68-60, 30);
    cell.fileSizeLabel.frame = CGRectMake(WIDTH-75, 17, 60, 28);
    cell.progressView.frame = CGRectMake(68, 50, WIDTH-68-15, 2);
    cell.cancelBtn.frame = CGRectMake(WIDTH-33, 21, 18, 18);
    //解除复用问题
    cell.progressView.progress = 0.0;
    
    if(indexPath.section == 1){//没有被下载的地图
        
        Map *map= [_dataList objectAtIndex:indexPath.row];
        if([map.imageStr isEqualToString:@"0"]){//标题 ---- 亚洲、国内、美洲等
            cell.iconImageView.frame = CGRectMake(0, 0, WIDTH, 28);
            cell.iconImageView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.1];
            cell.iconImageView.image = nil;
            
            cell.descriptionLabel.hidden = YES;
            cell.fileSizeLabel.hidden = YES;
            
            cell.cityLabel.frame = CGRectMake(20, 0, WIDTH, 28);
            cell.cityLabel.text = map.titleStr;
            cell.cityLabel.textColor = [UIColor blackColor];
            
            cell.progressView.hidden = YES;
            cell.cancelBtn.hidden = YES;
            return cell;
            
        }else{//还没被下载或正在下载的地图
            
            cell.iconImageView.image = [UIImage imageNamed:map.imageStr];
            cell.cityLabel.text = map.titleStr;
            cell.cityLabel.frame = CGRectMake(68, 5, WIDTH-68-60, 25);
            cell.cancelBtn.tag = indexPath.row;
            
            //判断下载的状态
            if (map.isDownload) {//正在下载
                cell.fileSizeLabel.hidden = YES;
                cell.progressView.hidden = NO;
                
                //获取进度条的值  ----- mapId作为key
                float progressValue = [[[NSUserDefaults standardUserDefaults] objectForKey:map.mapId] floatValue];
                cell.progressView.progress = progressValue;
                NSLog(@"progress ============== %f",progressValue);
                
                cell.descriptionLabel.text = [NSString stringWithFormat:@"下载中 %.1f MB / %ld MB",cell.progressView.progress*map.fileInitSize ,(long)map.fileInitSize];
                cell.descriptionLabel.textColor = [UIColor blueColor];
                
                //重新开始下载
                [_dlManager stopRequestTask:map.mapId];
                NSString *urlStr = [NSString stringWithFormat:@"http://mdownload.erlinyou.com/apple_test/com.erlinyou.pek.chinese.zip"];
                [self downloadWithURL:urlStr andInfoMap:map andCell:cell];
                
            }else if (map.isPause) {//暂停中
                cell.fileSizeLabel.hidden = YES;
                cell.progressView.hidden = NO;
                //获取进度条的值  ----- mapId作为key
                float progressValue = [[[NSUserDefaults standardUserDefaults] objectForKey:map.mapId] floatValue];
                cell.progressView.progress = progressValue;
                NSLog(@"progress ============== %f",progressValue);
                
                cell.descriptionLabel.text = [NSString stringWithFormat:@"暂停中 %.1f MB / %ld MB",cell.progressView.progress*map.fileInitSize ,(long)map.fileInitSize];
                cell.descriptionLabel.textColor = [UIColor brownColor];
                
            }else{//还未下载
                cell.fileSizeLabel.hidden = NO;
                cell.fileSizeLabel.text = [NSString stringWithFormat:@"%ld MB",(long)map.fileInitSize];
                
                cell.descriptionLabel.hidden = NO;
                cell.descriptionLabel.text = map.descriptionStr;
                
                cell.progressView.hidden = YES;
                cell.cancelBtn.hidden = YES;
            }
            return cell;
        }
        
    }else{//已经下载好的地图
        
        Map *map= [_downLoadList objectAtIndex:indexPath.row];
        
        cell.iconImageView.image = [UIImage imageNamed:map.imageStr];
        cell.cityLabel.frame = CGRectMake(68, 5, WIDTH-68-60, 25);
        cell.cityLabel.text = map.titleStr;
        cell.descriptionLabel.text = map.descriptionStr;
        cell.fileSizeLabel.text = [NSString stringWithFormat:@"%ld MB",(long)map.fileInitSize];
        
        cell.progressView.hidden = YES;
        cell.cancelBtn.hidden = YES;
        
        UILongPressGestureRecognizer *pgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        [cell.contentView addGestureRecognizer:pgr];
        return cell;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){//没有被完全下载好的地图被点击
    
        Map *map= [_dataList objectAtIndex:indexPath.row];
        if (!([map.imageStr isEqualToString:@"0"])) {//地图
            
            map.section = [NSString stringWithFormat:@"%d",(int)(indexPath.section)];
            map.row = [NSString stringWithFormat:@"%d",(int)(indexPath.row)];
            
            DownLoadXibCell *cell =(DownLoadXibCell*) [tableView cellForRowAtIndexPath:indexPath];
            cell.progressView.hidden = NO;
            cell.cancelBtn.hidden = NO;
            cell.fileSizeLabel.hidden = YES;
            
            cell.cancelBtn.userInteractionEnabled = YES;
            
            //判断地图下载的状态
            if (map.isDownload) {//正在下载中
                //改变状态 ----- 暂停状态
                map.isDownload = NO;
                map.isPause = YES;
                
                //删除下载任务 ----- 通过key来删除任务
                [_dlManager stopRequestTask:map.mapId];
                //移除通知
                [[NSNotificationCenter defaultCenter] removeObserver:self name:map.mapId object:nil];
                
                cell.descriptionLabel.text = [NSString stringWithFormat:@"暂停中 %.1f MB / %ld MB",cell.progressView.progress*map.fileInitSize ,(long)map.fileInitSize];
                cell.descriptionLabel.textColor = [UIColor brownColor];
                
                
            }else if (map.isPause){//暂停中
                //改变状态 ----- 下载状态
                map.isPause = NO;
                map.isDownload = YES;
                
                NSString *urlStr = [NSString stringWithFormat:@"http://mdownload.erlinyou.com/apple_test/com.erlinyou.pek.chinese.zip"];
                
                //开始下载任务
                [self downloadWithURL:urlStr andInfoMap:map andCell:cell];
                
                cell.descriptionLabel.text = [NSString stringWithFormat:@"连接中 %.1f MB / %ld MB",cell.progressView.progress*map.fileInitSize ,(long)map.fileInitSize];
                cell.descriptionLabel.textColor = [UIColor blueColor];
                
            }else{//还没开始下载
                //改变状态 ----- 下载状态
                map.isPause = NO;
                map.isDownload = YES;
                
                NSString *urlStr = [NSString stringWithFormat:@"http://mdownload.erlinyou.com/apple_test/com.erlinyou.pek.chinese.zip"];
                [self downloadWithURL:urlStr andInfoMap:map andCell:cell];

                cell.descriptionLabel.text = [NSString stringWithFormat:@"连接中 %.1f MB / %ld MB",cell.progressView.progress*map.fileInitSize ,(long)map.fileInitSize];
                cell.descriptionLabel.textColor = [UIColor blueColor];
            }
        }
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0){
        return @"已下载";
    }
    else{
        return @"未下载";
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, WIDTH, 30);
    
    label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(0, 0, WIDTH, 30);
    label1.textColor = [UIColor whiteColor];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font =[UIFont boldSystemFontOfSize:19];
    [view addSubview:label1];
    
    label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(WIDTH-140, 10, 115, 20);
    label2.textColor = [UIColor whiteColor];
    label2.textAlignment = NSTextAlignmentRight;
    label2.font =[UIFont boldSystemFontOfSize:12];
    [view addSubview:label2];
    
    if(section==0){
        view.backgroundColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.2 alpha:1];
        label1.text = @"已下载";
        label2.text = @"点击打开，长按删除";
    }
    else{
        view.backgroundColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.6 alpha:1];
        label1.text = @"未下载";
        label2.text = @"点击开始下载或暂停";
    }
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        Map *map=[[Map alloc]init];
        map = [_dataList objectAtIndex:indexPath.row];
        if([map.imageStr isEqualToString:@"0"]){
            return 28.0f;
        }
        else
            return 60.0f;
    }
    else
        return 60;
}

#pragma mark ------------------------------------- 响应事件 -----------------------------------------
//点击删除下载的任务
- (void)btnClick:(UIButton *)btn
{
    //点击之后暂停
    Map *map = [_dataList objectAtIndex:btn.tag];
    //[_dlManager stopRequestTask:map.mapId];
    index = btn.tag;
    NSLog(@"map.id ====== %@",map.mapId);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定取消下载%@地图?",map.titleStr] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"取消"];
    alert.tag = 0;
    [alert show];
}

//长按删除手势
-(void)longPressGesture:(UILongPressGestureRecognizer *)longPress
{
    if(longPress.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [longPress locationInView:_listTableView];
        NSIndexPath * indexPath = [_listTableView indexPathForRowAtPoint:point];
        if(indexPath == nil)
            return ;
        else{
            longPressIndex = indexPath.row;
            Map *map = [_downLoadList objectAtIndex:indexPath.row];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定删除%@地图?（注意：离线地图删除后将无法恢复，如需使用可重新下载）",map.titleStr] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert addButtonWithTitle:@"取消"];
            alert.tag = 1;
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"index ===== %d",(int)index);
    if(alertView.tag == 0){//删除当前正在进行的下载任务
        if (buttonIndex == 0) {
            
            //删除当前正在下载的任务
            Map *map = [_dataList objectAtIndex:index];
            NSLog(@"map.id ====== %@",map.mapId);
            
            map.isDownload = NO;
            map.isPause = NO;
            
            //删除任务
            [_dlManager deleteRequestTask:map.mapId];
            NSFileManager * fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:map.filePath error:nil];
            map.filePath = nil;
            [_listTableView reloadData];
        }
    }
    else{//删除已经下载好的任务
        if (buttonIndex == 0) {
            Map *map = [_downLoadList objectAtIndex:longPressIndex];
            [_mapDb deleteMap1WithMapId:[map.mapId intValue]];
            [_downLoadList removeObject:map];
            //删除下载
        
            NSFileManager * fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:map.filePath error:nil];
            map.filePath = nil;
            
            NSLog(@"map.ID ====== %@",map.mapId);
            int cuIndex = 0;
            for(int i=1;i<_dataList.count;i++){
                Map *map1 = [_dataList objectAtIndex:i-1];
                Map *map2 = [_dataList objectAtIndex:i];
                if([map1.mapId intValue]<[map.mapId intValue] && [map2.mapId intValue]>[map.mapId intValue]){
                    cuIndex = i;
                }
            }
            NSLog(@"cuIndex ======== %d",cuIndex);
            [_dataList insertObject:map atIndex:cuIndex];
            [_mapDb insertMapWithMapNum:cuIndex andMapImageStr:map.imageStr andMapTitle:map.titleStr andMapDescription:map.descriptionStr andMapSize:map.fileInitSize andMapId:[map.mapId intValue] andMapName:map.packageNameStr];
            
            [_listTableView reloadData];
        }
    }
}

#pragma mark ------------------------------------- 下载完成回调 -------------------------------------------
//下载完成
- (void)downloadFinish:(NSNotification *)notification {
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:nil];
    
    NSDictionary *infoDict = [notification userInfo];
    //判断下载是否成功
    NSString *success = [infoDict objectForKey:@"success"];
    //压缩文件路径
    NSString *filePath = [infoDict objectForKey:@"filePath"];
    //临时文件
    NSString *fileTempPath = [infoDict objectForKey:@"fileTempPath"];
    //key --- mapId
    NSString *key = [infoDict objectForKey:@"taskKey"];
    
    //获取map对象
    Map *map;
    for (Map *subMap in _dataList) {
        if ([subMap.mapId isEqualToString:key]) {
            map = subMap;
            break;
        }
    }
    map.filePath = filePath;
    
    if ([success isEqualToString:@"1"]) {//下载成功
        NSLog(@"%@ -------- 下载成功",key);
        
        map.isDownload = NO;
        map.isPause = NO;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:map.mapId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //把文件压缩
        [SSZipArchive unzipFileAtPath:fileTempPath toDestination:filePath];
        //删除临时文件
        [[NSFileManager defaultManager] removeItemAtPath:fileTempPath error:nil];
        
        //把下载好的数据插入到数据库中
        [_mapDb insertMap1WithMapImageStr:map.imageStr andMapTitle:map.titleStr andMapDescription:map.descriptionStr andMapSize:map.fileInitSize  andMapId:[map.mapId intValue] andMapName:map.packageNameStr andFilePath:map.filePath];
        [_downLoadList addObject:map];
        //[_mapDb selectALLMap1With:_downLoadList];
        //从数据库中删除
        [_dataList removeObject:map];
        [_mapDb deleteMapWithMapId:[map.mapId intValue]];
        [_listTableView reloadData];
        
    }else{//下载失败
        
        NSLog(@"下载失败");
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[map.row integerValue] inSection:[map.section integerValue]];
        DownLoadXibCell *cell = (DownLoadXibCell *)[self tableView:_listTableView cellForRowAtIndexPath:indexPath];
        
        cell.progressView.hidden = YES;
        cell.cancelBtn.hidden = YES;
        cell.fileSizeLabel.hidden =YES;
        cell.fileSizeLabel.text = [NSString stringWithFormat:@"%ld",(long)map.fileInitSize];
        cell.descriptionLabel.text = map.descriptionStr;
        [_listTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
