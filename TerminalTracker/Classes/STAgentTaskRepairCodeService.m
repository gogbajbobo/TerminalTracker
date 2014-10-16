//
//  STAgentTaskRepairCodeService.m
//  TerminalTracker
//
//  Created by Sergey on 15/10/2014.
//  Copyright (c) 2014 Maxim Grigoriev. All rights reserved.
//

#import "STAgentTaskRepairCodeService.h"

@implementation STAgentTaskRepairCodeService

+ (NSArray *)getListOfRepairsForTask:(STTTAgentTask *)task {
    // get all repairs
    // get repairs for task
    // intersect and fill Array
    
    // Array of Dictionaries -> keys: repairName, repairXid, isChecked
    
    return @[@{@"repairName": @"Не работает", @"repairXid": @"11111111", @"isChecked": [NSNumber numberWithBool:YES]}];
}

+ (void)updateRepairsForTask:(STTTAgentTask *)task fromList:(NSArray *)repairsList {
    // read data, modify DB
}


@end

