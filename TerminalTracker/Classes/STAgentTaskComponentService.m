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
#import "STTTAgentTerminal.h"

#import "STTTComponentsController.h"


@implementation STAgentTaskComponentService

+ (NSInteger)getNumberOfSelectedComponentsForTask:(STTTAgentTask *)task {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isdeleted == NO && component != nil && component.wasInitiallyInstalled == NO && component.isInstalled == YES"];
    NSSet *components = [task.components filteredSetUsingPredicate:predicate];
    
    return components.count;

}

+ (NSArray *)getListOfComponentsForTask:(STTTAgentTask *)task inGroup:(STTTAgentComponentGroup *)group {
    
//    NSMutableArray* resultArray = [NSMutableArray array];
    
    NSManagedObjectContext* managedObjectContext = [[STSessionManager sharedManager] currentSession].document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentComponent class])];
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"shortName" ascending:YES];
    NSSortDescriptor *serialDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"serial" ascending:YES];
    NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    request.sortDescriptors = @[nameDescriptor, serialDescriptor, idDescriptor];
    
    NSDate *expiredDate = [STTTComponentsController expiredDate];
    
    if (group) {
        request.predicate = [NSPredicate predicateWithFormat:@"componentGroup == %@ && ((cts > %@ && ANY terminalComponents.terminal == nil) || (ANY terminalComponents.terminal == %@))", group, expiredDate, task.terminal];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"(cts > %@ && ANY terminalComponents.terminal == nil) || (ANY terminalComponents.terminal == %@)", expiredDate, task.terminal];
    }
    
    NSError *error;
    NSArray *fetchResult = [managedObjectContext executeFetchRequest:request error:&error];
    
    return fetchResult;
    
//    if (!error) {
//        
//        for (STTTAgentComponent *component in fetchResult) {
//            
//            NSMutableDictionary *componentData = [NSMutableDictionary dictionary];
//            componentData[@"shortName"] = (component.shortName == nil) ? @"????" : component.shortName;
//            componentData[@"serial"] = (component.serial == nil) ? @"????" : component.serial;
//            componentData[@"componentXid"] = component.xid;
//            componentData[@"component"] = component;
//            
//            componentData[@"isUsed"] = (!component.taskComponent.isdeleted.boolValue &&
//                                        component.taskComponent.task &&
//                                        component.taskComponent.task != task) ? @YES : @NO;
//            
//            NSNumber *isChecked = @NO;
//            
//            for(STTTAgentTaskComponent *taskComponent in task.components) {
//                
//                if(taskComponent.component == component && ![taskComponent.isdeleted boolValue]) {
//                    isChecked = @YES;
//                    break;
//                }
//                
//            }
//            
//            componentData[@"isChecked"] = isChecked;
//            
//            [resultArray addObject:[componentData copy]];
//            
//        }
//        
//    }
//    
//    return [resultArray copy];

}

+ (NSArray *)getListOfComponentsForTask:(STTTAgentTask *)task {
    return [self getListOfComponentsForTask:task inGroup:nil];
}

+ (void)updateComponentsForTask:(STTTAgentTask *)task
        withInstalledComponents:(NSArray *)installedComponents
              removedComponents:(NSArray *)removedComponents
             remainedComponents:(NSArray *)remainedComponents
                 usedComponents:(NSArray *)usedComponents {

/*
 
    remained    — remained unused with technician
    installed   — was initially installed on terminal
    removed     — was removed from terminal by technician during task
    used        — was used and installed on terminal by technician during task
 
*/
    
    NSArray *allComponents = [@[installedComponents, removedComponents, remainedComponents, usedComponents] valueForKeyPath:@"@unionOfArrays.self"];
    
    for (STTTAgentComponent *component in allComponents) {

        STTTAgentTerminalComponent *terminalComponent = [component actualTerminalComponent];
        if (terminalComponent) terminalComponent.isdeleted = @(YES);

    }
    
//    for (STTTAgentComponent *component in remainedComponents) {
//        do not create taskComponent to comply STTTAgentComponent.m:31 (BOOL)isInstalled method
//    }

    for (STTTAgentComponent *component in installedComponents) {
        [self taskComponentForTask:task terminal:task.terminal andComponent:component];
    }

    for (STTTAgentComponent *component in removedComponents) {
        [self taskComponentForTask:task terminal:task.terminal andComponent:component].isBroken = @(YES);
    }
    
    for (STTTAgentComponent *component in usedComponents) {
        [self taskComponentForTask:task terminal:task.terminal andComponent:component];
    }
    
    task.ts = [NSDate date];

}

+ (STTTAgentTerminalComponent *)terminalComponentForTerminal:(STTTAgentTerminal *)terminal andComponent:(STTTAgentComponent *)component {
    
    STManagedDocument *document = [[STSessionManager sharedManager] currentSession].document;
    NSManagedObjectContext *context = document.managedObjectContext;
    NSString *taskComponentEntityName = NSStringFromClass([STTTAgentTerminalComponent class]);

    STTTAgentTerminalComponent *terminalComponent = (STTTAgentTerminalComponent *)[NSEntityDescription insertNewObjectForEntityForName:taskComponentEntityName inManagedObjectContext:context];

    terminalComponent.terminal = terminal;
    terminalComponent.component = component;
    terminalComponent.isBroken = @(NO);
    terminalComponent.isdeleted = @(NO);
    
    return terminalComponent;
    
}

+ (STTTAgentTaskComponent *)taskComponentForTask:(STTTAgentTask *)task terminal:(STTTAgentTerminal *)terminal andComponent:(STTTAgentComponent *)component {

    STManagedDocument *document = [[STSessionManager sharedManager] currentSession].document;
    NSManagedObjectContext *context = document.managedObjectContext;
    NSString *taskComponentEntityName = NSStringFromClass([STTTAgentTaskComponent class]);
    
    STTTAgentTaskComponent *taskComponent = (STTTAgentTaskComponent *)[NSEntityDescription insertNewObjectForEntityForName:taskComponentEntityName inManagedObjectContext:context];
    
    taskComponent.task = task;
    taskComponent.terminal = terminal;
    taskComponent.component = component;
    taskComponent.isBroken = @(NO);
    taskComponent.isdeleted = @(NO);
    
    return taskComponent;

}

//+ (STTTAgentTaskComponent *)taskComponentForTask:(STTTAgentTask *)task andComponent:(STTTAgentComponent *)component {
//    
//    STManagedDocument *document = [[STSessionManager sharedManager] currentSession].document;
//    NSManagedObjectContext *context = document.managedObjectContext;
//    NSString *taskComponentEntityName = NSStringFromClass([STTTAgentTaskComponent class]);
//
//    STTTAgentTaskComponent *taskComponent = component.taskComponent;
//    
//    if (!taskComponent) {
//        
//        taskComponent = (STTTAgentTaskComponent *)[NSEntityDescription insertNewObjectForEntityForName:taskComponentEntityName
//                                                                                inManagedObjectContext:context];
//        taskComponent.component = component;
//        
//    }
//    
//    taskComponent.task = task;
//    taskComponent.terminal = task.terminal;
//    taskComponent.isdeleted = @(NO);
//
//    return taskComponent;
//    
//}


+ (void)updateComponentsForTask:(STTTAgentTask *)task fromList:(NSArray *)componentsList {
    
    STManagedDocument *document = [[STSessionManager sharedManager] currentSession].document;
    NSManagedObjectContext *context = document.managedObjectContext;
    
    [context performBlockAndWait:^{
       
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
                
                NSString *taskComponentEntityName = NSStringFromClass([STTTAgentTaskComponent class]);
                
                STTTAgentTaskComponent *taskComponent = (STTTAgentTaskComponent *)[NSEntityDescription insertNewObjectForEntityForName:taskComponentEntityName
                                                                                                                inManagedObjectContext:context];
                taskComponent.task = task;
                taskComponent.component = [STAgentTaskComponentService findComponentByXid:componentXid inContext:context];
                
                task.ts = [NSDate date];
                
            }
            
        }
        
    }];
    
    [document saveDocument:^(BOOL success) {
        
    }];
    
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
