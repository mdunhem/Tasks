//
//  MDDetailViewController.h
//  Tasks+
//
//  Created by Sven on 5/1/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MDTasksViewControllerDataSource;

@interface MDDetailViewController : UIViewController

@property (nonatomic, assign) id<MDTasksViewControllerDataSource> dataSource;
@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
