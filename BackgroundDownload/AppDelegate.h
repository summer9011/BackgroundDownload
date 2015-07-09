//
//  AppDelegate.h
//  BackgroundDownload
//
//  Created by 赵立波 on 15/3/3.
//  Copyright (c) 2015年 赵立波. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadDelegate <NSObject>

@optional

-(void)DownloadURLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error;

-(void)DownloadURLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session;

-(void)DownloadURLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;

-(void)DownloadURLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

-(void)DownloadURLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes;

-(void)DownloadURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler;

-(void)DownloadURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate,NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong) id<DownloadDelegate> downloadDelegate;

@property (nonatomic,strong) NSURLSession *session1;
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask1;

@property (copy) void (^backgroundSessionCompletionHandler)();

@end

