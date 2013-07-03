//
//  STTTMapAnnotation.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface STTTMapAnnotation : NSObject <MKAnnotation>

+ (STTTMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
