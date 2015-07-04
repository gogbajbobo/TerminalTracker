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


@implementation STAgentTaskComponentService

+ (NSInteger)getNumberOfSelectedComponentsForTask:(STTTAgentTask *)task {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isdeleted != YES"];
    NSSet *defects = [task.components filteredSetUsingPredicate:predicate];
    
    return defects.count;

}

+ (NSArray *)getListOfComponentsForTask:(STTTAgentTask *)task {
    
    NSMutableArray* resultArray = [NSMutableArray array];
    
    NSManagedObjectContext* managedObjectContext = [[STSessionManager sharedManager] currentSession].document.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentComponent class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"shortName" ascending:YES]];
    
    NSError *error;
    NSArray *fetchResult = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error) {
        
        for(STTTAgentComponent *component in fetchResult) {
            
            NSMutableDictionary *componentData = [NSMutableDictionary dictionary];
            componentData[@"shortName"] = (component.shortName == nil) ? @"????" : component.shortName;
            componentData[@"serial"] = (component.serial == nil) ? @"????" : component.serial;
            componentData[@"defectXid"] = component.xid;
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

@end
