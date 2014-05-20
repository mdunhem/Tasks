//
//  MDCollapsableTableViewCell.h
//  Tasks+
//
//  Created by Sven on 5/17/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MDCollapsibleTableViewCellDelegate;

@interface MDCollapsibleTableViewCell : UITableViewCell

@property (nonatomic, assign) id <MDCollapsibleTableViewCellDelegate> delegate;
@property (nonatomic, strong) UITableViewCell *parent;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic) BOOL isOpen;

- (void)toggle;

@end

@protocol MDCollapsibleTableViewCellDelegate <NSObject>

- (void)collapseableTableViewCell:(MDCollapsibleTableViewCell *)collapsibleTableViewCell toggleOpen:(BOOL)isOpen;

@end
