//
//  STMainVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/24/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTMainVC.h"
#import <STManagedTracker/STSessionManager.h>
#import "STTTAgentTerminal.h"

@interface STTTMainVC () <UITableViewDelegate>

@property (nonatomic, strong) UIView *terminalView;
@property (nonatomic, strong) UIView *taskView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) BOOL tableViewIsShown;
@property (nonatomic) BOOL tasksIsShown;
@property (nonatomic) BOOL terminalsIsShown;
@property (nonatomic, strong) STSession *session;

@end

@implementation STTTMainVC

- (STSession *)session {
    return [[STSessionManager sharedManager] currentSession];
}

- (void)taskViewTap {
    NSLog(@"taskViewTap");
    if (!self.tableViewIsShown) {
        [self shrinkInfoViews];
        self.tasksIsShown = YES;
        [self showTableView];
        self.tableView.dataSource = self.taskController;
        [self.tableView reloadData];
        
    } else {
        if (self.tasksIsShown) {
            self.tasksIsShown = NO;
            [self.tableView removeFromSuperview];
            self.tableView = nil;
            self.tableViewIsShown = NO;
            [self fullSizeInfoViews];
        } else {
            NSLog(@"show tasks table");
            self.terminalsIsShown = NO;
            self.tasksIsShown = YES;
            self.tableView.dataSource = self.taskController;
            [self.tableView reloadData];
        }
    }
}

- (void)terminalViewTap {
    NSLog(@"terminalViewTap");
    if (!self.tableViewIsShown) {
        [[STTTLocationController sharedLC] getLocation];
        [self shrinkInfoViews];
        self.terminalsIsShown = YES;
        [self showTableView];
        self.tableView.dataSource = self.terminalController;
        [self.tableView reloadData];
        
    } else {
        if (self.terminalsIsShown) {
            self.terminalsIsShown = NO;
            [self.tableView removeFromSuperview];
            self.tableView = nil;
            self.tableViewIsShown = NO;
            [self fullSizeInfoViews];
        } else {
            NSLog(@"show terminals table");
            self.tasksIsShown = NO;
            self.terminalsIsShown = YES;
            self.tableView.dataSource = self.terminalController;
            [self.tableView reloadData];
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

- (void)showTableView {
    self.tableViewIsShown = YES;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, self.view.bounds.size.width, self.view.bounds.size.height - 108) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)showTerminalInfo {
    
    UILabel *numberOfTerminalsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.terminalView.bounds.size.width * 0.1, self.terminalView.bounds.size.height * 0.05, self.terminalView.bounds.size.width * 0.8, 44)];
    numberOfTerminalsLabel.text = [NSString stringWithFormat:@"Терминалов: %d", self.terminalController.resultsController.fetchedObjects.count];
    numberOfTerminalsLabel.textAlignment = NSTextAlignmentCenter;
    numberOfTerminalsLabel.font = [UIFont boldSystemFontOfSize:28];
    [self.terminalView addSubview:numberOfTerminalsLabel];

    UILabel *nearestLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.terminalView.bounds.size.width * 0.1, self.terminalView.bounds.size.height * 0.1 + 44, self.terminalView.bounds.size.width * 0.8, 44)];
    nearestLabel.text = @"Ближайший:";
    nearestLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.terminalView addSubview:nearestLabel];

    UILabel *nearestAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.terminalView.bounds.size.width * 0.1, self.terminalView.bounds.size.height * 0.1 + 88, self.terminalView.bounds.size.width * 0.8, 88)];
    nearestAddressLabel.text = [(STTTAgentTerminal *)[self.terminalController.resultsController.fetchedObjects objectAtIndex:1] address];
    nearestAddressLabel.textAlignment = NSTextAlignmentRight;
    nearestAddressLabel.font = [UIFont systemFontOfSize:20];
    nearestAddressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nearestAddressLabel.numberOfLines = 3;
    [self.terminalView addSubview:nearestAddressLabel];

}

- (void)viewInit {
//    NSLog(@"self.view %@", self.view);
//    NSLog(@"self.navigationController.navigationBar %@", self.navigationController.navigationBar);
    
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
        
    [self.view addSubview:self.taskView];
    [self.view addSubview:self.terminalView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    
}

- (void)sessionStatusChanged:(NSNotification *)notification {

    if ([self.session.status isEqualToString:@"running"]) {
        
        self.terminalController = [[STTTTerminalController alloc] init];
        self.terminalController.session = self.session;

        self.taskController = [[STTTTaskController alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocationUpdated:) name:@"currentLocationUpdated" object:nil];
        [STTTLocationController sharedLC].session = [[STSessionManager sharedManager] currentSession];
        [[STTTLocationController sharedLC] getLocation];
        [self showTerminalInfo];

    }

}

- (void)currentLocationUpdated:(NSNotification *)notification {
    NSLog(@"currentLocation %@", notification.object);
    [self.terminalController calculateDistance ];
}


#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
//    STHTLocation *location = (STHTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row];
//    NSString *message = [NSString stringWithFormat:@"timestamp %@ \r\n accuracy %@ \r\n", location.timestamp, location.horizontalAccuracy];
//
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location info" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    [alert show];
//}



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
