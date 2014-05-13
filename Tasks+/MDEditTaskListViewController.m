//
//  MDEditTaskListViewController.m
//  Tasks+
//
//  Created by Sven on 5/8/14.
//  Copyright (c) 2014 Mikael Dunhem. All rights reserved.
//

#import "MDEditTaskListViewController.h"
#import "MDTextFieldCell.h"

#import "GTLTasks.h"


static NSString *const kEditTaskListCellIdentifier = @"EditTaskListCellIdentifier";
static NSString *const kEditTaskListCellTextLabelText = @"List Name:";

@interface MDEditTaskListViewController ()

@property (nonatomic, strong) MDTextFieldCell *cell;

- (void)saveButtonPressed:(id)sender;
- (void)cancelButtonPressed:(id)sender;

@end

@implementation MDEditTaskListViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"New List";
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style taskList:(GTLTasksTaskList *)taskList {
    self = [self initWithStyle:style];
    if (taskList) {
        self.taskList = taskList;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    self.navigationItem.leftBarButtonItem = saveButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    [self.cell.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (MDTextFieldCell *)cell {
    if (!_cell) {
        _cell = [[MDTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEditTaskListCellIdentifier];
        _cell.textLabel.text = kEditTaskListCellTextLabelText;
        _cell.textField.text = [self.taskList title];
        _cell.textField.delegate = self;
        _cell.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
        _cell.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _cell.textField.keyboardType = UIKeyboardTypeAlphabet;
        _cell.textField.returnKeyType = UIReturnKeyDone;
    }
    return _cell;
}

- (GTLTasksTaskList *)taskList {
    if (!_taskList) {
        _taskList = [[GTLTasksTaskList alloc] init];
    }
    return _taskList;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cell;
}

- (void)saveButtonPressed:(id)sender {
    [self.cell.textField resignFirstResponder];
}

- (void)cancelButtonPressed:(id)sender {
    [self.delegate MDEditTaskListViewController:self didEndWithNewTaskListName:nil];
}

#pragma mark - UITextFieldDelegate Protocol

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length) {
        self.taskList.title = textField.text;
        [self.delegate MDEditTaskListViewController:self didEndWithUpdatedTaskList:self.taskList];
//        [self.delegate MDEditTaskListViewController:self didEndWithNewTaskListName:textField.text];
    } else {
        [self.delegate MDEditTaskListViewController:self didEndWithUpdatedTaskList:nil];
//        [self.delegate MDEditTaskListViewController:self didEndWithNewTaskListName:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
