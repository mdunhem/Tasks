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
        self.ticket = nil;
        
        if (error == nil) {
            [self.taskLists addObject:item];
            [self.delegate manager:self didAddItem:item atIndexPath:[NSIndexPath indexPathForRow:self.count - 1 inSection:0]];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)editTaskList:(GTLTasksTaskList *)taskList {
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsPatchWithObject:taskList tasklist:taskList.identifier];
    NSUInteger index = [self.taskLists indexOfObject:taskList];
    
    self.ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        self.ticket = nil;
        
        if (error == nil) {
            [self.taskLists replaceObjectAtIndex:index withObject:item];
            [self.delegate manager:self didUpdateItem:item atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)deleteTaskList:(GTLTasksTaskList *)taskList {
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsDeleteWithTasklist:taskList.identifier];
    NSUInteger index = [self.taskLists indexOfObject:taskList];
    
    self.ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id item, NSError *error) {
        self.ticket = nil;
        
        if (error == nil) {
            [self.taskLists removeObjectAtIndex:index];
            [self.delegate manager:self didDeleteItem:item atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

#pragma mark - Getters

- (GTLTasksTaskList *)taskListAtIndex:(NSUInteger)index {
    return [self.taskLists objectAtIndex:index];
}

@end
