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

+ (STTTAgentRepairCode*) findRepairCodeByXid:(NSData*)xid inContext:(NSManagedObjectContext*)context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STTTAgentRepairCode"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xid];
    NSError *error;
    NSArray *fetchResult = [context executeFetchRequest:request error:&error];
    
    if(error) {
        return nil;
    }
    return [fetchResult lastObject];
}

+ (int)getNumberOfSelectedRepairsForTask:(STTTAgentTask *)task {
    int repairsCnt = 0;
    for (STTTAgentTaskRepair* taskRepair in task.repairs) {
        if (![taskRepair.isdeleted boolValue]) {
            repairsCnt++;
        }
    }
    return repairsCnt;
}

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
        [repairData setObject:repair.repairName == nil ? @"????" : repair.repairName forKey:@"repairName"];
        [repairData setObject:repair.xid forKey:@"repairXid"];
        NSNumber* isChesked = @NO;
        for(STTTAgentTaskRepair* taskRepair in task.repairs) {
            if(taskRepair.repairCode == repair && ![taskRepair.isdeleted boolValue]) {
                isChesked = @YES;
                break;
            }
        }
        [repairData setObject:isChesked forKey:@"isChecked"];
        [resultArray addObject:[repairData copy]];
    }
    
    
    return [resultArray copy];
}

+ (void)updateRepairsForTask:(STTTAgentTask *)task fromList:(NSArray *)repairsList {
    
    NSManagedObjectContext* managedObjectContext = [[STSessionManager sharedManager] currentSession].document.managedObjectContext;
    
    for (NSDictionary *repairData in repairsList) {
        
        BOOL addNew = YES;

        BOOL isChecked = [repairData[@"isChecked"] boolValue];
        NSData *repairXid = repairData[@"repairXid"];

        for (STTTAgentTaskRepair *taskRepair in task.repairs) {
            
            if(![taskRepair.repairCode.xid isEqualToData:repairXid]) {
                continue;
            }
            
            addNew = NO;
            
            if (!isChecked) {
                
                taskRepair.isdeleted = @(!isChecked);
                task.ts = [NSDate date];
                
            } else {
                addNew = YES;
            }
            
            break;
            
        }
        
        if(addNew && isChecked) {
            
            STTTAgentTaskRepair* entity = (STTTAgentTaskRepair *)[NSEntityDescription insertNewObjectForEntityForName:@"STTTAgentTaskRepair" inManagedObjectContext:managedObjectContext];
            entity.task = task;
            entity.repairCode = [STAgentTaskRepairCodeService findRepairCodeByXid:repairXid inContext:managedObjectContext];
            
        }
        
    }
    
    if (managedObjectContext.hasChanges) {
        NSError* error;
        [managedObjectContext save:&error];
    }
}

@end

