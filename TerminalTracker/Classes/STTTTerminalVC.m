//
//  STTTTerminalVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTTerminalVC.h"
#import "STTTTerminalLocation.h"
#import "STTTAgentTask+remainingTime.h"
#import <STManagedTracker/STSessionManager.h>
//#import "STTTTaskVC.h"
#import "STTTMapAnnotation.h"

@interface STTTTerminalVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *srcSystemNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *errorTextView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastActivityTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *sortedTasks;

@end

@implementation STTTTerminalVC

- (NSArray *)sortedTasks {
    if (!_sortedTasks) {
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"doBefore" ascending:YES selector:@selector(compare:)];
        _sortedTasks = [self.terminal.tasks sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    }
    return _sortedTasks;
}

- (void)viewInit {

    if ([[self.backgroundColors valueForKey:@"terminal"] isKindOfClass:[UIColor class]]) {
        self.view.backgroundColor = [self.backgroundColors valueForKey:@"terminal"];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }

    [self labelsInit];
    [self mapInit];
    [self tableViewInit];
}

- (void)labelsInit {
    if (self.terminal) {
        self.codeLabel.text = self.terminal.code;
        self.srcSystemNameLabel.text = self.terminal.srcSystemName;
        self.errorTextView.text = self.terminal.errorText;
        self.addressLabel.text = self.terminal.address;

        if (self.terminal.lastActivityTime) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            self.lastActivityTimeLabel.text = [NSString stringWithFormat:@"LAT: %@", [dateFormatter stringFromDate:self.terminal.lastActivityTime]];
        } else {
            self.lastActivityTimeLabel.text = @"LAT: Нет данных";
        }
    }
}

- (void)mapInit {
    if (self.terminal) {
        CLLocationCoordinate2D terminalCoordinate = CLLocationCoordinate2DMake([self.terminal.location.latitude doubleValue], [self.terminal.location.longitude doubleValue]);
        MKCoordinateSpan span;
        span.longitudeDelta = 0.01;
        span.latitudeDelta = 0.01;
        [self.mapView setRegion:MKCoordinateRegionMake(terminalCoordinate, span)];
        self.mapView.showsUserLocation = YES;
        [self.mapView addAnnotation:[STTTMapAnnotation initWithCoordinate:terminalCoordinate]];
    }
}

- (void)tableViewInit {
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView reloadData];
}


#pragma mark - tableview datasource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.terminal.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"terminalTaskCell"];
    cell.textLabel.text = [(STTTAgentTask *)[self.sortedTasks objectAtIndex:indexPath.row] terminalBreakName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"goToTask" sender:[self.sortedTasks objectAtIndex:indexPath.row]];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"goToTask"]) {
//        if ([segue.destinationViewController isKindOfClass:[STTTTaskVC class]] && [sender isKindOfClass:[STTTAgentTask class]]) {
//            [(STTTTaskVC *)segue.destinationViewController setTask:(STTTAgentTask *)sender];
//            [(STTTTaskVC *)segue.destinationViewController setBackgroundColors:self.backgroundColors];
//        }
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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
