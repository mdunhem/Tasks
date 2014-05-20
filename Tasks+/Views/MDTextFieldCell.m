//
//  MDTextFieldCell.m
//  Tasks+
//
//  Created by Sven on 5/9/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDTextFieldCell.h"

@interface MDTextFieldCell ()

@property NSArray *dynamicCustomConstraints;

@end

@implementation MDTextFieldCell

@synthesize textLabel = _textLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView addSubview:self.textLabel];
        [self.contentView addSubview:self.textField];
        [self.contentView addConstraints:[self layoutConstraints]];
        [self.textLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
    }
    return self;
}

-(void)dealloc {
    [self.textLabel removeObserver:self forKeyPath:@"text"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.textLabel && [keyPath isEqualToString:@"text"]) {
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]){
            [self.contentView needsUpdateConstraints];
        }
    }
}

#pragma mark - Properties

-(UILabel *)textLabel {
    if (_textLabel) return _textLabel;
    _textLabel = [UILabel new];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    return _textLabel;
}

-(UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField new];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        [_textField setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    }
    
    return _textField;
}

#pragma mark - LayoutConstraints

-(NSArray *)layoutConstraints {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self.textLabel setContentHuggingPriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    [result addObject:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [result addObject:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [result addObject:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [result addObject:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    return result;
}

-(void)updateConstraints {
    if (self.dynamicCustomConstraints) {
        [self.contentView removeConstraints:self.dynamicCustomConstraints];
    }
    NSDictionary *views = @{@"label": self.textLabel, @"textField": self.textField};
    if (self.textLabel.text.length > 0) {
        self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[label]-[textField]-4-|" options:0 metrics:0 views:views];
    } else {
        self.dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[textField]-4-|" options:0 metrics:0 views:views];
    }
    [self.contentView addConstraints:self.dynamicCustomConstraints];
    [super updateConstraints];
}

@end
