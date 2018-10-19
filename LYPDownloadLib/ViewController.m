//
//  ViewController.m
//  LYPDownloadLib
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "ViewController.h"
#import "LYPDownloader.h"
#import "LYPDownloadManager.h"

@interface ViewController ()

@property (nonatomic, strong) LYPDownloader *downloader;

@end

@implementation ViewController

-(LYPDownloader *)downloader{
    if (!_downloader) {
        _downloader = [[LYPDownloader alloc]init];
    }
    return _downloader;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    NSLog(@"%@",NSHomeDirectory());
}

- (IBAction)download:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/Sip44.dmg"];
//    [self.downloader downloadWithUrl:url];
//    [self.downloader downloadWithUrl:url messageBlock:^(long long totalSize, NSString * _Nonnull downloadPath) {
//        NSLog(@"%lld == %@",totalSize,downloadPath);
//    } progressBlock:^(float progress) {
//        NSLog(@"%f",progress);
//    } successBlock:^(NSString * _Nonnull downLoadedPath) {
//        NSLog(@"下载成功");
//    } faileBlock:^(NSString * _Nonnull errorMsg) {
//        NSLog(@"==%@",errorMsg);
//    }];
    [[LYPDownloadManager shareInstance]downloadWithUrl:url messageBlock:^(long long totalSize, NSString * _Nonnull downloadPath) {
        NSLog(@"%lld == %@",totalSize,downloadPath);
    } progressBlock:^(float progress) {
        NSLog(@"下载中%f",progress);
    } successBlock:^(NSString * _Nonnull downLoadedPath) {
        NSLog(@"下载成功");
    } faileBlock:^(NSString * _Nonnull errorMsg) {
        NSLog(@"下载失败==%@",errorMsg);
    }];
    
}
- (IBAction)pause:(id)sender {
    [self.downloader pause];
}
- (IBAction)resume:(id)sender {
    [self.downloader resume];
}
- (IBAction)cancleAndClean:(id)sender {
    [self.downloader cancelAndClean];
}

@end
