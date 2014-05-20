//
//  MDMenuViewController.m
//  Tasks+
//
//  Created by Sven on 5/1/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDMenuViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MDAppDelegate.h"

#import "GTLTasks.h"
#import "GTMOAuth2ViewControllerTouch.h"

// Constants used for OAuth 2.0 authorization.
static NSString * const kKeychainItemName = @"Tasks+: iOS Google Tasks";
static NSString * const kClientId = @"815911753448-sp0tglbdk2gm5b32tob5p9421qi4orib.apps.googleusercontent.com";
static NSString * const kClientSecret = @"5qzXC53TeoLWy3H3qoOBRFtk";

static NSString * const kTaskListCellReuseIdentifier = @"TaskListCellReuseIdentifier";

@interface MDMenuViewController ()

@property (nonatomic, strong) NSArray *taskList;
@property (nonatomic, strong) MDTasksViewController *tasksViewController;
@property BOOL isAuthorized;

@property (nonatomic, strong) MDTaskListsManager *manager;

//@property (nonatomic) GTLServiceTasks *tasksService;
//@property (nonatomic) GTLTasksTaskLists *taskLists;
//@property (nonatomic) GTLTasksTasks *tasks;
//@property (nonatomic) GTLServiceTicket *tasksTicket;

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error;
- (void)presentLoginScreen;
- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth;

- (void)refresh:(id)sender;
- (void)createNewTaskList:(id)sender;

- (void)editTaskList:(GTLTasksTaskList *)taskList;

@end

@implementation MDMenuViewController

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.title = @"Task Lists";
    }
    return self;
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
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refresh List"]];
    [self setRefreshControl:refreshControl];
    
    // Attributed title offset bug fix...
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
        [self.refreshControl endRefreshing];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Accessors

- (MDTaskListsManager *)manager {
    if (!_manager) {
        _manager = [[MDTaskListsManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}

- (MDTasksViewController *)tasksViewController {
    if (!_tasksViewController) {
        _tasksViewController = [[MDTasksViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    return _tasksViewController;
}

#pragma mark - Actions

- (void)refresh:(id)sender {
    [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Loading"]];
    [self.manager fetch];
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

- (void)addTaskList:(GTLTasksTaskList *)taskList {
    [self.manager addNewTaskList:taskList];
}

#pragma mark - OAuth2

- (void)presentLoginScreen {
    GTMOAuth2ViewControllerTouch *loginViewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeTasks clientID:kClientId clientSecret:kClientSecret keychainItemName:kKeychainItemName delegate:self finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    loginViewController.title = @"Sign In";
    UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [[self drawerController] presentViewController:loginNavController animated:YES completion:nil];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    [[self drawerController] dismissViewControllerAnimated:YES completion:^(void) {
        if (error == nil) {
            [self isAuthorizedWithAuthentication:auth];
        }
    }];
}

- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    [self.tasksViewController setAuth:auth];
    
    self.isAuthorized = YES;
    [self.manager setAuth:auth];
    [self.manager fetch];
}

#pragma mark - Public

- (UIViewController *)getTasksViewController {
    return [[UINavigationController alloc] initWithRootViewController:self.tasksViewController];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.manager count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTaskListCellReuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTaskListCellReuseIdentifier];
    }
    
    GTLTasksTaskList *list = [self.manager taskListAtIndex:indexPath.row];
    
    cell.textLabel.text = list.title;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        [self editTaskList:[self.manager taskListAtIndex:indexPath.row]];
    } else {
        [self.tasksViewController setTaskList:[self.manager taskListAtIndex:indexPath.row]];
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
        [self.manager deleteTaskList:[self.manager taskListAtIndex:indexPath.row]];
        [tableView setEditing:NO];
        [self setEditing:NO];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - MDEditTaskListViewControllerDelegate

- (void)MDEditTaskListViewController:(MDEditTaskListViewController *)editTaskListViewController didEndWithUpdatedTaskList:(GTLTasksTaskList *)taskList {
    if (taskList != nil) {
        if ([self.manager containsTaskList:taskList]) {
            [self.manager editTaskList:taskList];
        } else {
            [self.manager addNewTaskList:taskList];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MDManagerDelegate

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
