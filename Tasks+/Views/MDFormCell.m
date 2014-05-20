//
//  MDFormCell.m
//  Tasks+
//
//  Created by Sven on 5/9/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDFormCell.h"

@implementation MDFormCell

- (id)initWithFormType:(MDFormCellType)type reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
