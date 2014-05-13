//
//  MDFormCell.h
//  Tasks+
//
//  Created by Sven on 5/9/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MDFormCellTypeText,
    MDFormCellTypeDate
} MDFormCellType;

@interface MDFormCell : UITableViewCell

- (id)initWithFormType:(MDFormCellType)type reuseIdentifier:(NSString *)reuseIdentifier;

@end
