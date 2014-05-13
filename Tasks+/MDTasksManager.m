//
//  MDTasksManager.m
//  Tasks+
//
//  Created by Sven on 5/12/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDTasksManager.h"

@interface MDTasksManager ()

@property (nonatomic, strong) GTLTasksTaskLists *taskLists;
@property (nonatomic, strong) GTLTasksTasks *tasks;
@property (nonatomic, strong) GTLServiceTasks *service;

- (void)syncTaskListsWithFetchedTaskLists:(GTLTasksTaskLists *)fetchedTaskLists;
- (void)syncTaskListsWithFetchedTaskList:(GTLTasksTaskList *)fetchedTaskList;

@end

@implementation MDTasksManager

@synthesize ticket = _ticket;

#pragma mark - Properties

- (GTLServiceTasks *)service {
    
    if (!_service) {
        _service = [[GTLServiceTasks alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them
        _service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        _service.retryEnabled = YES;
    }
    return _service;
}

#pragma mark - TableView Methods

- (NSInteger)numberOfTaskLists {
    return self.taskLists.items.count;
}
- (NSInteger)numberOfTasks {
    return self.tasks.items.count;
}

#pragma mark - Sync Methods

- (void)syncTaskListsWithFetchedTaskLists:(GTLTasksTaskLists *)fetchedTaskLists {
    for (GTLTasksTaskList *list in fetchedTaskLists) {
        [self syncTaskListsWithFetchedTaskList:list];
    }
}

- (void)syncTaskListsWithFetchedTaskList:(GTLTasksTaskList *)fetchedTaskList {
    if (![self.taskLists.items containsObject:fetchedTaskList]) {
        self.taskLists.items = [self.taskLists.items arrayByAddingObject:fetchedTaskList];
    }
}

#pragma mark - Fetch Methods

- (BOOL)fetchTaskLists:(NSError *)error {
    __block NSError *localError = nil;
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsList];
    _ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id taskLists, NSError *fetchError) {
        _ticket = nil;
        if ([self.delegate respondsToSelector:@selector(managerWillChangeContent:)]) {
            [self.delegate managerWillChangeContent:self];
        }
        [self syncTaskListsWithFetchedTaskLists:taskLists];
        if ([self.delegate respondsToSelector:@selector(managerDidChangeContent:)]) {
            [self.delegate managerDidChangeContent:self];
        }
        localError = fetchError;
    }];
    
    error = localError;
    
    return !error;
}

- (BOOL)fetchTasks:(NSError *)error forTaskListAtIndex:(NSUInteger)index {
    __block NSError *localError = nil;
    GTLTasksTaskList *taskList = [self.taskLists itemAtIndex:index];
    GTLQueryTasks *query = [GTLQueryTasks queryForTasksListWithTasklist:taskList.identifier];
    _ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id tasks, NSError *fetchError) {
        _ticket = nil;
        self.tasks = tasks;
        localError = fetchError;
    }];
    
    error = localError;
    
    return !error;
}

#pragma mark - TaskList Managing Methods

- (void)addNewTaskList:(GTLTasksTaskList *)taskList {
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsInsertWithObject:taskList];
    
    _ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        _ticket = nil;
        
        if (error == nil) {
            [self syncTaskListsWithFetchedTaskList:item];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)editTaskList:(GTLTasksTaskList *)taskList {
    
}

- (void)renameTaskList:(GTLTasksTaskList *)taskList {
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsPatchWithObject:taskList tasklist:taskList.identifier];
    
    _ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        _ticket = nil;
        
        if (error == nil) {
            
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)deleteTaskList:(GTLTasksTaskList *)taskList {
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsDeleteWithTasklist:taskList.identifier];
    
    _ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        _ticket = nil;
        
        if (error == nil) {
            
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

#pragma mark - Getters

- (GTLTasksTaskList *)taskListAtIndex:(NSUInteger)index {
    return [self.taskLists itemAtIndex:index];
}

- (GTLTasksTask *)taskAtIndex:(NSUInteger)index {
    return [self.tasks itemAtIndex:index];
}

@end
