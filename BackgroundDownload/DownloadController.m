//
//  DownloadController.m
//  BackgroundDownload
//
//  Created by 赵立波 on 15/3/3.
//  Copyright (c) 2015年 赵立波. All rights reserved.
//

#import "DownloadController.h"

#import "AppDelegate.h"
#import "ZipArchive.h"

@interface DownloadController () <DownloadDelegate>

@property (nonatomic,strong) AppDelegate *dele;

//下载任务1
@property (weak, nonatomic) IBOutlet UIProgressView *progress1;
@property (weak, nonatomic) IBOutlet UILabel *degree1;
@property (weak, nonatomic) IBOutlet UIButton *download1;
@property (weak, nonatomic) IBOutlet UILabel *taskFromLabel;
@property (weak, nonatomic) IBOutlet UITextView *downloadDir;

@property (nonatomic,strong) NSTimer *timer;

@end

//瞻岐赛道
static NSString *DownloadURLString1 = @"http://www.youwandao.com/uploads/package/61.zip";


@implementation DownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dele=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.dele.downloadDelegate=self;
    
    self.dele.session1=[self backgroundSession:@"track1"];
    
    NSString *partPath=@"Library/Private Documents/Tmp1";
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:partPath]])
    {
        [fileManager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:partPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showDownloadDir) userInfo:nil repeats:YES];
}

-(void)showDownloadDir {
    self.downloadDir.text=@"";
    NSMutableString *contentStr=[NSMutableString string];
    
    //下载文件夹中的状态
    NSString *sessionDownloadPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/com.apple.nsurlsessiond/Downloads/com.tripbe.BackgroundDownload"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *contentArr=[fileManager contentsOfDirectoryAtPath:sessionDownloadPath error:nil];
    
    [contentStr appendString:[NSString stringWithFormat:@"下载文件夹 %@",contentArr]];
    
    //临时文件夹中的状态
    NSString *tempPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents/Tmp1"];
    NSArray *tempArr=[fileManager contentsOfDirectoryAtPath:tempPath error:nil];
    
    [contentStr appendString:[NSString stringWithFormat:@"\n临时文件夹 %@",tempArr]];
    
    //已下载文件夹的状态
    NSString *downPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *downArr=[fileManager contentsOfDirectoryAtPath:downPath error:nil];
    
    [contentStr appendString:[NSString stringWithFormat:@"\n下载文件夹 %@",downArr]];
    
    //tmp文件夹
    NSArray *tmpArr=[fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    
    [contentStr appendString:[NSString stringWithFormat:@"\ntmp文件夹 %@",tmpArr]];
    
    self.downloadDir.text=[NSString stringWithFormat:@"%@",contentStr];
}

- (IBAction)startDownload1:(id)sender {
    NSString *partPath=@"Library/Private Documents/Tmp1";
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:partPath]]){
        [fileManager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:partPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *tmpPath=[[NSHomeDirectory() stringByAppendingPathComponent:partPath] stringByAppendingPathComponent:self.dele.session1.configuration.identifier];
    
    if ([fileManager fileExistsAtPath:tmpPath]) {
        self.taskFromLabel.text=@"从临时文件开启下载";
        
        NSData *resumeData=[NSData dataWithContentsOfFile:tmpPath];
        
        //从原有数据中开启下载
        self.dele.downloadTask1=[self.dele.session1 downloadTaskWithResumeData:resumeData];
        [self.dele.downloadTask1 resume];
        
    }else{
        self.taskFromLabel.text=@"开启新的下载";
        
        //开启新的下载
        NSURL *downloadURL = [NSURL URLWithString:DownloadURLString1];
        NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
        self.dele.downloadTask1=[self.dele.session1 downloadTaskWithRequest:request];
        [self.dele.downloadTask1 resume];
        
        NSString *downPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"61.zip"];
        [fileManager removeItemAtPath:downPath error:nil];
    }
}

- (IBAction)stopDownload1:(id)sender {
    self.taskFromLabel.text=@"暂停";
    
    [self.dele.downloadTask1 cancelByProducingResumeData:^(NSData *resumeData) {
        //
    }];
}

-(NSURLSession *)backgroundSession:(NSString *)downloadName {
    //初始化一个后台任务session
    NSURLSession *session;
    NSString *Identifier=[NSString stringWithFormat:@"com.tripbe.BackgroundDownload.%@",downloadName];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:Identifier];
    //允许系统为任务分配进行性能优化，只有当设备有足够电量时，设备才通过Wifi进行数据传输。如果电量低，或者只仅有一个蜂窝连接，传输任务是不会运行
    configuration.discretionary=YES;
    session = [NSURLSession sessionWithConfiguration:configuration delegate:self.dele delegateQueue:nil];
    
    return session;
}

#pragma mark - DownloadDelegate

-(void)DownloadURLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"%lld",fileOffset);
}

-(void)DownloadURLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"All tasks are finished");
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.backgroundSessionCompletionHandler) {
        //执行回调代码块
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
}

-(void)DownloadURLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    if (downloadTask == self.dele.downloadTask1) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsDirectory = [URLs objectAtIndex:0];
        NSURL *originalURL = [[downloadTask originalRequest] URL];
        NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
        NSError *errorCopy;
        
        //先删除原文件夹中的文件
        [fileManager removeItemAtURL:destinationURL error:NULL];
        
        //将已下载好的临时文件移动到目标文件夹
        BOOL success = [fileManager copyItemAtURL:location toURL:destinationURL error:&errorCopy];
        
        if (success) {
            NSLog(@"移动成功");
            
            //移动成功后解压
            
            NSString *partPath=@"Library/Private Documents";
            
            NSFileManager *fileManager=[NSFileManager defaultManager];
            if(![fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:partPath]])
            {
                [fileManager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:partPath] withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *unZipTo=[NSHomeDirectory() stringByAppendingPathComponent:partPath];
            
            
            NSString *unzipDocumentsDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *unzipDestination=[unzipDocumentsDirectory stringByAppendingPathComponent:[originalURL lastPathComponent]];
            
            ZipArchive *zip=[[ZipArchive alloc] init];
            BOOL isUnzipOpen=[zip UnzipOpenFile:unzipDestination];
            
            if (isUnzipOpen) {
                BOOL result=[zip UnzipFileTo:unZipTo overWrite:YES];
                if (result) {
                    NSLog(@"解压成功");
                    
                }else{
                    NSLog(@"解压失败");
                }
                
                [fileManager removeItemAtURL:destinationURL error:NULL];
            }
            [zip UnzipCloseFile];
            
        } else {
            NSLog(@"移动临时文件失败: %@", [errorCopy localizedDescription]);
        }
    }
}

-(void)DownloadURLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (downloadTask == self.dele.downloadTask1) {
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progress1.progress = progress;
            self.degree1.text=[NSString stringWithFormat:@"%.2f%%",progress*100];
        });
    }
}

-(void)DownloadURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (task == self.dele.downloadTask1) {
        if (error == nil) {
            NSLog(@"下载完成");
            
            NSString *partPath=@"Library/Private Documents/Tmp1";
            NSFileManager *fileManager=[NSFileManager defaultManager];
            NSString *tmpPath=[[NSHomeDirectory() stringByAppendingPathComponent:partPath] stringByAppendingPathComponent:session.configuration.identifier];
            
            //先删除原来的文件
            [fileManager removeItemAtPath:tmpPath error:nil];
            
        } else {
            NSLog(@"下载失败,保存临时数据");
            
            if (error.userInfo[@"NSURLSessionDownloadTaskResumeData"]) {
                //保存resumeData
                NSData *tmpData=error.userInfo[@"NSURLSessionDownloadTaskResumeData"];
                NSString *partPath=@"Library/Private Documents/Tmp1";
                
                NSFileManager *fileManager=[NSFileManager defaultManager];
                if(![fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:partPath]])
                {
                    [fileManager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:partPath] withIntermediateDirectories:YES attributes:nil error:nil];
                }
                
                NSString *tmpPath=[[NSHomeDirectory() stringByAppendingPathComponent:partPath] stringByAppendingPathComponent:session.configuration.identifier];
                
                //先删除原来的文件
                [fileManager removeItemAtPath:tmpPath error:nil];
                //再保存文件
                [fileManager createFileAtPath:tmpPath contents:tmpData attributes:nil];
            }
            
        }
        
        double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progress1.progress = progress;
            self.degree1.text=[NSString stringWithFormat:@"%.2f%%",progress*100];
        });
    }
}

@end
