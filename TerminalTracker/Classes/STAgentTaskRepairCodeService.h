//
//  STAgentTaskRepairCodeService.h
//  TerminalTracker
//
//  Created by Sergey on 15/10/2014.
//  Copyright (c) 2014 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTTAgentTask.h"

@interface STAgentTaskRepairCodeService : NSObject

// Array of Dictionaries -> keys: repairName, repairXid, isChecked
+ (NSArray*)getListOfRepairsForTask:(STTTAgentTask*)task;
+ (void) updateRepairsForTask:(STTTAgentTask*)task fromList:(NSArray*)repairsList;

@end
