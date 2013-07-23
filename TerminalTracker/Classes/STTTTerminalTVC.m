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
#import "STTTAgentTask+remainingTime.h"

@interface STTTTerminalTVC ()

@end

@implementation STTTTerminalTVC

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 3;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
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
            break;
        case 2:
            if (self.terminal.tasks.count > 0) {
                sectionTitle = @"Список задач:";
            }
            break;
            
        default:
            break;
    }
    return sectionTitle;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"terminalCell";
    UITableViewCell *cell = [UITableViewCell alloc];
    
    switch (indexPath.section) {
        case 0:
            cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [self addMapToCell:cell];
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell = [cell initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                    [self addInfoToCell:cell];
                    break;
                case 1:
                    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [self addAddressToCell:cell];
                    break;
                case 2:
                    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [self addErrorTextToCell:cell];
                    break;
                    
                default:
                    break;
            }
            break;
        case 2:
            cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [self addButtonsToCell:cell];
            break;
            
        default:
            cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            break;
    }
    
    return cell;
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

- (void)addInfoToCell:(UITableViewCell *)cell {

    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"doBefore" ascending:YES selector:@selector(compare:)];
    NSArray *sortedTasks = [self.terminal.tasks sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    STTTAgentTask *lastTask;
    if (sortedTasks.count > 0) {
        lastTask = (STTTAgentTask *)[sortedTasks objectAtIndex:0];
    }

    NSString *code = self.terminal.code ? self.terminal.code : @"Н/Д";
//    NSString *sysName = self.terminal.srcSystemName ? [NSString stringWithFormat:@" / %@", self.terminal.srcSystemName] : @"";
    NSString *breakName = lastTask.terminalBreakName ? [NSString stringWithFormat:@" / %@", lastTask.terminalBreakName] : @"";
    
//    cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@", code, sysName, breakName];
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", code, breakName];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.terminal.lastActivityTime];
    
    if (timeInterval > 0 && timeInterval <= 24 * 3600) {
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else if (timeInterval <= 7 * 24 * 3600) {
        dateFormatter.dateFormat = @"EEEE";
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    cell.detailTextLabel.text = [dateFormatter stringFromDate:self.terminal.lastActivityTime];

}

- (void)addMapToCell:(UITableViewCell *)cell {

    CLLocationCoordinate2D terminalCoordinate = CLLocationCoordinate2DMake([self.terminal.location.latitude doubleValue], [self.terminal.location.longitude doubleValue]);
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


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 160;
            break;
        case 1:
            switch (indexPath.row) {
                case 2:
                    return 66;
                    break;
                
                default:
                    return 44;
                    break;
            }
            break;
        case 2:
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
            // show terminal
            break;
        case 2:
//            if (![self.task.visited boolValue]) {
//                [self buttonsBehaviorInCell:[tableView cellForRowAtIndexPath:indexPath]];
//            }
            break;
        case 3:
//            [self performSegueWithIdentifier:@"showComment" sender:self.task];
            break;
            
        default:
            break;
    }
    
}


@end
