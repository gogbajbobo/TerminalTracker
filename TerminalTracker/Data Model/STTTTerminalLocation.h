//
//  STTTTerminalLocation.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/1/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STLocation.h"

@class STTTAgentTerminal;

@interface STTTTerminalLocation : STLocation

@property (nonatomic, retain) STTTAgentTerminal *terminal;

@end
