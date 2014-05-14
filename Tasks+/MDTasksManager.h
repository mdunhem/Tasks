//
//  MDTasksManager.h
//  Tasks+
//
//  Created by Sven on 5/12/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTLTasks.h"
#import "GTMOAuth2ViewControllerTouch.h"

@protocol MDTasksManagerDelegate;

@interface MDTasksManager : NSObject

@property (nonatomic, assign) id <MDTasksManagerDelegate> delegate;
@property (nonatomic, assign) GTMOAuth2Authentication *auth;
@property (nonatomic, readonly) GTLServiceTicket *ticket;

@property (readonly) NSError *fetchError;

- (instancetype)initWithAuth:(GTMOAuth2Authentication *)auth;

// Fetching
- (BOOL)fetchTaskLists:(NSError *)error;
- (BOOL)fetchTasks:(NSError *)error forTaskListAtIndex:(NSUInteger)index;

// Counts
- (NSInteger)numberOfTaskLists;
- (NSInteger)numberOfTasks;

// TaskList Editing
- (void)addNewTaskList:(GTLTasksTaskList *)taskList;
- (void)editTaskList:(GTLTasksTaskList *)taskList;
- (void)renameTaskList:(GTLTasksTaskList *)taskList;
- (void)deleteTaskList:(GTLTasksTaskList *)taskList;

- (GTLTasksTaskList *)taskListAtIndex:(NSUInteger)index;
- (GTLTasksTask *)taskAtIndex:(NSUInteger)index;

@end

@protocol MDTasksManagerDelegate <NSObject>

@optional
- (void)managerWillChangeContent:(MDTasksManager *)manager;
- (void)managerDidChangeContent:(MDTasksManager *)manager;

@end
