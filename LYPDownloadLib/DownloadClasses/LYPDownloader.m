//
//  LYPDownloader.m
//  LYPDownloadLib
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "LYPDownloader.h"
#import "LYPFileTool.h"

#define kCache  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@interface LYPDownloader ()<NSURLSessionDataDelegate,NSURLSessionDelegate>
{
    long long _fileTmpSize;
    long long _totalSize;
}
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *downloadedFilePath;
@property (nonatomic, copy) NSString *downloadingFilePath;
@property (nonatomic, copy) NSString *dowloadedPath;
@property (nonatomic, copy) NSString *downloadingPath;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@end

@implementation LYPDownloader

-(void)downloadWithUrl:(NSURL *)url messageBlock:(DownloadMessage)messageBlock progressBlock:(DownLoadProgressChange)progressBlock successBlock:(DownLoadSuccess)successBlock faileBlock:(DownLoadFailed)faileBlock{
    self.messageBlock = messageBlock;
    self.progressBlock = progressBlock;
    self.successBlock = successBlock;
    self.faileBlock = faileBlock;
    [self downloadWithUrl:url];
}

-(void)downloadWithUrl:(NSURL *)url{
    
    //    下载
    //    0.存储机制
    //   下载中 cache/download/downloading/url.lastCompent
    //    下载完成 cache/download/downloaded/url.lastCompent
    
    self.downloadingFilePath = [self.downloadingPath stringByAppendingPathComponent:url.lastPathComponent];
    self.downloadedFilePath = [self.dowloadedPath stringByAppendingPathComponent:url.lastPathComponent];
    
//    容错，判断s任务是否已经存在
    if ([url isEqual:self.task.originalRequest.URL]) {
        if (self.state == LYPDownloadStatePause) {
            [self resume];
            return;
        }
        if (self.state == LYPDownloadStateDowning) {
            return;
        }
        if (self.state == LYPDownloadStateSuccess) {
            if (self.successBlock) {
                self.successBlock(self.downloadedFilePath);
            }
            return;
        }
    }
//   1. 判断有没有下载完成
//    1.1 通过一些特殊的记录信息，下载完成l和临时缓存路径分离
//    1.2  记录那些是已经下载完成的，做个特殊标记
    if ([LYPFileTool fileExistsAtPath:self.downloadedFilePath]) {
        NSLog(@"当前d文件下载完成");
        if (self.successBlock) {
            self.successBlock(self.downloadedFilePath);
        }
        return;
    }
    
//    2. 判断是否有缓存
//    2.1 本地没有缓存，从0开始下载
    if (![LYPFileTool fileExistsAtPath:self.downloadingFilePath]) {
        [self downloadWithUrl:url offset:_fileTmpSize];
        return;
    }
    
    [self cancel];
//    2.2 本地有缓存ls，文件总大小rs
    _fileTmpSize = [LYPFileTool fileSizeAtPath:self.downloadingFilePath];
    [self downloadWithUrl:url offset:_fileTmpSize];

    
}

-(void)downloadWithUrl:(NSURL *)url offset:(long long)offset{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [urlRequest setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    self.task = [self.session dataTaskWithRequest:urlRequest];
    [self resume];
}

-(void)cancel{
    // 取消所有的请求, 并且会销毁资源
    [self.session invalidateAndCancel];
    self.session = nil;
}
// 继续了几次, 暂停几次, 才能暂停
// 通过状态
-(void)pause{
    if (self.state == LYPDownloadStateDowning) {
        [self.task suspend];
        self.state = LYPDownloadStatePause;
    }
}
// 暂停了几次, 就得继续几次, 才能继续
-(void)resume{
    if ((self.task && self.state == LYPDownloadStatePause) || self.state == LYPDownloadStateFailed) {
        [self.task resume];
        self.state = LYPDownloadStateDowning;
    }
}
-(void)cancelAndClean{
    [self cancel];
    [LYPFileTool removeFileAtPath:self.downloadingFilePath];
}

#pragma mark NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    NSLog(@"%@",response);
//    总大小
    NSString *rangeStr = response.allHeaderFields[@"Content-Range"];
    _totalSize = [[[rangeStr componentsSeparatedByString:@"/"]lastObject] longLongValue];
    //    2.2.1 ls < rs 从range 从ls开始下载
    //    2.2.2 ls = rs 下载完成，将文件挪动到downloaded文件夹
    //    2.2.3 ls > rs 文件有误，删除重新下载
    if (_fileTmpSize == _totalSize) {
//        大小相等，不一定代表文件完整，正确
//        验证文件的完整行 ->移除操作
        NSLog(@"下载完成，执行移除操作");
        [LYPFileTool moveFileFromPath:self.downloadingFilePath toPath:self.downloadedFilePath];
        completionHandler(NSURLSessionResponseCancel);
        if (self.successBlock) {
            self.successBlock(self.downloadedFilePath);
        }
        return;
    }
    
    if (_fileTmpSize > _totalSize) {
//        执行移除操作
        [LYPFileTool removeFileAtPath:self.downloadingFilePath];
        completionHandler(NSURLSessionResponseCancel);
        [self downloadWithUrl:response.URL];
        
        return;
    }
    
    if (self.messageBlock) {
        self.messageBlock(_totalSize, self.downloadingFilePath);
    }
//    NSLog(@"继续接受数据");
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downloadingFilePath append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    NSLog(@"在接受数据");
    _fileTmpSize += data.length;
    if (self.progressBlock) {
        self.progressBlock(1.0 * _fileTmpSize/_totalSize);
    }
    [self.outputStream write:data.bytes maxLength:data.length];
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
//    比对完整性
    if (!error) {
        if (_fileTmpSize == _totalSize) {
            [LYPFileTool moveFileFromPath:self.downloadingFilePath toPath:self.downloadedFilePath];
            self.state = LYPDownloadStateSuccess;
            if (self.successBlock) {
                self.successBlock(self.downloadedFilePath);
            }
        }
    }else{
        self.state = LYPDownloadStateFailed;
        if (self.faileBlock) {
            self.faileBlock(error.localizedDescription);
        }
    }
}


#pragma mark -- settter
-(NSURLSession *)session{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    }
    return _session;
}
-(NSString *)dowloadedPath{
    NSString *filePath = [kCache stringByAppendingPathComponent:@"download/downloaded"];
    BOOL result = [LYPFileTool createDirectoryIfNotExists:filePath];
    if (result) {
        return filePath;
    }
    return @"";
}
-(NSString *)downloadingPath{
    NSString *path = [kCache stringByAppendingPathComponent:@"download/downloading"];
    BOOL result = [LYPFileTool createDirectoryIfNotExists:path];
    if (result) {
        return path;
    }
    return  @"";
}
-(void)setState:(LYPDownloadState)state{
    _state = state;
    if (self.stateChangeBlock) {
        self.stateChangeBlock(state);
    }
}
@end
