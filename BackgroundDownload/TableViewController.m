//
//  TableViewController.m
//  BackgroundDownload
//
//  Created by 赵立波 on 15/3/3.
//  Copyright (c) 2015年 赵立波. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@property (nonatomic) NSMutableArray *objects;
@property (nonatomic) NSArray *possibleTableData;
@property (nonatomic) int numberOfnewPosts;
@property (nonatomic) UIRefreshControl *refreshControl;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.objects=[NSMutableArray array];
    
    self.possibleTableData = [NSArray arrayWithObjects:@"Spicy garlic Lime Chicken",@"Apple Crisp II",@"Eggplant Parmesan II",@"Pumpkin Ginger Cupcakes",@"Easy Lasagna", @"Puttanesca", @"Alfredo Sauce", nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(insertNewObject:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)insertNewObject:(id)sender {
    self.numberOfnewPosts = [self getRandomNumberBetween:0 to:4];
    NSLog(@"%d new fetched objects",self.numberOfnewPosts);
    
    for(int i = 0; i < self.numberOfnewPosts; i++){
        int addPost = [self getRandomNumberBetween:0 to:(int)([self.possibleTableData count]-1)];
        [self.objects addObject:[self.possibleTableData objectAtIndex:addPost]];
    }
    [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

-(void)insertNewObjectForFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Update the tableview.");
    
    self.numberOfnewPosts = [self getRandomNumberBetween:0 to:4];
    NSLog(@"%d new fetched objects",self.numberOfnewPosts);
    
    for(int i = 0; i < self.numberOfnewPosts; i++){
        int addPost = [self getRandomNumberBetween:0 to:(int)([self.possibleTableData count]-1)];
        [self.objects addObject:[self.possibleTableData objectAtIndex:addPost]];
    }
    
    [self.tableView reloadData];
    
    /*
     At the end of the fetch, invoke the completion handler.
     */
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.objects[indexPath.row];
    if(indexPath.row < self.numberOfnewPosts){
        cell.backgroundColor = [UIColor yellowColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

@end
