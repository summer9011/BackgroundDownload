//
//  TableViewController.h
//  BackgroundDownload
//
//  Created by 赵立波 on 15/3/3.
//  Copyright (c) 2015年 赵立波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController

-(void)insertNewObjectForFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
