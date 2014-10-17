//
//  STAgentTaskRepairCodeService.m
//  TerminalTracker
//
//  Created by Sergey on 15/10/2014.
//  Copyright (c) 2014 Maxim Grigoriev. All rights reserved.
//

#import "STAgentTaskRepairCodeService.h"
#import "STTTAgentRepairCode.h"
#import "STSessionManager.h"
#import "STSession.h"
#import "STTTAgentTaskRepair.h"

@implementation STAgentTaskRepairCodeService

+ (NSArray *)getListOfRepairsForTask:(STTTAgentTask *)task {
    NSMutableArray* resultArray = [NSMutableArray array];
    
    NSManagedObjectContext* managedObjectContext = [[STSessionManager sharedManager] currentSession].document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentRepairCode class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"repairName" ascending:YES]];
    NSError *error;
    NSArray *fetchResult = [managedObjectContext executeFetchRequest:request error:&error];
    
    if(error) {
        return [resultArray copy];
    }
    
    for(STTTAgentRepairCode* repair in fetchResult) {
        NSMutableDictionary* repairData = [NSMutableDictionary dictionary];
        [repairData setObject:repair.repairName forKey:@"repairName"];
        [repairData setObject:repair.xid forKey:@"repairXid"];
        [repairData setObject:[NSNumber numberWithBool:[task.repairs containsObject:repair]] forKey:@"isChecked"];
    }
    
    // get all repairs
    // get repairs for task
    // intersect and fill Array
    
    // Array of Dictionaries -> keys: repairName, repairXid, isChecked
    
    return [resultArray copy];//@[@{@"repairName": @"Не работает", @"repairXid": @"11111111", @"isChecked": [NSNumber numberWithBool:YES]}];
}

+ (void)updateRepairsForTask:(STTTAgentTask *)task fromList:(NSArray *)repairsList {
    // read data, modify DB
}


@end

