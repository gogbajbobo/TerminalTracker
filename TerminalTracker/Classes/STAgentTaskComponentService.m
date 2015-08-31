//
//  STAgentTaskComponentService.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 04/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import "STAgentTaskComponentService.h"
#import "STSessionManager.h"
#import "STSession.h"
#import "STTTAgentTaskComponent.h"
#import "STTTAgentComponent.h"
#import "STTTComponentsController.h"


@implementation STAgentTaskComponentService

+ (NSInteger)getNumberOfSelectedComponentsForTask:(STTTAgentTask *)task {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isdeleted != YES && component != %@", nil];
    NSSet *components = [task.components filteredSetUsingPredicate:predicate];
    
    return components.count;

}

+ (NSArray *)getListOfComponentsForTask:(STTTAgentTask *)task {
    
    NSMutableArray* resultArray = [NSMutableArray array];
    
    NSManagedObjectContext* managedObjectContext = [[STSessionManager sharedManager] currentSession].document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentComponent class])];
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"shortName" ascending:YES];
    NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    request.sortDescriptors = @[nameDescriptor, idDescriptor];
    
    NSDate *expiredDate = [STTTComponentsController expiredDate];
    request.predicate = [NSPredicate predicateWithFormat:@"(cts > %@) OR (taskComponent.task == %@)", expiredDate, task];
    
    NSError *error;
    NSArray *fetchResult = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error) {
        
        for(STTTAgentComponent *component in fetchResult) {
            
            NSMutableDictionary *componentData = [NSMutableDictionary dictionary];
            componentData[@"shortName"] = (component.shortName == nil) ? @"????" : component.shortName;
            componentData[@"serial"] = (component.serial == nil) ? @"????" : component.serial;
            componentData[@"componentXid"] = component.xid;
            
            componentData[@"isUsed"] = (!component.taskComponent.isdeleted.boolValue &&
                                        component.taskComponent.task &&
                                        component.taskComponent.task != task) ? @YES : @NO;
            
            NSNumber *isChecked = @NO;
            
            for(STTTAgentTaskComponent *taskComponent in task.components) {
                
                if(taskComponent.component == component && ![taskComponent.isdeleted boolValue]) {
                    isChecked = @YES;
                    break;
                }
                
            }
            
            componentData[@"isChecked"] = isChecked;
            
            [resultArray addObject:[componentData copy]];
            
        }
        
    }
    
    return [resultArray copy];

}

+ (void)updateComponentsForTask:(STTTAgentTask *)task fromList:(NSArray *)componentsList {
    
    STManagedDocument *document = [[STSessionManager sharedManager] currentSession].document;
    NSManagedObjectContext *context = document.managedObjectContext;
    
    for (NSDictionary *componentData in componentsList) {
        
        BOOL addNew = YES;
        
        BOOL isChecked = [componentData[@"isChecked"] boolValue];
        NSData *componentXid = componentData[@"componentXid"];
        
        for (STTTAgentTaskComponent *taskComponent in task.components) {
            
            if(![taskComponent.component.xid isEqualToData:componentXid]) {
                continue;
            }
            
            BOOL isdeleted = taskComponent.isdeleted.boolValue;
            
            addNew = addNew && isdeleted && isChecked;
            
            if (!(isChecked || isdeleted)) {
                
                taskComponent.isdeleted = @(YES);
                task.ts = [NSDate date];
                
            }
            
        }
        
        if (addNew && isChecked) {
            
            STTTAgentTaskComponent *taskComponent = (STTTAgentTaskComponent *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STTTAgentTaskComponent class]) inManagedObjectContext:context];
            taskComponent.task = task;
            taskComponent.component = [STAgentTaskComponentService findComponentByXid:componentXid inContext:context];
            
            task.ts = [NSDate date];

        }
        
    }
    
    [document saveDocument:^(BOOL success) {
        
    }];
    
//    if (context.hasChanges) {
//        NSError* error;
//        [context save:&error];
//    }

}

+ (STTTAgentComponent *)findComponentByXid:(NSData *)xid inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentComponent class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xid];
    
    NSError *error;
    NSArray *fetchResult = [context executeFetchRequest:request error:&error];
    
    return (error) ? nil : [fetchResult lastObject];
    
}


@end
