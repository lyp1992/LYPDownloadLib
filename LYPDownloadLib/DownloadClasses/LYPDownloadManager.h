//
//  LYPDownloadManager.h
//  LYPDownloadLib
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYPDownloader.h"

NS_ASSUME_NONNULL_BEGIN

@interface LYPDownloadManager : NSObject

+(instancetype)shareInstance;

-(void)downloadWithUrl:(NSURL *)url messageBlock:(DownloadMessage)messageBlock progressBlock:(DownLoadProgressChange)progressBlock successBlock:(DownLoadSuccess)successBlock faileBlock:(DownLoadFailed)faileBlock;

-(void)pauseWithUrl:(NSURL *)url;
-(void)pauseAll;

@end

NS_ASSUME_NONNULL_END
