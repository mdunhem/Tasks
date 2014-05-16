//
//  MDTasksManager.m
//  Tasks+
//
//  Created by Sven on 5/12/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDTasksManager.h"

@interface MDTasksManager ()

@property (nonatomic, strong) NSMutableArray *tasks;

@end

@implementation MDTasksManager

#pragma mark - Properties

- (NSMutableArray *)tasks {
    if (!_tasks) {
        _tasks = [NSMutableArray array];
    }
    return _tasks;
}

#pragma mark - TableView Methods

- (NSInteger)count {
    return self.tasks.count;
}


#pragma mark - Fetch Methods

- (void)fetch {
    [self.tasks removeAllObjects];
    
    GTLQueryTasks *query = [GTLQueryTasks queryForTasksListWithTasklist:self.taskList.identifier];
    self.ticket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id tasks, NSError *error) {
        self.ticket = nil;
        if (error == nil) {
            for (GTLTasksTask *task in (GTLTasksTasks *)tasks) {
                [self.tasks addObject:task];
            }
            [self.delegate managerDidRefresh:self];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

#pragma mark - Task Managing Methods

- (void)addNewTask:(GTLTasksTask *)task {
    
}

- (void)editTask:(GTLTasksTask *)task {
    
}

- (void)deleteTask:(GTLTasksTask *)task {
    
}

#pragma mark - Getters

- (GTLTasksTask *)taskAtIndex:(NSUInteger)index {
    return [self.tasks objectAtIndex:index];
}

- (BOOL)containsTask:(GTLTasksTask *)task {
    for (GTLTasksTask *testingTask in self.tasks) {
        if ([testingTask.identifier isEqualToString:task.identifier]) {
            return YES;
        }
    }
    return NO;
}

@end
