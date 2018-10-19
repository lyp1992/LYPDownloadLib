//
//  LYPFileTool.h
//  LYPDownloadLib
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYPFileTool : NSObject

+ (BOOL)createDirectoryIfNotExists:(NSString *)path;
+ (BOOL)fileExistsAtPath:(NSString *)path;
+ (long long)fileSizeAtPath:(NSString *)path;
+ (void)removeFileAtPath:(NSString *)path;

+ (void)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
@end

NS_ASSUME_NONNULL_END
