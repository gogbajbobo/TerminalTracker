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

@interface STTTTaskTVC ()

@property (nonatomic) BOOL waitingLocation;
@property (nonatomic, strong) UITableViewCell *buttonsCell;
@property (nonatomic, strong) UITableViewCell *commentsCell;
@property (nonatomic, strong) CLLocation *location;

@end

@implementation STTTTaskTVC

- (void)viewInit {
    self.title = self.task.terminalBreakName;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocationUpdated:) name:@"currentLocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentAccuracyUpdated:) name:@"currentAccuracyUpdated" object:nil];
    [self.task addObserver:self forKeyPath:@"commentText" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([change valueForKey:NSKeyValueChangeNewKey] != [change valueForKey:NSKeyValueChangeOldKey]) {
        if ([keyPath isEqualToString:@"commentText"]) {
            [self saveDocument];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:self.commentsCell]] withRowAnimation:UITableViewRowAnimationAutomatic];

        }
    }
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 4;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle;
    switch (section) {
        case 0:
            sectionTitle = nil;
            break;
        case 1:
            sectionTitle = nil;
            break;
        case 2:
            sectionTitle = @"Комментарии:";
            break;
        case 3:
            sectionTitle = @"Терминал:";
            break;

        default:
            break;
    }
    return sectionTitle;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"taskCell";
    UITableViewCell *cell = [UITableViewCell alloc];
    
    switch (indexPath.section) {
        case 0:
            cell = [cell initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
            [self addDoBeforeToCell:cell];
            break;
        case 1:
            cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [self addButtonsToCell:cell];
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    if ([[dateFormatter stringFromDate:[NSDate date]] isEqualToString:[dateFormatter stringFromDate:self.task.doBefore]]) {
        
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        
    } else {
        
        if ([[NSDate date] timeIntervalSinceDate:self.task.doBefore] <= 7 * 24 * 3600 &&
            [[NSDate date] timeIntervalSinceDate:self.task.doBefore] >= -7 * 24 * 3600) {
            dateFormatter.dateFormat = @"EEEE";
        } else {
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
        }
        
    }

    cell.textLabel.text = @"Срок:";
//    cell.textLabel.numberOfLines = 2;
    
//    CGSize size = [@"Срок выполнения:" sizeWithFont:[UIFont boldSystemFontOfSize:12]];
//    NSLog(@"size.width %f, size.height %f", size.width, size.height);
    
    
    cell.detailTextLabel.text = [dateFormatter stringFromDate:self.task.doBefore];
    
    
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *textColor = [UIColor blueColor];
    
    if (![self.task.visited boolValue]) {
        
        NSTimeInterval remainingTime = [self.task remainingTime];
        
        if (remainingTime < 0) {
            textColor = [UIColor redColor];
        } else {
            if (remainingTime > 0 && remainingTime <= 60*60) {
                backgroundColor = [UIColor redColor];
                textColor = [UIColor whiteColor];
                cell.textLabel.textColor = textColor;
            } else if (remainingTime < 120*60) {
                backgroundColor = [UIColor yellowColor];
            } else if (remainingTime < 180*60) {
                backgroundColor = [UIColor colorWithRed:0.56 green:0.93 blue:0.56 alpha:1];
            }
        }
        
    }
    
    cell.backgroundColor = backgroundColor;
    cell.detailTextLabel.textColor = textColor;
    
//    NSLog(@"cell.textLabel %@", cell.textLabel);
//    NSLog(@"cell.detailTextLabel %@", cell.detailTextLabel);
    
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

- (void)addButtonsToCell:(UITableViewCell *)cell {

    cell.textLabel.textAlignment = NSTextAlignmentCenter;

    if ([self.task.visited boolValue]) {
        cell.textLabel.text = @"Выполнено";
        cell.textLabel.textColor = [UIColor colorWithRed:0.16 green:0.53 blue:0.16 alpha:1];
    } else {
        cell.textLabel.textColor = [UIColor blueColor];
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
    
    if (self.task.terminal) {
        cell.detailTextLabel.text = self.task.terminal.address ? self.task.terminal.address : @"Нет данных";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.task.terminal.lastActivityTime];
    
    if (timeInterval > 0 && timeInterval <= 24 * 3600) {
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else if (timeInterval <= 7 * 24 * 3600) {
        //        dateFormatter.dateFormat = @"EEEE, H:mm a";
        dateFormatter.dateStyle = NSDateFormatterFullStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    
    NSString *lastActivity = [dateFormatter stringFromDate:self.task.terminal.lastActivityTime];
    
    NSArray *components = [lastActivity componentsSeparatedByString:@","];
    if (components.count > 2) {
        lastActivity = [NSString stringWithFormat:@"%@,%@", [components objectAtIndex:0], [components lastObject]];
    }

    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = [lastActivity sizeWithFont:font];
    
    CGFloat paddingX = 0;
    CGFloat paddingY = 0;
    CGFloat marginX = 30;
    CGFloat marginY = 2;
    
    CGFloat x = cell.contentView.frame.size.width - size.width - 2 * paddingX - marginX;
    CGFloat y = cell.textLabel.bounds.origin.y + marginY;
    
    CGRect frame = CGRectMake(x, y, size.width + 2 * paddingX, size.height + 2 * paddingY);
    
    UILabel *lastActivityLabel = [[UILabel alloc] initWithFrame:frame];
    lastActivityLabel.text = lastActivity;
    lastActivityLabel.font = font;
    lastActivityLabel.tag = 666;
    
    [[cell.contentView viewWithTag:666] removeFromSuperview];
    [cell.contentView addSubview:lastActivityLabel];
    
}

- (void)addMapToCell:(UITableViewCell *)cell {
    if (self.task.terminal) {
        CLLocationCoordinate2D terminalCoordinate = CLLocationCoordinate2DMake([self.task.terminal.location.latitude doubleValue], [self.task.terminal.location.longitude doubleValue]);
        MKCoordinateSpan span;
        span.longitudeDelta = 0.01;
        span.latitudeDelta = 0.01;
        
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 300, 158)];
        [mapView setRegion:MKCoordinateRegionMake(terminalCoordinate, span)];
        mapView.showsUserLocation = YES;
        [mapView addAnnotation:[STTTMapAnnotation initWithCoordinate:terminalCoordinate]];
        
        mapView.layer.cornerRadius = 10.0;
        
        mapView.userInteractionEnabled = NO;
        
        [cell.contentView addSubview:mapView];
    }

}



#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 44;
            break;
        case 1:
            return 44;
            break;
        case 2:
            return 44;
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    return 44;
                    break;
                case 1:
                    return 160;
                    break;
                    
                default:
                    return 0;
                    break;
            }
            break;
            
        default:
            return 0;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case 0:
            // do nothing
            break;
        case 1:
            if (![self.task.visited boolValue]) {
                [self buttonsBehaviorInCell:[tableView cellForRowAtIndexPath:indexPath]];
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
    
    if (!self.location) {
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
    } else {
        [self addTaskLocation];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationAutomatic];

    }

}

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
        self.task.visited = [NSNumber numberWithBool:YES];
        [self saveDocument];
    } else {
        NSLog(@"No task location");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showComment"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTCommentVC class]] && [sender isKindOfClass:[STTTAgentTask class]]) {
            [(STTTCommentVC *)segue.destinationViewController setTask:(STTTAgentTask *)sender];
        }
    } else if ([segue.identifier isEqualToString:@"goToTerminal"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTTerminalTVC class]] && [sender isKindOfClass:[STTTAgentTerminal class]]) {
            [(STTTTerminalTVC *)segue.destinationViewController setTerminal:(STTTAgentTerminal *)sender];
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
