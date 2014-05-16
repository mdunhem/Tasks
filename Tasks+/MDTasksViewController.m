//
//  MDTasksViewController.m
//  Tasks+
//
//  Created by Sven on 5/1/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDTasksViewController.h"
#import "MDTasksManager.h"
#import "MDAppDelegate.h"

static NSString * const kTasksCellReuseIdentifier = @"TasksCellReuseIdentifier";

@interface MDTasksViewController () <MDManagerDelegate>

//@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, strong) MDTasksManager *manager;

//- (void)fetchTasksFromTaskList;

@end

@implementation MDTasksViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Tasks";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *color = [UIColor colorWithRed:42/255.0f green:138/255.0f blue:157/255.0f alpha:1.0f];
//    UIColor *color = [UIColor colorWithRed:120/255.0f green:143/255.0f blue:141/255.0f alpha:1.0f];
    [self.navigationController.navigationBar setBarTintColor:color];
    [self.navigationController.navigationBar setTranslucent:NO];
    
//    [self.manager fetch];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refresh Tasks List"]];
    [self setRefreshControl:refreshControl];
    
    // Attributed title offset bug fix...
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
        [self.refreshControl endRefreshing];
    });
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)refresh:(id)sender {
    [self.manager fetch];
}

- (MDTasksManager *)manager {
    if (!_manager) {
        _manager = [[MDTasksManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}

- (void)setAuth:(GTMOAuth2Authentication *)auth {
    _auth = auth;
    [self.manager setAuth:auth];
    [self.manager fetch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTaskList:(GTLTasksTaskList *)taskList {
    _taskList = taskList;
    [self.manager setTaskList:taskList];
    [self.manager fetch];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_manager count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTasksCellReuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTasksCellReuseIdentifier];
    }
    
    GTLTasksTask *task = [_manager taskAtIndex:indexPath.row];
    cell.textLabel.text = task.title;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - MDManagerDelegate Protocol Methods

- (void)managerDidRefresh:(MDManager *)manager {
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
        [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refresh List"]];
    }
    [self.tableView reloadData];
}

- (void)manager:(MDManager *)manager didAddItem:(id)item atIndexPath:(NSIndexPath *)indexPath {
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)manager:(MDManager *)manager didUpdateItem:(id)item atIndexPath:(NSIndexPath *)indexPath {
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)manager:(MDManager *)manager didDeleteItem:(id)item atIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

@end
