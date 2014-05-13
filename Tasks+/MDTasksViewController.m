//
//  MDTasksViewController.m
//  Tasks+
//
//  Created by Sven on 5/1/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDTasksViewController.h"

#import "MDTask.h"

static NSString * const kTasksCellReuseIdentifier = @"TasksCellReuseIdentifier";

@interface MDTasksViewController ()

//@property (nonatomic, strong) NSArray *tasks;

- (void)fetchTasksFromTaskList;

@end

@implementation MDTasksViewController

- (id)initWithStyle:(UITableViewStyle)style
{
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
    
    [self reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)reloadData {
    [self fetchTasksFromTaskList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Task Fetching

//- (GTLServiceTasks *)tasksService {
//    
//    if (!_tasksService) {
//        _tasksService = [[GTLServiceTasks alloc] init];
//        
//        // Have the service object set tickets to fetch consecutive pages
//        // of the feed so we do not need to manually fetch them
//        _tasksService.shouldFetchNextPages = YES;
//        
//        // Have the service object set tickets to retry temporary error conditions
//        // automatically
//        _tasksService.retryEnabled = YES;
//    }
//    return _tasksService;
//}

- (void)setTaskList:(GTLTasksTaskList *)taskList {
    _taskList = taskList;
    [self fetchTasksFromTaskList];
}

- (void)fetchTasksFromTaskList {
    if (_taskList) {
        GTLQueryTasks *query = [GTLQueryTasks queryForTasksListWithTasklist:_taskList.identifier];
        [self.tasksService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id tasks, NSError *error) {
            self.tasks = tasks;
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.tasks.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTasksCellReuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTasksCellReuseIdentifier];
    }
    
    GTLTasksTask *task = [self.tasks itemAtIndex:indexPath.row];
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


@end
