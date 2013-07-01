//
//  STTTTaskLocation.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/1/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STLocation.h"

@class STTTAgentTask;

@interface STTTTaskLocation : STLocation

@property (nonatomic, retain) STTTAgentTask *task;

@end
