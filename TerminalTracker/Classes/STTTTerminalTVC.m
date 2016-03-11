//
//  STTTTerminalTVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/22/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTTerminalTVC.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "STTTMapAnnotation.h"
#import "STTTTerminalLocation.h"
#import "STTTAgentTask.h"
#import "STTTTaskTVC.h"
#import "STUtilities.h"
#import "STTTAgentTask+cellcoloring.h"

@interface STTTTerminalTVC ()

@property (nonatomic, strong) NSArray *sortedTasks;


@end


@implementation STTTTerminalTVC

- (NSArray *)sortedTasks {
    
    if (!_sortedTasks) {
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"doBefore"
                                                                     ascending:NO
                                                                      selector:@selector(compare:)];
        
        _sortedTasks = [self.terminal.tasks sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        
    }
    return _sortedTasks;
    
}

- (id)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = self.terminal.code;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 6;
            break;
        case 1:
            return self.terminal.tasks.count;
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = nil;
    switch (section) {
        case 0:
            break;
        case 1:
            if (self.terminal.tasks.count > 0) {
                sectionTitle = @"Задачи:";
            }
            break;
            
        default:
            break;
    }
    return sectionTitle;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"terminalCell";
    UITableViewCell *cell = [UITableViewCell alloc];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell = [cell initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
                    [self addSrcSystemNameToCell:cell];
                    break;
                case 1:
                    cell = [cell initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
                    [self addLastActivityTimeToCell:cell];
                    break;
                case 2:
                    cell = [cell initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
                    [self addLastPaymentTimeToCell:cell];
                    break;
                case 3:
                    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [self addMapToCell:cell];
                    break;
                case 4:
                    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [self addAddressToCell:cell];
                    break;
                case 5:
                    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [self addErrorTextToCell:cell];
                    break;

                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                default:
                    cell = [cell initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                    STTTAgentTask *task = (STTTAgentTask *)[self.sortedTasks objectAtIndex:indexPath.row];
                    [self addTask:task toCell:cell];
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

- (void)addLastActivityTimeToCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Сигнал:";
    cell.detailTextLabel.text = [STUtilities stringWithRelativeDateFromDate:self.terminal.lastActivityTime];
}

- (void)addLastPaymentTimeToCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Платёж:";
    cell.detailTextLabel.text = [STUtilities stringWithRelativeDateFromDate:self.terminal.lastPaymentTime];
}

- (void)addSrcSystemNameToCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Система:";
    cell.detailTextLabel.text = self.terminal.srcSystemName;
}

- (void)addTask:(STTTAgentTask *)task toCell:(UITableViewCell *)cell {
    cell.textLabel.text = task.terminalBreakName;
    cell.detailTextLabel.text = [STUtilities stringWithRelativeDateFromDate:task.doBefore];
    cell.backgroundColor = [task getBackgroundColorForDisplaying];
    cell.textLabel.textColor = [task getTextColorForDisplaying];
    cell.detailTextLabel.textColor = cell.textLabel.textColor;
}

- (void)addErrorTextToCell:(UITableViewCell *)cell {
    
    cell.textLabel.text = self.terminal.errorText;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

}

- (void)addAddressToCell:(UITableViewCell *)cell {
    
    cell.textLabel.text = self.terminal.address;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
}

- (void)addMapToCell:(UITableViewCell *)cell {
    
    CLLocationCoordinate2D terminalCoordinate = CLLocationCoordinate2DMake([self.terminal.location.latitude doubleValue], [self.terminal.location.longitude doubleValue]);
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


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                    
                default:
                    return 44;
                    break;
                    
                case 3:
                    return 160;
                    break;
                    
            }
            break;
        case 1:
            return 44;
            break;
            
        default:
            return 0;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            // show full map
            break;
        case 1:
            [self performSegueWithIdentifier:@"goToTask" sender:[self.sortedTasks objectAtIndex:indexPath.row]];
            break;
            
        default:
            break;
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"goToTask"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTTaskTVC class]] && [sender isKindOfClass:[STTTAgentTask class]]) {
            [(STTTTaskTVC *)segue.destinationViewController setTask:(STTTAgentTask *)sender];
        }
    }
    
}



@end
