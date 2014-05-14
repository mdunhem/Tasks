//
//  MDMenuViewController.m
//  Tasks+
//
//  Created by Sven on 5/1/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDMenuViewController.h"
#import "UIViewController+MMDrawerController.h"

#import "GTLTasks.h"
#import "GTMOAuth2ViewControllerTouch.h"

// Constants used for OAuth 2.0 authorization.
static NSString *const kKeychainItemName = @"Tasks+: iOS Google Tasks";
static NSString *const kClientId = @"815911753448-sp0tglbdk2gm5b32tob5p9421qi4orib.apps.googleusercontent.com";
static NSString *const kClientSecret = @"5qzXC53TeoLWy3H3qoOBRFtk";

static NSString * const kTaskListCellReuseIdentifier = @"TaskListCellReuseIdentifier";

@interface MDMenuViewController ()

@property (nonatomic, strong) NSArray *taskList;
@property (nonatomic, strong) MDTasksViewController *tasksViewController;
@property BOOL isAuthorized;

@property (nonatomic, strong) MDTasksManager *manager;

@property (nonatomic) GTLServiceTasks *tasksService;
@property (nonatomic) GTLTasksTaskLists *taskLists;
@property (nonatomic) GTLTasksTasks *tasks;
@property (nonatomic) GTLServiceTicket *tasksTicket;

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;
- (void)presentLoginScreen;
- (void)fetchTaskLists;
- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth;

- (void)createNewTaskList:(id)sender;

- (void)editTaskList:(GTLTasksTaskList *)taskList;

- (void)addNewTaskListWithName:(NSString *)taskListName;
- (void)deleteTaskList:(GTLTasksTaskList *)taskList;


@end

@implementation MDMenuViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.title = @"Task Lists";
    }
    return self;
}

- (MDTasksManager *)manager {
    if (!_manager) {
        _manager = [[MDTasksManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}

- (MDTasksViewController *)tasksViewController {
    if (!_tasksViewController) {
        _tasksViewController = [[MDTasksViewController alloc] initWithStyle:UITableViewStylePlain];
        [_tasksViewController setTasksService:self.tasksService];
    }
    return _tasksViewController;
}

- (UIViewController *)getTasksViewController {
    return [[UINavigationController alloc] initWithRootViewController:self.tasksViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Temp: Only so I can make sure the login screen works properly
    //[GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kClientId clientSecret:kClientSecret];
    
    if ([auth canAuthorize]) {
        [self isAuthorizedWithAuthentication:auth];
    } else {
        [self presentLoginScreen];
    }
    
    UIBarButtonItem *createTaskListButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewTaskList:)];
    self.navigationItem.leftBarButtonItem = createTaskListButton;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
//    NSError *error;
//    if (![[self manager] fetchTaskLists:error]) {
//        // Update to handle the error appropriately.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        exit(-1);  // Fail
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.taskLists.items.count;
    NSInteger count = [_manager numberOfTaskLists];
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTaskListCellReuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTaskListCellReuseIdentifier];
    }
    
    GTLTasksTaskList *list = [_manager taskListAtIndex:indexPath.row]; //[self.taskLists itemAtIndex:indexPath.row];
    
    cell.textLabel.text = list.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        [self editTaskList:[self.taskLists itemAtIndex:indexPath.row]];
    } else {
        [self.tasksViewController setTaskList:[self.taskLists itemAtIndex:indexPath.row]];
        [self.drawerController closeDrawerAnimated:YES completion:nil];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GTLTasksTaskList *list = (GTLTasksTaskList *)[[[self taskLists] items] objectAtIndex:indexPath.row];
        [self deleteTaskList:list];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)createNewTaskList:(id)sender {
    [self editTaskList:nil];
}

- (void)editTaskList:(GTLTasksTaskList *)taskList {
    MDEditTaskListViewController *editTaskListViewController = [[MDEditTaskListViewController alloc] initWithStyle:UITableViewStyleGrouped taskList:taskList];
    editTaskListViewController.delegate = self;
    
    UINavigationController *addTaskListNavController = [[UINavigationController alloc] initWithRootViewController:editTaskListViewController];
    
    [self presentViewController:addTaskListNavController animated:YES completion:nil];
}

- (GTLServiceTasks *)tasksService {
    
    if (!_tasksService) {
        _tasksService = [[GTLServiceTasks alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them
        _tasksService.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        _tasksService.retryEnabled = YES;
    }
    return _tasksService;
}

- (void)fetchTaskLists {
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsList];
    _tasksTicket = [[self tasksService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id taskLists, NSError *error) {
        self.taskLists = taskLists;
//        self.taskListsFetchError = error;
        self.tasksTicket = nil;
        [[self tableView] reloadData];
        // TODO: Change this so that it does not always load the first list
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.tasksViewController setTaskList:[self.taskLists itemAtIndex:0]];
    }];
}

- (void)presentLoginScreen {
    GTMOAuth2ViewControllerTouch *loginViewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeTasks clientID:kClientId clientSecret:kClientSecret keychainItemName:kKeychainItemName delegate:self finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    loginViewController.title = @"Sign In";
    UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [[self drawerController] presentViewController:loginNavController animated:YES completion:nil];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    [[self drawerController] dismissViewControllerAnimated:YES completion:^(void) {
        if (error == nil) {
            [self isAuthorizedWithAuthentication:auth];
        }
    }];
}

- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    self.isAuthorized = YES;
    [self.manager setAuth:auth];
    self.tasksService.authorizer = auth;
    NSError *error = nil;
    [self.manager fetchTaskLists:error];
//    [self fetchTaskLists];
}

- (void)MDEditTaskListViewController:(MDEditTaskListViewController *)addTaskListViewController didEndWithNewTaskListName:(NSString *)taskListName {
    [self addNewTaskListWithName:taskListName];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)MDEditTaskListViewController:(MDEditTaskListViewController *)editTaskListViewController didEndWithUpdatedTaskList:(GTLTasksTaskList *)taskList {
    if (taskList != nil) {
        BOOL isFound = NO;
        for (GTLTasksTaskList *list in self.taskLists) {
            if ([list.identifier isEqualToString:taskList.identifier]) {
                [self renameTaskList:taskList];
//                if (![list.title isEqualToString:taskList.title]) {
//                    
//                }
                isFound = YES;
            }
        }
        if (!isFound) {
            [self addTaskList:taskList];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Task List Management

- (void)addNewTaskListWithName:(NSString *)taskListName {
    if (taskListName.length) {
        GTLTasksTaskList *tasklist = [GTLTasksTaskList object];
        tasklist.title = taskListName;
        
        GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsInsertWithObject:tasklist];
        
        _tasksTicket = [self.tasksService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
            _tasksTicket = nil;
            
            if (error == nil) {
                [self fetchTaskLists];
            } else {
                NSLog(@"Error: %@", error);
            }
        }];
    }
}

- (void)addTaskList:(GTLTasksTaskList *)taskList {
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsInsertWithObject:taskList];
    
    _tasksTicket = [self.tasksService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        _tasksTicket = nil;
        
        if (error == nil) {
            [self fetchTaskLists];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)renameTaskList:(GTLTasksTaskList *)taskList {
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsPatchWithObject:taskList tasklist:taskList.identifier];
    
    _tasksTicket = [self.tasksService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        _tasksTicket = nil;
        
        if (error == nil) {
            [self fetchTaskLists];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

//- (void)renameSelectedTaskList {
//    NSString *title = [taskListNameField_ stringValue];
//    if ([title length] > 0) {
//        // Rename the selected task list
//        
//        // Rather than update the object with a complete replacement, we'll make
//        // a patch object containing just the changed title
//        GTLTasksTaskList *patchObject = [GTLTasksTaskList object];
//        patchObject.title = title;
//        
//        GTLTasksTaskList *selectedTaskList = [self selectedTaskList];
//        
//        GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsPatchWithObject:patchObject
//                                                                      tasklist:selectedTaskList.identifier];
//        GTLServiceTasks *service = self.tasksService;
//        self.editTaskListTicket = [service executeQuery:query
//                                      completionHandler:^(GTLServiceTicket *ticket,
//                                                          id item, NSError *error) {
//                                          // callback
//                                          self.editTaskListTicket = nil;
//                                          GTLTasksTaskList *tasklist = item;
//                                          
//                                          if (error == nil) {
//                                              [self displayAlert:@"Task List Updated"
//                                                          format:@"Updated task list \"%@\"", tasklist.title];
//                                              [self fetchTaskLists];
//                                              [taskListNameField_ setStringValue:@""];
//                                          } else {
//                                              [self displayAlert:@"Error"
//                                                          format:@"%@", error];
//                                              [self updateUI];
//                                          }
//                                      }];
//        [self updateUI];
//    }
//}

- (void)deleteTaskList:(GTLTasksTaskList *)taskList {
    
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsDeleteWithTasklist:taskList.identifier];
    
    _tasksTicket = [self.tasksService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        _tasksTicket = nil;
        
        if (error == nil) {
            [self fetchTaskLists];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

#pragma mark - MDTaskManagerDelegate Protocol Methods

- (void)managerWillChangeContent:(MDTasksManager *)manager {
    
}

- (void)managerDidChangeContent:(MDTasksManager *)manager {
    [self.tableView reloadData];
}

@end
