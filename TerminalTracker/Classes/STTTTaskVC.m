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

@interface STTTTaskVC ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *terminalBreakNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *doBeforeLabel;
@property (weak, nonatomic) IBOutlet UIButton *terminalButton;
@property (weak, nonatomic) IBOutlet UIButton *geoLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *visitedButton;

@end

@implementation STTTTaskVC

- (IBAction)terminalButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"goToTerminal" sender:self.task.terminal];
}

- (IBAction)geoLocationButtonPressed:(id)sender {
}

- (IBAction)visitedButtonPressed:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"goToTerminal"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTTerminalVC class]] && [sender isKindOfClass:[STTTAgentTerminal class]]) {
            [(STTTTerminalVC *)segue.destinationViewController setTerminal:(STTTAgentTerminal *)sender];
        }
    }
    
}

- (void)viewInit {
    [self mapViewInit];
    [self labelsInit];
    [self buttonsInit];
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
    if ([self.task.visited boolValue]) {
        [self.visitedButton setTitleColor:[UIColor greenColor] forState:UIControlStateDisabled];
        [self.geoLocationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        self.geoLocationButton.enabled = NO;
    } else {
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
