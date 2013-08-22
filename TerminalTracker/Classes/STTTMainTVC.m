//
//  STTTMainTVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/22/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTMainTVC.h"
#import <STManagedTracker/STSessionManager.h>
#import "STTTLocationController.h"
#import "STTTAgentTask+remainingTime.h"
#import "STTTInfoTVC.h"
#import "STTTInfoCell.h"
#import "STTTSyncer.h"

@interface STTTMainTVC () <UIAlertViewDelegate>

@property (nonatomic, strong) STSession *session;
@property (nonatomic, strong) STTTInfoCell *deleteCell;
@property (nonatomic, strong) STTTInfoCell *refreshCell;


@end

@implementation STTTMainTVC

- (STSession *)session {
    return [[STSessionManager sharedManager] currentSession];
}

- (void)viewInit {
    
    [self addLogButton];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sessionStatusChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    if ([self.session.status isEqualToString:@"running"]) {
        [self sessionStatusChanged:nil];
        [self syncStatusChanged:nil];
    }
    
}

- (void)addLogButton {
    UIBarButtonItem *logButton = [[UIBarButtonItem alloc] initWithTitle:@"Log" style:UIBarButtonItemStyleBordered target:self action:@selector(logButtonPressed)];
    self.navigationItem.rightBarButtonItem = logButton;
}

- (void)logButtonPressed {
    UITableViewController *logTVC = [[UITableViewController alloc] init];
    logTVC.tableView.delegate = self.session.logger;
    logTVC.tableView.dataSource = self.session.logger;
    self.session.logger.tableView = logTVC.tableView;
    [self.navigationController pushViewController:logTVC animated:YES];
}

- (void)syncStatusChanged:(NSNotification *)notification {
    if (self.session.syncer.syncing) {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.tag = 1;
        [spinner startAnimating];
        
        CGFloat padding = 20;
        CGFloat x = self.refreshCell.contentView.frame.size.width - spinner.frame.size.width - padding;
        CGFloat y = (self.refreshCell.contentView.frame.size.height - spinner.frame.size.width) / 2;
        CGRect frame = CGRectMake(x, y, spinner.frame.size.width, spinner.frame.size.height);
        spinner.frame = frame;
        [[self.refreshCell.contentView viewWithTag:1] removeFromSuperview];
        [self.refreshCell.contentView addSubview:spinner];
        
        self.deleteCell.textLabel.textColor = [UIColor grayColor];

    } else {
        
        [[self.refreshCell.contentView viewWithTag:1] removeFromSuperview];
        self.deleteCell.textLabel.textColor = [UIColor blackColor];
        
    }
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    
    if ([self.session.status isEqualToString:@"running"]) {
        
        self.terminalController = [[STTTTerminalController alloc] init];
        self.terminalController.session = self.session;
        
        self.taskController = [[STTTTaskController alloc] init];
        self.taskController.session = self.session;
        
        [self removeObservers];
        [self addObservers];
        
        [STTTLocationController sharedLC].session = [[STSessionManager sharedManager] currentSession];
        [[STTTLocationController sharedLC] getLocation];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarDoubleTap)];
        doubleTap.numberOfTapsRequired = 2;
        [self.navigationController.navigationBar addGestureRecognizer:doubleTap];
        
        [self.tableView reloadData];
        
    }
    
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocationUpdated:) name:@"currentLocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskControllerDidChangeContent:) name:@"taskControllerDidChangeContent" object:self.taskController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(terminalControllerDidChangeContent:) name:@"terminalControllerDidChangeContent" object:self.terminalController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncStatusChanged:) name:@"syncStatusChanged" object:self.session.syncer];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"currentLocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"taskControllerDidChangeContent" object:self.taskController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"terminalControllerDidChangeContent" object:self.terminalController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncStatusChanged" object:self.session.syncer];
}

- (void)navBarDoubleTap {
    
    [self.session.syncer syncData];
    
}

- (void)currentLocationUpdated:(NSNotification *)notification {
    NSLog(@"currentLocation %@", notification.object);
    [self.terminalController calculateDistance];
    [self.tableView reloadData];
}

- (void)taskControllerDidChangeContent:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)terminalControllerDidChangeContent:(NSNotification *)notification {
    [self.tableView reloadData];
}


#pragma mark - view lifecycle

- (void) awakeFromNib {
    self.title = @"Техники";
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    if ([self.session.status isEqualToString:@"running"]) {
        [[STTTLocationController sharedLC] getLocation];
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 2:
            return 2;
            break;
        default:
            return 1;
            break;
    }

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle;
    switch (section) {
        case 0:
            sectionTitle = @"Задачи";
            break;
        case 1:
            sectionTitle = @"Терминалы";
            break;
        case 2:
            sectionTitle = @"Управление";
            break;
        default:
            break;
    }
    return sectionTitle;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    CGFloat headerHeight;
    switch (section) {
        case 2:
            headerHeight = UITableViewAutomaticDimension;
            break;

        default:
            headerHeight = UITableViewAutomaticDimension;
            break;
    }
    return headerHeight;
    
}

- (STTTInfoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"mainViewCell";

    STTTInfoCell *cell = [[STTTInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    //    if (!cell) {
    //        cell = [[STTTInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    //    }
    
        
    switch (indexPath.section) {
        case 0:
            [self configureTaskCell:cell];
            break;
        case 1:
            [self configureTerminalCell:cell];
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [self configureRefreshCell:cell];
                    self.refreshCell = cell;
                    break;
                case 1:
                    [self configureDeleteCell:cell];
                    self.deleteCell = cell;
                    break;
                    
                default:
                    break;
            }
            [self syncStatusChanged:nil];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)configureRefreshCell:(STTTInfoCell *)cell {
    
    cell.textLabel.text = @"Обновить данные";
    
}

- (void)configureDeleteCell:(STTTInfoCell *)cell {
    
    cell.textLabel.text = @"Очистить базу данных";
    
}

- (void)configureTaskCell:(STTTInfoCell *)cell {
    
    NSArray *tasks = self.taskController.resultsController.fetchedObjects;
    
    if (tasks.count > 0) {
        //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.servstatus == %@", [NSNumber numberWithInt:0]];
    NSArray *unsolvedTasks = [tasks filteredArrayUsingPredicate:predicate];
    NSUInteger numberOfUnsolvedTasks = unsolvedTasks.count;
    cell.textLabel.text = [NSString stringWithFormat:@"Невыполненных: %d", numberOfUnsolvedTasks];
    
    //
    //    NSString *subtitle = @"Всего: ";
    //    cell.detailTextLabel.text = [subtitle stringByAppendingFormat:@"%d", tasks.count];
    
    int numberOfOverdueTasks = 0;
    int numberOfCriticalTasks = 0;
    int numberOfCautionTasks = 0;
    int numberOfHurryTasks = 0;
    for (STTTAgentTask *task in unsolvedTasks) {
        NSTimeInterval remainingTime = [task remainingTime];
        if (remainingTime <= 0) {
            numberOfOverdueTasks += 1;
        } else if (remainingTime > 0 && remainingTime < 60*60) {
            numberOfCriticalTasks += 1;
        } else if (remainingTime > 60*60 && remainingTime < 120*60) {
            numberOfCautionTasks += 1;
        } else if (remainingTime > 120*60 && remainingTime < 180*60) {
            numberOfHurryTasks += 1;
        }
    }
    
    int numberOfColoredTasks = numberOfCautionTasks + numberOfCriticalTasks + numberOfHurryTasks + numberOfOverdueTasks;
    int numberOfUncoloredTasks = numberOfUnsolvedTasks - numberOfColoredTasks;
    
    if (numberOfColoredTasks > 0) {
        UIColor *backgroundColor = cell.backgroundColor;
        UIColor *textColor = [UIColor blackColor];
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    font, NSFontAttributeName,
                                    backgroundColor, NSBackgroundColorAttributeName,
                                    textColor, NSForegroundColorAttributeName,
                                    nil];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"" attributes:attributes];
        
        if (numberOfOverdueTasks > 0) {
            
            textColor = [UIColor redColor];
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          textColor, NSForegroundColorAttributeName,
                          nil];
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d ", numberOfOverdueTasks] attributes:attributes]];
            
        }
        
        if (numberOfCriticalTasks > 0) {
            
            backgroundColor = [UIColor redColor];
            textColor = [UIColor whiteColor];
            
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          font, NSFontAttributeName,
                          backgroundColor, NSBackgroundColorAttributeName,
                          textColor, NSForegroundColorAttributeName,
                          nil];
            
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d ", numberOfCriticalTasks] attributes:attributes]];
            
        }
        
        if (numberOfCautionTasks > 0) {
            
            backgroundColor = [UIColor yellowColor];
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          backgroundColor, NSBackgroundColorAttributeName,
                          nil];
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d ", numberOfCautionTasks] attributes:attributes]];
            
        }
        
        if (numberOfHurryTasks > 0) {
            backgroundColor = [UIColor colorWithRed:0.56 green:0.93 blue:0.56 alpha:1];
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          backgroundColor, NSBackgroundColorAttributeName,
                          nil];
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d ", numberOfHurryTasks] attributes:attributes]];
        }
        
        if (numberOfUncoloredTasks > 0) {
            backgroundColor = cell.backgroundColor;
            attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          backgroundColor, NSBackgroundColorAttributeName,
                          nil];
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d ", numberOfUncoloredTasks] attributes:attributes]];
        }
        
        cell.detailTextLabel.attributedText = text;
    }
    
    if (tasks.count > 0) {
        cell.infoLabel.text = [NSString stringWithFormat:@"%d", tasks.count];
    }
    
}

- (void)configureTerminalCell:(STTTInfoCell *)cell {
    
    NSArray *terminals = self.terminalController.resultsController.fetchedObjects;
    
    if (terminals.count > 0) {
        //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Ближайший:";
        cell.detailTextLabel.text = [(STTTAgentTerminal *)[self.terminalController.resultsController.fetchedObjects objectAtIndex:0] address];
        
        cell.infoLabel.text = [NSString stringWithFormat:@"%d", terminals.count];
        
    } else {
        cell.textLabel.text = @"Нет данных";
    }
    
}

- (void)addInfoLabelWithText:(NSString *)text andAttributes:(NSDictionary *)attributes toCell:(UITableViewCell *)cell {
    
    UIFont *font = [attributes objectForKey:NSFontAttributeName];
    
    CGSize size = [text sizeWithFont:font];
    //    NSLog(@"size w %f h %f", size.width, size.height);
    
    CGFloat paddingX = 0;
    CGFloat paddingY = 0;
    CGFloat marginX = 10;
    
    CGFloat x = cell.contentView.frame.size.width - size.width - 2 * paddingX - marginX;
    CGFloat y = (cell.contentView.frame.size.height - size.height - 2 * paddingY) / 2;
    //    NSLog(@"x, y, %f, %f", x, y);
    
    CGRect frame = CGRectMake(x, y, size.width + 2 * paddingX, size.height + 2 * paddingY);
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:frame];
    infoLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    infoLabel.tag = 666;
    
    [[cell.contentView viewWithTag:666] removeFromSuperview];
    [cell.contentView addSubview:infoLabel];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        
        [self performSegueWithIdentifier:@"showInfoTVC" sender:indexPath];
        
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            
            [self.session.syncer syncData];
            
        } else if (indexPath.row == 1) {
            
            if (!self.session.syncer.syncing) {
                
                [self showDeleteAlert];
                
            }
        }
    
    }

}

- (void)showDeleteAlert {
    
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Очистка базы данных" message:@"Вы уверены?" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Уверен!", nil];
    deleteAlert.tag = 1;
    [deleteAlert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        
        if (buttonIndex == 0) {
            // Cancel
            
        } else if (buttonIndex == 1) {
            // Delete
            [self clearDatabase];
        }
        
        self.deleteCell.selected = NO;
        
    }
}

- (void)clearDatabase {
    
    [self removeObjectWithName:NSStringFromClass([STTTAgentTask class])];
    [self removeObjectWithName:NSStringFromClass([STTTAgentTerminal class])];

    [(STTTSyncer *)self.session.syncer setDataOffset:nil];
    
}

- (void)removeObjectWithName:(NSString *)name {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(compare:)], nil];
    NSError *error;
    NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
    for (NSManagedObject *object in fetchResult) {
        [self.session.document.managedObjectContext deleteObject:object];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showInfoTVC"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTInfoTVC class]]) {
            STTTInfoTVC *infoTVC = (STTTInfoTVC *)segue.destinationViewController;
            if ([sender isKindOfClass:[NSIndexPath class]]) {
                
                if ([(NSIndexPath *)sender section] == 0) {
                    
                    infoTVC.tableView.dataSource = self.taskController;
                    self.taskController.tableView = infoTVC.tableView;
                    infoTVC.title = @"Задачи";
                    
                } else if ([(NSIndexPath *)sender section] == 1) {
                    
                    infoTVC.tableView.dataSource = self.terminalController;
                    self.terminalController.tableView = infoTVC.tableView;
                    infoTVC.title = @"Терминалы";
                    
                }
            }
        }
    }
}

@end
