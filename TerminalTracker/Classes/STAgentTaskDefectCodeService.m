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

+ (NSInteger)getNumberOfSelectedDefectsForTask:(STTTAgentTask *)task {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isdeleted != YES"];
    NSSet *defects = [task.defects filteredSetUsingPredicate:predicate];

    return defects.count;
    
}

+ (NSArray*)getListOfDefectsForTask:(STTTAgentTask*)task {
    
    NSMutableArray* resultArray = [NSMutableArray array];
    
    NSManagedObjectContext* managedObjectContext = [[STSessionManager sharedManager] currentSession].document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentDefectCode class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSError *error;
    NSArray *fetchResult = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error) {
        
        for(STTTAgentDefectCode *defect in fetchResult) {
            
            NSMutableDictionary *defectData = [NSMutableDictionary dictionary];
            defectData[@"name"] = (defect.name == nil) ? @"????" : defect.name;
            defectData[@"defectXid"] = defect.xid;
            NSNumber *isChecked = @NO;
            
            for(STTTAgentTaskDefect *taskDefect in task.defects) {
                
                if(taskDefect.defectCode == defect && ![taskDefect.isdeleted boolValue]) {
                    isChecked = @YES;
                    break;
                }
                
            }
            
            defectData[@"isChecked"] = isChecked;
            
            [resultArray addObject:[defectData copy]];
            
        }
        
    }

    return [resultArray copy];

}

+ (void)updateDefectsForTask:(STTTAgentTask *)task fromList:(NSArray *)defectsList {
    
    STManagedDocument *document = [[STSessionManager sharedManager] currentSession].document;
    NSManagedObjectContext *context = document.managedObjectContext;
    
    for (NSDictionary *defectData in defectsList) {
        
        BOOL addNew = YES;
        
        BOOL isChecked = [defectData[@"isChecked"] boolValue];
        NSData *defectXid = defectData[@"defectXid"];

        for (STTTAgentTaskDefect *taskDefect in task.defects) {
            
            if(![taskDefect.defectCode.xid isEqualToData:defectXid]) {
                continue;
            }
            
            BOOL isdeleted = [taskDefect.isdeleted boolValue];
            
            addNew = addNew && isdeleted && isChecked;
            
            if (!(isChecked || isdeleted)) {
                
                taskDefect.isdeleted = @(YES);
                task.ts = [NSDate date];
                
            }
            
        }
        
        if (addNew && isChecked) {
            
            STTTAgentTaskDefect *taskDefect = (STTTAgentTaskDefect *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STTTAgentTaskDefect class]) inManagedObjectContext:context];
            taskDefect.task = task;
            taskDefect.defectCode = [STAgentTaskDefectCodeService findDefectCodeByXid:defectXid inContext:context];
            
        }
        
    }
    
    if (context.hasChanges) {
        NSError* error;
        [context save:&error];
    }
    
}

+ (STTTAgentDefectCode *)findDefectCodeByXid:(NSData *)xid inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentDefectCode class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xid];
    
    NSError *error;
    NSArray *fetchResult = [context executeFetchRequest:request error:&error];
    
    return (error) ? nil : [fetchResult lastObject];
    
}


@end
