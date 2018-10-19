//
//  LYPDownloadManager.m
//  LYPDownloadLib
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "LYPDownloadManager.h"
#import "NSString+LYPMD5.h"

@interface LYPDownloadManager ()<NSCopying,NSMutableCopying>

@property (nonatomic, strong) NSMutableDictionary *downloadInfo;
@end

@implementation LYPDownloadManager

static LYPDownloadManager *downloaderManager;
+(instancetype)shareInstance{
    if (!downloaderManager) {
        downloaderManager = [[self alloc]init];
    }
    return downloaderManager;
}
-(id)copyWithZone:(NSZone *)zone{
    return downloaderManager;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!downloaderManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            downloaderManager = [super allocWithZone:zone];
        });
    }
    return downloaderManager;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return downloaderManager;
}
-(NSMutableDictionary *)downloadInfo{
    if (!_downloadInfo) {
        _downloadInfo = [[NSMutableDictionary alloc]init];
    }
    return _downloadInfo;
}

-(void)downloadWithUrl:(NSURL *)url messageBlock:(DownloadMessage)messageBlock progressBlock:(DownLoadProgressChange)progressBlock successBlock:(DownLoadSuccess)successBlock faileBlock:(DownLoadFailed)faileBlock{
    
//    先取下载器
    NSString *urlStr = [url.absoluteString md5Str];
    LYPDownloader *downloader = self.downloadInfo[urlStr];
    if (downloader == nil) {
        downloader = [[LYPDownloader alloc]init];
        self.downloadInfo[urlStr] = downloader;
    }
    __weak typeof(self) weakSelf = self;
    [downloader downloadWithUrl:url messageBlock:messageBlock progressBlock:progressBlock successBlock:^(NSString * _Nonnull downLoadedPath) {
        
        [weakSelf.downloadInfo removeObjectForKey:urlStr];
        if (successBlock) {
            successBlock(downLoadedPath);
        }
    } faileBlock:faileBlock];
    
}

-(void)pauseWithUrl:(NSURL *)url{
    NSString *urlStr = [url.absoluteString md5Str];
    LYPDownloader *downloader = self.downloadInfo[urlStr];
    [downloader pause];
}

-(void)pauseAll{
    [self.downloadInfo.allValues performSelector:@selector(pause) withObject:nil];
}

@end
