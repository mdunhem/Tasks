//
//  MDCollapsableTableViewCell.m
//  Tasks+
//
//  Created by Sven on 5/17/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDCollapsibleTableViewCell.h"

@implementation MDCollapsibleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
}

- (void)toggle {
    
}

@end
