//
//  STTTTerminalVC.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTTAgentTerminal.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface STTTTerminalVC : UIViewController

@property (nonatomic, strong) STTTAgentTerminal *terminal;

@end




@interface STTTMapAnnotation : NSObject <MKAnnotation>

+ (STTTMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
