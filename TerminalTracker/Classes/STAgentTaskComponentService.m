//
//  STAgentTaskComponentService.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 04/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import "STAgentTaskComponentService.h"

@implementation STAgentTaskComponentService

+ (NSInteger)getNumberOfSelectedComponentsForTask:(STTTAgentTask *)task {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isdeleted != YES"];
    NSSet *defects = [task.components filteredSetUsingPredicate:predicate];
    
    return defects.count;

}


@end
