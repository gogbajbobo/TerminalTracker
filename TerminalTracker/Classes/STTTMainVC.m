//
//  STMainVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/24/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTMainVC.h"
#import <STManagedTracker/STSessionManager.h>
#import "STTTAgentTask+remainingTime.h"
#import "STTTAgentTerminal.h"
#import "STTTTerminalVC.h"
#import "STTTTaskVC.h"

@interface STTTMainVC () <UITableViewDelegate>

@property (nonatomic, strong) UIView *terminalView;
@property (nonatomic, strong) UIView *taskView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) BOOL tableViewIsShown;
@property (nonatomic) BOOL tasksIsShown;
@property (nonatomic) BOOL terminalsIsShown;
@property (nonatomic, strong) STSession *session;
@property (nonatomic, strong) STTTAgentTask *selectedTask;
@property (nonatomic, strong) STTTAgentTerminal *selectedTerminal;
@property (nonatomic, strong) UIColor *terminalInfoViewColor;
@property (nonatomic, strong) UIColor *taskInfoViewColor;
@property (nonatomic, strong) NSDictionary *backgroundColors;


@end

@implementation STTTMainVC

- (UIColor *)terminalInfoViewColor {
    return [UIColor colorWithRed:0.9 green:0.9 blue:1 alpha:1];
}

- (UIColor *)taskInfoViewColor {
    return [UIColor colorWithRed:0.9 green:1 blue:0.9 alpha:1];
}

- (NSDictionary *)backgroundColors {
    if (!_backgroundColors) {
        _backgroundColors = [NSDictionary dictionaryWithObjectsAndKeys:self.terminalInfoViewColor, @"terminal", self.taskInfoViewColor, @"task", nil];
    }
    return _backgroundColors;
}

- (STSession *)session {
    return [[STSessionManager sharedManager] currentSession];
}

- (void)taskViewTap {
//    NSLog(@"taskViewTap");
    if (!self.tableViewIsShown) {
        [self showTableView];
        self.tasksIsShown = YES;
        
    } else {
        if (self.tasksIsShown) {
            self.tasksIsShown = NO;
            [self fullSizeInfoViews];
        } else {
//            NSLog(@"show tasks table");
            self.tasksIsShown = YES;
        }
    }
}

- (void)terminalViewTap {
//    NSLog(@"terminalViewTap");
    if (!self.tableViewIsShown) {
        [[STTTLocationController sharedLC] getLocation];
        [self showTableView];
        self.terminalsIsShown = YES;
        
    } else {
        if (self.terminalsIsShown) {
            self.terminalsIsShown = NO;
            [self fullSizeInfoViews];
        } else {
//            NSLog(@"show terminals table");
            self.terminalsIsShown = YES;
        }
    }

}

- (void)setTerminalsIsShown:(BOOL)terminalsIsShown {
    _terminalsIsShown = terminalsIsShown;
    if (_terminalsIsShown) {
        self.tasksIsShown = NO;
        self.title = @"Терминалы";
//        self.terminalController.tableView = self.tableView;
        self.tableView.dataSource = self.terminalController;
        self.tableView.backgroundColor = self.terminalInfoViewColor;
        [self.tableView reloadData];
    }
}

- (void)setTasksIsShown:(BOOL)tasksIsShown {
    _tasksIsShown = tasksIsShown;
    if (_tasksIsShown) {
        self.terminalsIsShown = NO;
        self.title = @"Задания";
//        self.taskController.tableView = self.tableView;
        self.tableView.dataSource = self.taskController;
        self.tableView.backgroundColor = self.taskInfoViewColor;
        [self.tableView reloadData];
    }
}

- (void)shrinkInfoViews {
    self.taskView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 54);
    self.terminalView.frame = CGRectMake(0, self.view.bounds.size.height - 54, self.view.bounds.size.width, 54);
}

- (void)fullSizeInfoViews {
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    self.tableViewIsShown = NO;
    self.title = @"Информация";
    self.taskView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2);
    self.terminalView.frame = CGRectMake(0, self.view.bounds.size.height / 2, self.view.bounds.size.width, self.view.bounds.size.height / 2);
}

- (void)showTableView {
    [self shrinkInfoViews];
    self.tableViewIsShown = YES;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, self.view.bounds.size.width, self.view.bounds.size.height - 108) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)showTaskInfo {
    
    [self removeSubviewsFrom:self.taskView];
    
    NSArray *tasks = self.taskController.resultsController.fetchedObjects;
    
    UILabel *numberOfTasksLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.taskView.bounds.size.width * 0.1, self.taskView.bounds.size.height * 0.05, self.taskView.bounds.size.width * 0.8, 44)];
    numberOfTasksLabel.text = [NSString stringWithFormat:@"Заданий: %d", tasks.count];
    numberOfTasksLabel.textAlignment = NSTextAlignmentCenter;
    numberOfTasksLabel.font = [UIFont boldSystemFontOfSize:28];
    numberOfTasksLabel.backgroundColor = self.taskInfoViewColor;
    [self.taskView addSubview:numberOfTasksLabel];

    UILabel *numberOfUnsolvedTasksLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.taskView.bounds.size.width * 0.1, self.taskView.bounds.size.height * 0.1 + 44, self.taskView.bounds.size.width * 0.8, 44)];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.visited == %@", 0];
    NSUInteger numberOfUnsolvedTasks = [tasks filteredArrayUsingPredicate:predicate].count;
    numberOfUnsolvedTasksLabel.text = [NSString stringWithFormat:@"Невыполненных: %d", numberOfUnsolvedTasks];
    numberOfUnsolvedTasksLabel.font = [UIFont boldSystemFontOfSize:24];
    numberOfUnsolvedTasksLabel.backgroundColor = self.taskInfoViewColor;
    [self.taskView addSubview:numberOfUnsolvedTasksLabel];

    UILabel *numberOfCriticalTasksLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.taskView.bounds.size.width * 0.1, self.taskView.bounds.size.height * 0.1 + 88, self.taskView.bounds.size.width * 0.8, 88)];
    numberOfCriticalTasksLabel.lineBreakMode = NSLineBreakByWordWrapping;
    numberOfCriticalTasksLabel.numberOfLines = 2;
    int numberOfCriticalTasks = 0;
    int numberOfOverdueTasks = 0;
    for (STTTAgentTask *task in tasks) {
        NSTimeInterval remainingTime = [task remainingTime];
        if (remainingTime > 0 && remainingTime < 60*60) {
            numberOfCriticalTasks += 1;
        } else if (remainingTime <= 0) {
            numberOfOverdueTasks += 1;
        }
    }
    numberOfCriticalTasksLabel.text = [NSString stringWithFormat:@"Критических: %d \r\nПросроченных: %d", numberOfCriticalTasks, numberOfOverdueTasks];
    numberOfCriticalTasksLabel.font = [UIFont boldSystemFontOfSize:20];
    if (numberOfCriticalTasks + numberOfOverdueTasks > 0) {
        numberOfCriticalTasksLabel.backgroundColor = [UIColor redColor];
        numberOfCriticalTasksLabel.textColor = [UIColor whiteColor];
    } else {
        numberOfCriticalTasksLabel.backgroundColor = self.taskInfoViewColor;
        numberOfCriticalTasksLabel.textColor = [UIColor blackColor];
    }
    [self.taskView addSubview:numberOfCriticalTasksLabel];

    
}

- (void)showTerminalInfo {
    
    [self removeSubviewsFrom:self.terminalView];
    
    UILabel *numberOfTerminalsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.terminalView.bounds.size.width * 0.1, self.terminalView.bounds.size.height * 0.05, self.terminalView.bounds.size.width * 0.8, 44)];
    numberOfTerminalsLabel.text = [NSString stringWithFormat:@"Терминалов: %d", self.terminalController.resultsController.fetchedObjects.count];
    numberOfTerminalsLabel.textAlignment = NSTextAlignmentCenter;
    numberOfTerminalsLabel.font = [UIFont boldSystemFontOfSize:28];
    numberOfTerminalsLabel.backgroundColor = self.terminalInfoViewColor;
    [self.terminalView addSubview:numberOfTerminalsLabel];

    UILabel *nearestLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.terminalView.bounds.size.width * 0.1, self.terminalView.bounds.size.height * 0.1 + 44, self.terminalView.bounds.size.width * 0.8, 44)];
    nearestLabel.text = @"Ближайший:";
    nearestLabel.font = [UIFont boldSystemFontOfSize:24];
    nearestLabel.backgroundColor = self.terminalInfoViewColor;
    [self.terminalView addSubview:nearestLabel];

    UILabel *nearestAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.terminalView.bounds.size.width * 0.1, self.terminalView.bounds.size.height * 0.1 + 88, self.terminalView.bounds.size.width * 0.8, 88)];
    if (self.terminalController.resultsController.fetchedObjects.count > 0) {
        nearestAddressLabel.text = [(STTTAgentTerminal *)[self.terminalController.resultsController.fetchedObjects objectAtIndex:0] address];
    }
    nearestAddressLabel.textAlignment = NSTextAlignmentRight;
    nearestAddressLabel.font = [UIFont systemFontOfSize:20];
    nearestAddressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nearestAddressLabel.numberOfLines = 3;
    nearestAddressLabel.backgroundColor = self.terminalInfoViewColor;
    [self.terminalView addSubview:nearestAddressLabel];

}

- (void)removeSubviewsFrom:(UIView *)view {
    for (UIView *subview in view.subviews) {
        [subview removeFromSuperview];
    }

}

- (void)viewInit {

    CGFloat halfHeight = (self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height) / 2;

    self.taskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, halfHeight)];
    self.taskView.backgroundColor = self.taskInfoViewColor;
    
    UIGestureRecognizer *taskViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taskViewTap)];
    [self.taskView addGestureRecognizer:taskViewTap];
    
    self.terminalView = [[UIView alloc] initWithFrame:CGRectMake(0, halfHeight, self.view.bounds.size.width, halfHeight)];
    self.terminalView.backgroundColor = self.terminalInfoViewColor;
    
    UIGestureRecognizer *terminalViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(terminalViewTap)];
    [self.terminalView addGestureRecognizer:terminalViewTap];
        
    [self.view addSubview:self.taskView];
    [self.view addSubview:self.terminalView];
    
    self.title = @"Информация";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    
}

- (void)sessionStatusChanged:(NSNotification *)notification {

    if ([self.session.status isEqualToString:@"running"]) {
        
        self.terminalController = [[STTTTerminalController alloc] init];
        self.terminalController.session = self.session;

        self.taskController = [[STTTTaskController alloc] init];
        self.taskController.session = self.session;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocationUpdated:) name:@"currentLocationUpdated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskControllerDidChangeContent:) name:@"taskControllerDidChangeContent" object:self.taskController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(terminalControllerDidChangeContent:) name:@"terminalControllerDidChangeContent" object:self.terminalController];

        
        [STTTLocationController sharedLC].session = [[STSessionManager sharedManager] currentSession];
        [[STTTLocationController sharedLC] getLocation];
        [self showTaskInfo];
        [self showTerminalInfo];

    }

}

- (void)currentLocationUpdated:(NSNotification *)notification {
    NSLog(@"currentLocation %@", notification.object);
    [self.terminalController calculateDistance];
}

- (void)taskControllerDidChangeContent:(NSNotification *)notification {
    [self showTaskInfo];
}

- (void)terminalControllerDidChangeContent:(NSNotification *)notification {
    [self showTerminalInfo];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.tasksIsShown) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.taskController.resultsController sections] objectAtIndex:indexPath.section];
        STTTAgentTask *task = (STTTAgentTask *)[[sectionInfo objects] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"showTask" sender:task];

    } else if (self.terminalsIsShown) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.terminalController.resultsController sections] objectAtIndex:indexPath.section];
        STTTAgentTerminal *terminal = (STTTAgentTerminal *)[[sectionInfo objects] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"showTerminal" sender:terminal];

    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showTask"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTTaskVC class]] && [sender isKindOfClass:[STTTAgentTask class]]) {
            [(STTTTaskVC *)segue.destinationViewController setTask:(STTTAgentTask *)sender];
            [(STTTTaskVC *)segue.destinationViewController setBackgroundColors:self.backgroundColors];
        }
    } else if ([segue.identifier isEqualToString:@"showTerminal"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTTerminalVC class]] && [sender isKindOfClass:[STTTAgentTerminal class]]) {
            [(STTTTerminalVC *)segue.destinationViewController setTerminal:(STTTAgentTerminal *)sender];
            [(STTTTerminalVC *)segue.destinationViewController setBackgroundColors:self.backgroundColors];
        }
    }
    
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
