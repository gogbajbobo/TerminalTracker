//
//  STMainVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/24/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTMainVC.h"

@interface STTTMainVC ()

@property (nonatomic, strong) UIView *terminalView;
@property (nonatomic, strong) UIView *taskView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) BOOL tableViewIsShown;
@property (nonatomic) BOOL tasksIsShown;
@property (nonatomic) BOOL terminalsIsShown;

@end

@implementation STTTMainVC

- (void)showTableView {
    self.tableViewIsShown = YES;
}

- (void)taskViewTap {
    NSLog(@"taskViewTap");
    if (!self.tableViewIsShown) {
        [self shrinkInfoViews];
        self.tasksIsShown = YES;
        [self showTableView];
        
    } else {
        if (self.tasksIsShown) {
            self.tasksIsShown = NO;
            self.tableView = nil;
            self.tableViewIsShown = NO;
            [self fullSizeInfoViews];
        } else {
            NSLog(@"show tasks table");
            self.terminalsIsShown = NO;
            self.tasksIsShown = YES;
        }
    }
}

- (void)terminalViewTap {
    NSLog(@"terminalViewTap");
    if (!self.tableViewIsShown) {
        [self shrinkInfoViews];
        self.terminalsIsShown = YES;
        [self showTableView];
        
    } else {
        if (self.terminalsIsShown) {
            self.terminalsIsShown = NO;
            self.tableView = nil;
            self.tableViewIsShown = NO;
            [self fullSizeInfoViews];
        } else {
            NSLog(@"show terminals table");
            self.tasksIsShown = NO;
            self.terminalsIsShown = YES;
        }
    }

}

- (void)shrinkInfoViews {
    self.taskView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 54);
    self.terminalView.frame = CGRectMake(0, self.view.bounds.size.height - 54, self.view.bounds.size.width, 54);
}

- (void)fullSizeInfoViews {
    self.taskView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2);
    self.terminalView.frame = CGRectMake(0, self.view.bounds.size.height / 2, self.view.bounds.size.width, self.view.bounds.size.height / 2);
}

- (void)viewInit {
    NSLog(@"self.view %@", self.view);
    NSLog(@"self.navigationController.navigationBar %@", self.navigationController.navigationBar);
    
    CGFloat halfHeight = (self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height) / 2;

    self.taskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, halfHeight)];
    self.taskView.backgroundColor = [UIColor greenColor];
    
    UIGestureRecognizer *taskViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taskViewTap)];
    [self.taskView addGestureRecognizer:taskViewTap];
    
//    UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
//    taskLabel.text = @"TASK";
//    [self.taskView addSubview:taskLabel];
    
    self.terminalView = [[UIView alloc] initWithFrame:CGRectMake(0, halfHeight, self.view.bounds.size.width, halfHeight)];
    self.terminalView.backgroundColor = [UIColor blueColor];
    
    UIGestureRecognizer *terminalViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(terminalViewTap)];
    [self.terminalView addGestureRecognizer:terminalViewTap];
    
//    UILabel *terminalLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.height / 2, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
//    terminalLabel.text = @"TERMINAL";
//    [self.terminalView addSubview:terminalLabel];
    
    [self.view addSubview:self.taskView];
    [self.view addSubview:self.terminalView];
    
}

#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewInit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
