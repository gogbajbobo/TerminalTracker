//
//  STTTMapAnnotation.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTMapAnnotation.h"

@interface STTTMapAnnotation()

@property (nonatomic) CLLocationCoordinate2D center;

@end

@implementation STTTMapAnnotation

+ (STTTMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    STTTMapAnnotation *annotation = [[STTTMapAnnotation alloc] init];
    annotation.center = coordinate;
    return annotation;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.center;
}


@end
