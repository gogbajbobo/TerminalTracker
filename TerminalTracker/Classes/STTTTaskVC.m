//
//  STTTTaskVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTTaskVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "STTTAgentTerminal.h"
#import "STTTTerminalLocation.h"
#import "STTTMapAnnotation.h"
#import "STTTTerminalVC.h"
#import "STTTLocationController.h"
#import "STTTTaskLocation.h"
#import <STManagedTracker/STSession.h>
#import "STTTCommentVC.h"

@interface STTTTaskVC ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *terminalBreakNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *doBeforeLabel;
@property (weak, nonatomic) IBOutlet UIButton *terminalButton;
@property (weak, nonatomic) IBOutlet UIButton *geoLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *visitedButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic) BOOL waitingLocation;

@end

@implementation STTTTaskVC

- (IBAction)terminalButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"goToTerminal" sender:self.task.terminal];
}

- (IBAction)geoLocationButtonPressed:(id)sender {
    self.waitingLocation = YES;
    [self showSpinner];
    [[STTTLocationController sharedLC] getLocation];
}

- (IBAction)visitedButtonPressed:(id)sender {
    [self addTaskLocation];
}

- (IBAction)commentButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showComment" sender:self.task];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"goToTerminal"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTTerminalVC class]] && [sender isKindOfClass:[STTTAgentTerminal class]]) {
            [(STTTTerminalVC *)segue.destinationViewController setTerminal:(STTTAgentTerminal *)sender];
            [(STTTTerminalVC *)segue.destinationViewController setBackgroundColors:self.backgroundColors];
        }
    } else if ([segue.identifier isEqualToString:@"showComment"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTCommentVC class]] && [sender isKindOfClass:[STTTAgentTask class]]) {
            [(STTTCommentVC *)segue.destinationViewController setTask:(STTTAgentTask *)sender];
            [(STTTCommentVC *)segue.destinationViewController setBackgroundColors:self.backgroundColors];
        }
    }
    
}

- (void)currentLocationUpdated:(NSNotification *)notification {
    if (self.waitingLocation) {
        self.location = [[STTTLocationController sharedLC] currentLocation];
        self.waitingLocation = NO;
        [self removeSpinner];
        self.visitedButton.enabled = YES;
    }
}

- (void)showSpinner {
    [self.geoLocationButton setTitle:@"" forState:UIControlStateNormal];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.tag = 1;
    [spinner startAnimating];
    spinner.frame = self.geoLocationButton.bounds;
    [self.geoLocationButton addSubview:spinner];
    self.geoLocationButton.enabled = NO;
}

- (void)removeSpinner {
    if ([[self.geoLocationButton viewWithTag:1] isKindOfClass:[UIActivityIndicatorView class]]) {
        [[self.geoLocationButton viewWithTag:1] removeFromSuperview];
        [self.geoLocationButton setTitle:@"Геометка" forState:UIControlStateNormal];
    }
}

- (void)addTaskLocation {
    if (self.location) {
        STTTTaskLocation *taskLocation = (STTTTaskLocation *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STTTTaskLocation class]) inManagedObjectContext:[[STSessionManager sharedManager] currentSession].document.managedObjectContext];
        taskLocation.latitude = [NSNumber numberWithDouble:self.location.coordinate.latitude];
        taskLocation.longitude = [NSNumber numberWithDouble:self.location.coordinate.longitude];
        self.task.visitLocation = taskLocation;
        self.task.visited = [NSNumber numberWithBool:YES];
        [self.visitedButton setTitleColor:[UIColor greenColor] forState:UIControlStateDisabled];
        self.visitedButton.enabled = NO;
        [[[STSessionManager sharedManager] currentSession].document saveDocument:^(BOOL success) {
            if (!success) {
                NSLog(@"save task fail");
            }
        }];
    } else {
        NSLog(@"No task location");
    }
}

- (void)viewInit {
    if ([[self.backgroundColors valueForKey:@"task"] isKindOfClass:[UIColor class]]) {
        self.view.backgroundColor = [self.backgroundColors valueForKey:@"task"];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    [self mapViewInit];
    [self labelsInit];
    [self buttonsInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocationUpdated:) name:@"currentLocationUpdated" object:nil];
}

- (void)mapViewInit {
    if (self.task.terminal) {
        CLLocationCoordinate2D terminalCoordinate = CLLocationCoordinate2DMake([self.task.terminal.location.latitude doubleValue], [self.task.terminal.location.longitude doubleValue]);
        MKCoordinateSpan span;
        span.longitudeDelta = 0.01;
        span.latitudeDelta = 0.01;
        [self.mapView setRegion:MKCoordinateRegionMake(terminalCoordinate, span)];
        self.mapView.showsUserLocation = YES;
        [self.mapView addAnnotation:[STTTMapAnnotation initWithCoordinate:terminalCoordinate]];
    }
}

- (void)labelsInit {
    self.terminalBreakNameLabel.text = self.task.terminalBreakName;
    self.doBeforeLabel.text = [NSString stringWithFormat:@"%@", self.task.doBefore];
    if (self.task.terminal) {
        self.addressLabel.text = self.task.terminal.address;
    }
    
}

- (void)buttonsInit {
    if (self.task.terminal) {
        self.terminalButton.enabled = YES;
    } else {
        self.terminalButton.enabled = NO;
    }
    self.visitedButton.enabled = NO;
    [self.geoLocationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    if ([self.task.visited boolValue]) {
        [self.visitedButton setTitleColor:[UIColor greenColor] forState:UIControlStateDisabled];
        self.geoLocationButton.enabled = NO;
        
// ____________testing
        self.geoLocationButton.enabled = YES;
// ___________________
        
    } else {
        [self.visitedButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        self.geoLocationButton.enabled = YES;
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
