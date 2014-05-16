//
//  MDTasksViewController.h
//  Tasks+
//
//  Created by Sven on 5/1/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLTasks.h"
#import "GTMOAuth2ViewControllerTouch.h"

//@protocol MDTasksViewControllerDataSource;

@interface MDTasksViewController : UITableViewController

//@property (nonatomic, assign) id<MDTasksViewControllerDataSource> dataSource;
@property (nonatomic, assign) GTLTasksTaskList *taskList;
//@property (nonatomic, strong) GTLServiceTasks *tasksService;
//@property (nonatomic, strong) GTLTasksTasks *tasks;

//- (void)reloadData;
@property (nonatomic, strong) GTMOAuth2Authentication *auth;

@end

//@protocol MDTasksViewControllerDataSource <NSObject>
//
//- (NSArray *)tasksForTasksViewController:(MDTasksViewController *)tasksViewController;
//
//@end
