//
//  MDEditTaskListViewController.h
//  Tasks+
//
//  Created by Sven on 5/8/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDEditTaskListViewController;
@class GTLTasksTaskList;

@protocol MDEditTaskListViewControllerDelegate <NSObject>

- (void)MDEditTaskListViewController:(MDEditTaskListViewController *)editTaskListViewController didEndWithUpdatedTaskList:(GTLTasksTaskList *)taskList;

@end

@interface MDEditTaskListViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) GTLTasksTaskList *taskList;
@property (nonatomic, assign) id<MDEditTaskListViewControllerDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewStyle)style taskList:(GTLTasksTaskList *)taskList;

@end
