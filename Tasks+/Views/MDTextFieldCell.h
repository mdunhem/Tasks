//
//  MDTextFieldCell.h
//  Tasks+
//
//  Created by Sven on 5/9/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDTextFieldCell : UITableViewCell

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, strong) UITextField *textField;

@end
