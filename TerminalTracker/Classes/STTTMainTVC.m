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

@interface STTTMainTVC ()

@property (nonatomic, strong) STSession *session;


@end

@implementation STTTMainTVC

- (STSession *)session {
    return [[STSessionManager sharedManager] currentSession];
}

- (void)viewInit {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    
    if ([self.session.status isEqualToString:@"running"]) {
        [self sessionStatusChanged:nil];
    }
    
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
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarDoubleTap)];
        doubleTap.numberOfTapsRequired = 2;
        [self.navigationController.navigationBar addGestureRecognizer:doubleTap];
        
        [self.tableView reloadData];
        
    }
    
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
    
    return 1;
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
            headerHeight = 140;
            break;

        default:
            headerHeight = UITableViewAutomaticDimension;
            break;
    }
    return headerHeight;
    
}

- (STTTInfoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"mainViewCell";
    //    STTTInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
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
            [self configureDeleteCell:cell];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)configureDeleteCell:(STTTInfoCell *)cell {
    
    cell.textLabel.text = @"Очистить базу данных";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
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
    
    [self performSegueWithIdentifier:@"showInfoTVC" sender:indexPath];
    
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
                    infoTVC.title = @"Терминалы";
                    
                }
            }
        }
    }
}

@end
