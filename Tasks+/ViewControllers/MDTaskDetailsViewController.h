//
//  MDTaskDetailsViewController.h
//  Tasks+
//
//  Created by Sven on 5/16/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTLTasksTask;

@interface MDTaskDetailsViewController : UITableViewController

@property (strong, nonatomic) GTLTasksTask *task;

- (instancetype)initWithStyle:(UITableViewStyle)style task:(GTLTasksTask *)task;

@end
