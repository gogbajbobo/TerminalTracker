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
    
    STManagedDocument *document = [[STSessionManager sharedManager] currentSession].document;
    NSManagedObjectContext *context = document.managedObjectContext;
    
    [context performBlockAndWait:^{
       
        for (NSDictionary *repairData in repairsList) {
            
            BOOL addNew = YES;
            
            BOOL isChecked = [repairData[@"isChecked"] boolValue];
            NSData *repairXid = repairData[@"repairXid"];
            
            for (STTTAgentTaskRepair *taskRepair in task.repairs) {
                
                if(![taskRepair.repairCode.xid isEqualToData:repairXid]) {
                    continue;
                }
                
                BOOL isdeleted = taskRepair.isdeleted.boolValue;
                
                addNew = addNew && isdeleted && isChecked;
                
                if (!(isChecked || isdeleted)) {
                    
                    taskRepair.isdeleted = @(YES);
                    task.ts = [NSDate date];
                    
                }
                
            }
            
            if(addNew && isChecked) {
                
                NSString *taskRepairEntityName = NSStringFromClass([STTTAgentTaskRepair class]);
                
                STTTAgentTaskRepair *entity = (STTTAgentTaskRepair *)[NSEntityDescription insertNewObjectForEntityForName:taskRepairEntityName
                                                                                                   inManagedObjectContext:context];
                entity.task = task;
                entity.repairCode = [STAgentTaskRepairCodeService findRepairCodeByXid:repairXid inContext:context];
                
                task.ts = [NSDate date];
                
            }
            
        }
        
    }];
    
    [document saveDocument:^(BOOL success) {
        
    }];
    
}

@end

