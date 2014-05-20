//
//  MDTaskListsManager.m
//  Tasks+
//
//  Created by Sven on 5/14/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDTaskListsManager.h"

@interface MDTaskListsManager ()

@property (nonatomic, strong) NSMutableArray *taskLists;

@end

@implementation MDTaskListsManager

#pragma mark - Properties

- (NSMutableArray *)taskLists {
    if (!_taskLists) {
        _taskLists = [NSMutableArray array];
    }
    return _taskLists;
}

#pragma mark - TableView Methods

- (NSInteger)count {
    return self.taskLists.count;
}

#pragma mark - Fetch Methods

- (void)fetch {
    [self.taskLists removeAllObjects];
    
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsList];
    self.ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id taskLists, NSError *error) {
        self.ticket = nil;
        if (error == nil) {
            for (GTLTasksTaskList *list in (GTLTasksTaskLists *)taskLists) {
                [self.taskLists addObject:list];
            }
            [self.delegate managerDidRefresh:self];
        } else {
            NSLog(@"Error: %@", error);
        }
        
    }];
}

#pragma mark - TaskList Managing Methods

- (void)addNewTaskList:(GTLTasksTaskList *)taskList {
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsInsertWithObject:taskList];
    self.ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        // Need to clear the ticket
        self.ticket = nil;
        
        if (error != nil) {
            // TODO: Implement error handling.
            NSLog(@"Error: %@", error);
        }
    }];
    
    [self.taskLists addObject:taskList];
    [self.delegate manager:self didAddItem:taskList atIndexPath:[NSIndexPath indexPathForRow:self.count - 1 inSection:0]];
}

- (void)editTaskList:(GTLTasksTaskList *)taskList {
    NSUInteger index = [self.taskLists indexOfObject:taskList];
    
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsPatchWithObject:taskList tasklist:taskList.identifier];
    self.ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        // Need to clear the ticket
        self.ticket = nil;
        
        if (error != nil) {
            // TODO: Implement error handling.
            NSLog(@"Error: %@", error);
        }
    }];
    
    [self.taskLists replaceObjectAtIndex:index withObject:taskList];
    [self.delegate manager:self didUpdateItem:taskList atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (void)deleteTaskList:(GTLTasksTaskList *)taskList {
    NSUInteger index = [self.taskLists indexOfObject:taskList];
    
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsDeleteWithTasklist:taskList.identifier];
    self.ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        // Need to clear the ticket
        self.ticket = nil;
        
        if (error != nil) {
            // TODO: Implement error handling.
            NSLog(@"Error: %@", error);
        }
    }];
    
    [self.taskLists removeObjectAtIndex:index];
    [self.delegate manager:self didDeleteItem:taskList atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

#pragma mark - Getters

- (GTLTasksTaskList *)taskListAtIndex:(NSUInteger)index {
    return [self.taskLists objectAtIndex:index];
}

- (BOOL)containsTaskList:(GTLTasksTaskList *)taskList {
    for (GTLTasksTaskList *list in self.taskLists) {
        if ([list.identifier isEqualToString:taskList.identifier]) {
            return YES;
        }
    }
    return NO;
}

@end
