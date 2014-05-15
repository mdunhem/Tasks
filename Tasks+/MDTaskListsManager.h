//
//  MDTaskListsManager.h
//  Tasks+
//
//  Created by Sven on 5/14/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDManager.h"

#import "GTLTasks.h"
#import "GTMOAuth2ViewControllerTouch.h"

@interface MDTaskListsManager : MDManager

// TaskList Editing
- (void)addNewTaskList:(GTLTasksTaskList *)taskList;
- (void)editTaskList:(GTLTasksTaskList *)taskList;
- (void)deleteTaskList:(GTLTasksTaskList *)taskList;

- (GTLTasksTaskList *)taskListAtIndex:(NSUInteger)index;

@end

