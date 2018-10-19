//
//  LYPDownloader.h
//  LYPDownloadLib
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,LYPDownloadState){
    LYPDownloadStatePause,//下载暂停
    LYPDownloadStateDowning,//正在下载
    LYPDownloadStateSuccess,// 下载成功
    LYPDownloadStateFailed //下载失败
};

typedef void(^DownloadStateChange)(LYPDownloadState state);
typedef void(^DownloadMessage) (long long totalSize,NSString *downloadPath);
typedef void(^DownLoadProgressChange) (float progress);
typedef void(^DownLoadSuccess)(NSString *downLoadedPath);
typedef void(^DownLoadFailed)(NSString *errorMsg);

@interface LYPDownloader : NSObject

@property (nonatomic, assign,readonly) LYPDownloadState state;
@property (nonatomic, copy) DownloadMessage messageBlock;
@property (nonatomic, copy) DownLoadFailed faileBlock;
@property (nonatomic, copy) DownLoadSuccess successBlock;
@property (nonatomic, copy) DownLoadProgressChange progressBlock;
@property (nonatomic, copy) DownloadStateChange stateChangeBlock;

//download url
-(void)downloadWithUrl:(NSURL *)url;
-(void)downloadWithUrl:(NSURL *)url messageBlock:(DownloadMessage)messageBlock progressBlock:(DownLoadProgressChange)progressBlock successBlock:(DownLoadSuccess)successBlock faileBlock:(DownLoadFailed)faileBlock;

-(void)cancel;
-(void)pause;
-(void)resume;
-(void)cancelAndClean;

@end

NS_ASSUME_NONNULL_END
