//
//  MDMenuViewController.h
//  Tasks+
//
//  Created by Sven on 5/1/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDTasksManager.h"
#import "MDTasksViewController.h"
#import "MDEditTaskListViewController.h"

@interface MDMenuViewController : UITableViewController <MDEditTaskListViewControllerDelegate, MDTasksManagerDelegate>

- (UIViewController *)getTasksViewController;

@end
