//
//  STAgentTaskDefectCodeService.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 22/04/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import "STAgentTaskDefectCodeService.h"
#import "STTTAgentDefectCode.h"
#import "STSessionManager.h"
#import "STSession.h"
#import "STTTAgentTaskDefect.h"

@implementation STAgentTaskDefectCodeService

+ (NSArray*)getListOfDefectsForTask:(STTTAgentTask*)task {
    
    NSMutableArray* resultArray = [NSMutableArray array];
    
    NSManagedObjectContext* managedObjectContext = [[STSessionManager sharedManager] currentSession].document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentDefectCode class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error;
    NSArray *fetchResult = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error) {
        
        for(STTTAgentDefectCode *defect in fetchResult) {
            
            NSMutableDictionary* defectData = [NSMutableDictionary dictionary];
            [defectData setObject:(defect.name == nil) ? @"????" : defect.name forKey:@"name"];
            [defectData setObject:defect.xid forKey:@"defectXid"];
            NSNumber *isChecked = @NO;
            
            for(STTTAgentTaskDefect *taskDefect in task.defects) {
                
                if(taskDefect.defectCode == defect && ![taskDefect.isdeleted boolValue]) {
                    isChecked = @YES;
                    break;
                }
                
            }
            
            [defectData setObject:isChecked forKey:@"isChecked"];
            [resultArray addObject:[defectData copy]];
            
        }
        
    }

    return [resultArray copy];

}


@end
