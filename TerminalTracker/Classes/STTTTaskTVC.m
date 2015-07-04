//
//  STTTTaskTVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/22/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTTaskTVC.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "STTTAgentTerminal.h"
#import "STTTTerminalLocation.h"
#import "STTTMapAnnotation.h"
#import "STTTLocationController.h"
#import "STTTTaskLocation.h"
#import "STTTCommentVC.h"
#import "STTTTerminalTVC.h"
#import "STUtilities.h"
#import "STTTAgentTask+cellcoloring.h"
#import "STTTSettingsController.h"

#import "STEditTaskRepairCodesTVC.h"
#import "STEditTaskDefectCodesTVC.h"

#import "STAgentTaskRepairCodeService.h"
#import "STAgentTaskDefectCodeService.h"
#import "STAgentTaskComponentService.h"


@interface STTTTaskTVC ()

@property (nonatomic) BOOL waitingLocation;

@property (nonatomic, strong) UITableViewCell *buttonsCell;
@property (nonatomic, strong) UITableViewCell *commentsCell;
@property (nonatomic, strong) UITableViewCell *repairsCell;
@property (nonatomic, strong) UITableViewCell *defectsCell;
@property (nonatomic, strong) UITableViewCell *componentsCell;

@property (nonatomic) NSInteger repairsCount;
@property (nonatomic) NSInteger defectsCount;
@property (nonatomic) NSInteger componentsCount;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic) BOOL taskCompleted;


@end


@implementation STTTTaskTVC

- (NSInteger)repairsCount {
    
    _repairsCount = [STAgentTaskRepairCodeService getNumberOfSelectedRepairsForTask:self.task];
    return _repairsCount;
    
}

- (NSInteger)defectsCount {
    
    _defectsCount = [STAgentTaskDefectCodeService getNumberOfSelectedDefectsForTask:self.task];
    return _defectsCount;
    
}

- (NSInteger)componentsCount {
    
    _componentsCount = [STAgentTaskComponentService getNumberOfSelectedComponentsForTask:self.task];
    return _componentsCount;
    
}

- (void)viewInit {
    self.title = self.task.terminalBreakName;
    self.taskCompleted = [self.task.servstatus boolValue] && ![self recentlyChangedServstatus];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([change valueForKey:NSKeyValueChangeNewKey] != [change valueForKey:NSKeyValueChangeOldKey]) {
        if ([keyPath isEqualToString:@"commentText"]) {
            [self saveDocument];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:self.commentsCell]] withRowAnimation:UITableViewRowAnimationAutomatic];

        }
    }
    
}

- (void)addObservers {
    [self.task addObserver:self forKeyPath:@"commentText" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocationUpdated:) name:@"currentLocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentAccuracyUpdated:) name:@"currentAccuracyUpdated" object:nil];
}

- (void)removeObservers {
    [self.task removeObserver:self forKeyPath:@"commentText" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"currentLocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"currentAccuracyUpdated" object:nil];
}

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self addObservers];
    
    if (self.defectsCell) [self reloadCell:self.defectsCell];
    if (self.repairsCell) [self reloadCell:self.repairsCell];
    if (self.componentsCell) [self reloadCell:self.componentsCell];
    if (self.buttonsCell) [self reloadCell:self.buttonsCell];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self removeObservers];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 4;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 4;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 3;
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = nil;
    switch (section) {
        case 2:
            sectionTitle = @"Комментарии:";
            break;
        case 3:
            sectionTitle = @"Терминал:";
            break;
    }
    return sectionTitle;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"taskCell";
    UITableViewCell *cell = [UITableViewCell alloc];
    
    switch (indexPath.section) {
            
        case 0:
            cell = [cell initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
            [self addDoBeforeToCell:cell];
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [self addDefectsToCell:cell];
                    break;
                case 1:
                    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [self addRepairsToCell:cell];
                    break;
                case 2:
                    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [self addComponentsToCell:cell];
                    break;
                case 3:
                    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [self addButtonsToCell:cell];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [self addCommentToCell:cell];
            break;
            
        case 3:
            switch (indexPath.row) {
                case 0:
                    cell = [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                    [self addInfoToCell:cell];
                    break;
                case 1:
                    cell = [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                    [self addAddressToCell:cell];
                    break;
                case 2:
                    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [self addMapToCell:cell];
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)addDoBeforeToCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Срок:";
    cell.detailTextLabel.text = [STUtilities stringWithRelativeDateFromDate:self.task.doBefore];
    cell.backgroundColor = [self.task getBackgroundColorForDisplaying];
    cell.detailTextLabel.textColor = [self.task getTextColorForDisplaying];
}

- (void)addCommentToCell:(UITableViewCell *)cell {
    
    if (self.task.commentText) {
        cell.textLabel.text = self.task.commentText;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    } else {
        cell.textLabel.text = @"Добавить комментарий";
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    self.commentsCell = cell;
    
}

- (void)addDefectsToCell:(UITableViewCell *)cell {
    
    NSString *baseLabel = @"Добавить неисправность";
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = (self.defectsCount == 0) ? baseLabel : [NSString stringWithFormat:@"%@ (%i)", baseLabel, self.defectsCount];
    
    self.defectsCell = cell;
    
}

- (void)addRepairsToCell:(UITableViewCell *)cell {
    
    NSString *baseLabel = @"Добавить ремонт";
    
    UIColor *textColor = (self.defectsCount > 0) ? [UIColor blackColor] : [UIColor lightGrayColor];
    
    cell.textLabel.textColor = textColor;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = (self.repairsCount == 0) ? baseLabel : [NSString stringWithFormat:@"%@ (%i)", baseLabel, self.repairsCount];
    
    self.repairsCell = cell;
    
}

- (void)addComponentsToCell:(UITableViewCell *)cell {
    
    NSString *baseLabel = @"ЗИПы";
    
    UIColor *textColor = (self.defectsCount > 0 && self.repairsCount > 0) ? [UIColor blackColor] : [UIColor lightGrayColor];
    
    cell.textLabel.textColor = textColor;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = (self.componentsCount == 0) ? baseLabel : [NSString stringWithFormat:@"%@ (%i)", baseLabel, self.componentsCount];
    
    self.componentsCell = cell;
    
}

- (void)addButtonsToCell:(UITableViewCell *)cell {
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    if (self.taskCompleted) {
        
        cell.textLabel.text = @"Выполнено";
        cell.textLabel.textColor = [UIColor colorWithRed:0.16 green:0.53 blue:0.16 alpha:1];
        
    } else {
        
        UIColor *textColor = (self.repairsCount > 0 && self.defectsCount > 0 && self.componentsCount > 0) ? [UIColor blueColor] : [UIColor lightGrayColor];
        
        cell.textLabel.textColor = textColor;
        if (self.location) {
            cell.textLabel.text = @"Отметить выполнение";
        } else {
            cell.textLabel.text = @"Поставить геометку";
        }
        
    }
    
    self.buttonsCell = cell;
    
}

- (void)addInfoToCell:(UITableViewCell *)cell {
    
    cell.textLabel.text = self.task.terminal.code ? self.task.terminal.code : @"Н/Д";
    
    NSString *lastActivity = [STUtilities stringWithRelativeDateFromDate:self.task.terminal.lastActivityTime];

    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = [lastActivity sizeWithFont:font];
    
    CGFloat paddingX = 0;
    CGFloat paddingY = 0;
    CGFloat marginX = 10;
    
    CGFloat x = cell.contentView.frame.size.width - size.width - 2 * paddingX - marginX;
    CGFloat y = cell.textLabel.bounds.origin.y;
    
    CGRect frame = CGRectMake(x, y, size.width + 2 * paddingX, size.height + 2 * paddingY);
    
    UILabel *lastActivityLabel = [[UILabel alloc] initWithFrame:frame];
    lastActivityLabel.text = lastActivity;
    lastActivityLabel.font = font;
    lastActivityLabel.tag = 666;
    lastActivityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [[cell.contentView viewWithTag:666] removeFromSuperview];
    [cell.contentView addSubview:lastActivityLabel];
    
}

- (void)addAddressToCell:(UITableViewCell *)cell {
    cell.textLabel.text = self.task.terminal.address;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
}

- (void)addMapToCell:(UITableViewCell *)cell {
    if (self.task.terminal) {
        CLLocationCoordinate2D terminalCoordinate = CLLocationCoordinate2DMake([self.task.terminal.location.latitude doubleValue], [self.task.terminal.location.longitude doubleValue]);
        MKCoordinateSpan span;
        span.longitudeDelta = 0.01;
        span.latitudeDelta = 0.01;
        
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 160)];
        [mapView setRegion:MKCoordinateRegionMake(terminalCoordinate, span)];
        mapView.showsUserLocation = YES;
        [mapView addAnnotation:[STTTMapAnnotation initWithCoordinate:terminalCoordinate]];
        
        mapView.userInteractionEnabled = NO;
        mapView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [cell.contentView addSubview:mapView];
    }

}



#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 3:
            switch (indexPath.row) {
                case 2:
                    return 160;
                    break;
                    
                default:
                    return 44;
                    break;
            }
            break;
            
        default:
            return 44;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case 0:
            // do nothing
            break;
            
        case 1:
            
            switch (indexPath.row) {
                case 0:
                    [self performSegueWithIdentifier:@"editDefectCode" sender:self.task];
                    break;
                    
                case 1:
                    if (self.defectsCount > 0) {
                        [self performSegueWithIdentifier:@"editBreakCode" sender:self.task];
                    } else {
                        [self showNoDefectsSelectedAlert];
                    }
                    break;
                    
                case 2:
                    [self performSegueWithIdentifier:@"editComponents" sender:self.task];
                    break;
                    
                case 3:
                    if (self.defectsCount == 0 && self.repairsCount == 0) {
                        [self showNoDefectsAndRepairsSelectedAlert];
                    } else {
                        
                        if (self.defectsCount == 0) {
                            [self showNoDefectsSelectedAlert];
                        } else if (self.repairsCount == 0) {
                            [self showNoRepairsSelectedAlert];
                        } else {
                            if (!self.taskCompleted) {
                                [self buttonsBehaviorInCell:[tableView cellForRowAtIndexPath:indexPath]];
                            }                    
                        }
                        
                    }
                    break;
        
                default:
                    break;
            }
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"showComment" sender:self.task];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"goToTerminal" sender:self.task.terminal];
            break;
            
        default:
            break;
    }
    
}

- (void)buttonsBehaviorInCell:(UITableViewCell *)cell {
    
    if ([STAgentTaskRepairCodeService getNumberOfSelectedRepairsForTask:self.task] == 0) {
        [self showNoRepairsSelectedAlert];
    } else if (!self.location) {
        if (!self.waitingLocation) {
            self.waitingLocation = YES;
            cell.textLabel.text = @"";
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.tag = 1;
            [spinner startAnimating];
            spinner.frame = cell.textLabel.bounds;
            [cell.contentView addSubview:spinner];
            [[STTTLocationController sharedLC] getLocation];
        }
    } else if ([self tooFarFromTerminal]) {
        [self showTooFarAlert];
    } else {
        [self addTaskLocation];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationAutomatic];

    }

}

- (void)reloadCell:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


- (BOOL) recentlyChangedServstatus {
    return abs([self.task.servstatusDate timeIntervalSinceNow]) < [[[STTTSettingsController sharedSTTTSettingsController] getSettingValueForName:@"OkInterval" inGroup:@"general"] doubleValue]*60;
}

- (BOOL)tooFarFromTerminal {
    
#ifdef DEBUG
    
    return NO;
    
#else
    
    CLLocation *terminalLocation = [[CLLocation alloc] initWithLatitude:[self.task.terminal.location.latitude doubleValue]
                                                              longitude:[self.task.terminal.location.longitude doubleValue]];
    CLLocationDistance distanceFromTerminal = [self.location distanceFromLocation:terminalLocation];
    return (distanceFromTerminal > [[[STTTSettingsController sharedSTTTSettingsController] getSettingValueForName:@"maxOkDistanceFromTerminal" inGroup:@"general"] doubleValue]);
    
#endif
    
}


#pragma mark - alerts

- (void) showTooFarAlert {
    double maxOkDistanceFromTerminal = [[[STTTSettingsController sharedSTTTSettingsController] getSettingValueForName:@"maxOkDistanceFromTerminal" inGroup:@"general"] doubleValue];
    NSString *message = [NSString stringWithFormat:@"Нужно находиться не дальше %.0fм от терминала для подтверждения выполнения", maxOkDistanceFromTerminal];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Терминал слишком далеко"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    self.location = nil;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:self.buttonsCell]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)showNoDefectsAndRepairsSelectedAlert {

    NSString *message = [NSString stringWithFormat:@"Необходимо указать неисправности и ремонты для подтверждения выполнения"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Неисправности и ремонты не выбраны"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    self.location = nil;
    
    NSIndexPath *buttonCellIndexPath = [self.tableView indexPathForCell:self.buttonsCell];
    
    [self.tableView reloadRowsAtIndexPaths:@[buttonCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

}

- (void)showNoRepairsSelectedAlert {
    
    NSString *message = [NSString stringWithFormat:@"Необходимо указать ремонты для подтверждения выполнения"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ремонты не выбраны"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    self.location = nil;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:self.buttonsCell]] withRowAnimation:UITableViewRowAnimationAutomatic];

}

- (void)showNoDefectsSelectedAlert {
    
    NSString *message = [NSString stringWithFormat:@"Необходимо указать неисправности для выбора ремонта"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Неисправности не выбраны"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    self.location = nil;
    
    NSIndexPath *buttonCellIndexPath = [self.tableView indexPathForCell:self.buttonsCell];
    NSIndexPath *repairCellIndexPath = [self.tableView indexPathForCell:self.repairsCell];
    
    [self.tableView reloadRowsAtIndexPaths:@[buttonCellIndexPath, repairCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


#pragma mark - notifications

- (void)currentAccuracyUpdated:(NSNotification *)notification {
    if (self.waitingLocation) {
        NSString *currentAccuracy = [NSString stringWithFormat:@"%.f", [STTTLocationController sharedLC].currentAccuracy];
        NSString *requiredAccuracy = [NSString stringWithFormat:@"%.f", [STTTLocationController sharedLC].requiredAccuracy];
//        self.buttonsCell.textLabel.text = [NSString stringWithFormat:@"%@ -> %@", currentAccuracy, requiredAccuracy];
        NSLog(@"accuracy %@", [NSString stringWithFormat:@"%@ -> %@", currentAccuracy, requiredAccuracy]);
    }
}

- (void)currentLocationUpdated:(NSNotification *)notification {
    if (self.waitingLocation) {
        self.location = [[STTTLocationController sharedLC] currentLocation];
        self.waitingLocation = NO;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:self.buttonsCell]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)addTaskLocation {
    if (self.location) {
        STTTTaskLocation *taskLocation = (STTTTaskLocation *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STTTTaskLocation class]) inManagedObjectContext:[[STSessionManager sharedManager] currentSession].document.managedObjectContext];
        taskLocation.latitude = [NSNumber numberWithDouble:self.location.coordinate.latitude];
        taskLocation.longitude = [NSNumber numberWithDouble:self.location.coordinate.longitude];
        self.task.visitLocation = taskLocation;
        self.task.servstatus = [NSNumber numberWithBool:YES];
        self.taskCompleted = YES;
        [self saveDocument];
    } else {
        NSLog(@"No task location");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([sender isKindOfClass:[STTTAgentTask class]]) {
        
        STTTAgentTask *task = (STTTAgentTask *)sender;
        
        if ([segue.identifier isEqualToString:@"showComment"]) {
            
            if ([segue.destinationViewController isKindOfClass:[STTTCommentVC class]]) {
                [(STTTCommentVC *)segue.destinationViewController setTask:task];
            }
            
        } else  if ([segue.identifier isEqualToString:@"editBreakCode"]) {
            
            if ([segue.destinationViewController isKindOfClass:[STEditTaskRepairCodesTVC class]]) {
                [(STEditTaskRepairCodesTVC *)segue.destinationViewController setTask:task];
            }
            
        } else if ([segue.identifier isEqualToString:@"editDefectCode"]) {
            
            if ([segue.destinationViewController isKindOfClass:[STEditTaskDefectCodesTVC class]]) {
                [(STEditTaskDefectCodesTVC *)segue.destinationViewController setTask:task];
            }
            
        }

    } else if ([sender isKindOfClass:[STTTAgentTerminal class]]) {
        
        STTTAgentTerminal *terminal = (STTTAgentTerminal *)sender;
        
        if ([segue.identifier isEqualToString:@"goToTerminal"]) {
            
            if ([segue.destinationViewController isKindOfClass:[STTTTerminalTVC class]]) {
                [(STTTTerminalTVC *)segue.destinationViewController setTerminal:terminal];
            }
            
        }
        
    }
    
}

- (void)saveDocument {
    [[[STSessionManager sharedManager] currentSession].document saveDocument:^(BOOL success) {
        if (!success) {
            NSLog(@"save task fail");
        }
    }];
}

@end
