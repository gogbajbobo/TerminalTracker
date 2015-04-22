//
//  STAgentTaskDefectCodeService.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 22/04/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTTAgentTask.h"

@interface STAgentTaskDefectCodeService : NSObject

// Array of Dictionaries -> keys: repairName, repairXid, isChecked
+ (NSArray*)getListOfDefectsForTask:(STTTAgentTask*)task;

+ (void)updateDefectsForTask:(STTTAgentTask *)task fromList:(NSArray *)defectsList;

@end
