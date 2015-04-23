//
//  Download.m
//  XML
//
//  Created by LYD on 15/1/19.
//  Copyright (c) 2015年 lifangli. All rights reserved.
//

#import "Download.h"
#import "AppUtil.h"

@implementation Download{
    UIProgressView *_progressView;
    //文件夹路径
    NSString *_docPath;
    //文件路径
    NSString *_filePath;
    //文件临时路径
    NSString *_fileTempPath;

    //网络请求对象
    NSURL *_url;
    NSMutableURLRequest *_request;
    NSURLConnection *_connection;
    
    //写入文件对象
    NSFileHandle *_fileHandle;
    // 请求返回结果
    NSURLResponse *_downloadResponse;
    // 下载起始大小
    unsigned long long _downLoadStartBytes;
    // 已经下载的字节数
    unsigned long long _downLoadReceivedBytes;
    // 接收数据大小比例
    double _downLoadPercent;
    //进行中的block
    void (^_myBlock)(long long ,long long);
}

//开始下载任务
- (void)starRequestTask:(NSString *)urlStr andFile:(NSString *)fileName andUnderway:(void (^)(long long, long long))underwayBlock {
    //用于回调的block
    _myBlock = underwayBlock;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //存放的文件夹
    _docPath = [NSString stringWithFormat:@"%@/Map/",[AppUtil getDocumentPath]];
    //判断存储的文件夹是否存在，不存在就创建
    if (![fileManager fileExistsAtPath:_docPath]) {
        [fileManager createDirectoryAtPath:_docPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    _url = [NSURL URLWithString:urlStr];
    _request = [[NSMutableURLRequest alloc] initWithURL:_url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0];
    
    //设置压缩文件路径
    _filePath = [NSString stringWithFormat:@"%@%@",_docPath,fileName];
    //设置临时文件名
    _fileTempPath = [NSString stringWithFormat:@"%@temp%@",_docPath,fileName];
    NSLog(@"_fileTempPath ========= %@",_fileTempPath);
    //判断临时文件是否存在 --- 是否存在下载文件,如果有，就说明上次没有下载完成
    BOOL isHaveTempFile;
    if ([fileManager fileExistsAtPath:_fileTempPath]) {//如果存在
        //断点续传，需要从文件属性中获取已经下载的数据长度
        NSDictionary *fileInfoDict = [fileManager attributesOfItemAtPath:_fileTempPath error:nil];
        if (fileInfoDict) {//字典不为空
            //获取文件大小
            NSNumber *fileSize = [fileInfoDict objectForKey:NSFileSize];
            //设置本次下载起始大小
            _downLoadStartBytes = [fileSize unsignedLongLongValue];
            NSLog(@"已经下载文件大小 = %llu",_downLoadStartBytes);
        }
        isHaveTempFile = YES;
    }else{
        //如果没有，创建临时下载文件
        [fileManager createFileAtPath:_fileTempPath contents:nil attributes:nil];
        isHaveTempFile = NO;
    }
    
    // 如果要写文件，首先创建”文件写入对象“，目的是将来要追加数据
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_fileTempPath];
    // 如果有临时文件，需要继续下载
    if(isHaveTempFile)
    {
        // 断点续传需要给请求头中告诉服务器从多少大小开始下载。所以需要加入文件大小于RANGE中(%qu为lonlongvalue类型)
        [_request addValue:[NSString stringWithFormat:@"bytes=%qu-",_downLoadStartBytes] forHTTPHeaderField:@"RANGE"];
    }
    
    // 开始连接
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];

}

// 开始下载前，接到的服务器响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"~~接收连接响应~~");
    _downLoadReceivedBytes = _downLoadStartBytes;
    _downloadResponse = response;
    
    //回调
    if (_delegate && [_delegate respondsToSelector:@selector(downloadStar:)]) {
        [_delegate downloadStar:self];
    }
}

// 接受到数据时候响应(反复刷新)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"==接收数据中==");
    
    NSLog(@"需要下载大小 = %llu",[_downloadResponse expectedContentLength]);
    // 文件总大小 = 响应头中预期要接收的 + 已经接收的
    unsigned long long expectedLength = [_downloadResponse expectedContentLength]+_downLoadStartBytes;
    // 已接收的数据大小 = 之前接收的数据大小 + 当前接收的数据大小
    _downLoadReceivedBytes = _downLoadReceivedBytes + [data length];
    // 判断一下，如果总文件大小不是未知的
    if(expectedLength != NSURLResponseUnknownLength)
    {
        // 接收比例 = 已接收数据大小 / 需要接收数据大小
        _downLoadPercent = _downLoadReceivedBytes / (double)expectedLength;
        // 跳转到文件最后
        [_fileHandle seekToEndOfFile];
        // 将刚刚接收的数据写入到文件
        [_fileHandle writeData:data];
        NSLog(@"已下载:%f",_downLoadPercent*100);
        // 设置进度条进度
        _progressView.progress = _downLoadPercent;
        NSUserDefaults *myUserDefualts = [NSUserDefaults standardUserDefaults];
        
        //保存下载进度 ---- key
        [myUserDefualts setObject:[NSString stringWithFormat:@"%f",_downLoadPercent] forKey:_taskKey];
        [myUserDefualts synchronize];
        
        //回调
        _myBlock(_downLoadReceivedBytes, expectedLength);
        
        //回调
        if (_delegate && [_delegate respondsToSelector:@selector(downloadProgresing:)]) {
            [_delegate downloadProgresing:self];
        }
    }
}

//下载失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_fileHandle closeFile];
    NSLog(@"下载失败！");
    if (_delegate && [_delegate respondsToSelector:@selector(downloadDidFinish:andIsSuccess:)]) {
        [_delegate downloadDidFinish:self andIsSuccess:NO];
    }
}

//下载完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_fileHandle closeFile];
    NSLog(@"下载完成!");
    if (_delegate && [_delegate respondsToSelector:@selector(downloadDidFinish:andIsSuccess:)]) {
        [_delegate downloadDidFinish:self andIsSuccess:YES];
    }
}

//暂停下载任务
- (void)stopRequestTask{
    [_connection cancel];
    //[_fileHandle closeFile];
}

//删除任务
- (void)deleteRequestTask{
    [_connection cancel];
    [_fileHandle closeFile];
    BOOL isSuccess = [[NSFileManager defaultManager] removeItemAtPath:_fileTempPath error:nil];
    if (isSuccess) {
        NSLog(@"----------------------------删除任务成功----------------------------");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:_taskKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        NSLog(@"----------------------------删除任务失败----------------------------");
    }
}

//返回临时文件路径
- (NSString *)fileTempPath{
    return _fileTempPath;
}

//返回压缩文件路径
- (NSString *)filePath{
    return _filePath;
}

@end















