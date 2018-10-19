//
//  LYPFileTool.m
//  LYPDownloadLib
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "LYPFileTool.h"

@implementation LYPFileTool
+ (BOOL)createDirectoryIfNotExists:(NSString *)path{
    
    NSFileManager *fileManager =[ NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSError *error;
       [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)fileExistsAtPath:(NSString *)path{
    NSFileManager *fileManager= [ NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return NO;
    }
    return YES;
}

+ (long long)fileSizeAtPath:(NSString *)path{
//    判断文件在不在
    if (![self fileExistsAtPath:path]) {
        return 0;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *fileinfo = [manager attributesOfItemAtPath:path error:nil];
    return [fileinfo[NSFileSize] longLongValue];
}

+ (void)removeFileAtPath:(NSString *)path{
    
    if (![self fileExistsAtPath:path]) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
    
}
+(void)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath{
    if (![self fileExistsAtPath:fromPath]) {
        return;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager moveItemAtPath:fromPath toPath:toPath error:nil];
}

@end
