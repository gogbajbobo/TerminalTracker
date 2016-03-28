//
//  STTTSyncer.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTSyncer.h"
#import <STManagedTracker/STSession.h>

#import "STLogMessage.h"

#import "STTTAgentTerminal.h"
#import "STTTAgentTask.h"
#import "STTTTerminalLocation.h"
#import "STTTTaskLocation.h"

#import "STTTAgentTask.h"

#import "STTTAgentRepairCode.h"
#import "STTTAgentTaskRepair.h"

#import "STTTAgentDefectCode.h"
#import "STTTAgentTaskDefect.h"

#import "STTTAgentComponentGroup.h"
#import "STTTAgentComponent.h"
#import "STTTAgentTaskComponent.h"
#import "STTTAgentTerminalComponent.h"

#import "STTTAgentBarcodeType.h"

#import "STTTComponentsController.h"


@interface STTTSyncer() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSString *recieveDataServerURI;
@property (nonatomic, strong) NSString *sendDataServerURI;
@property (nonatomic) NSUInteger newTasksCount;

@property (nonatomic, strong) NSFetchedResultsController *resultsController;


@end


@implementation STTTSyncer

@synthesize dataOffset = _dataOffset;

- (void)setSession:(id<STSession>)session {
    
    [super setSession:session];

    [STTTComponentsController checkExpiredComponentsForSession:session];
    
}

- (NSString *)restServerURI {
    if (!_restServerURI) {
        _restServerURI = [self.settings valueForKey:@"restServerURI"];
    }
    return _restServerURI;
}

- (NSString *)recieveDataServerURI {
    if (!_recieveDataServerURI) {
        _recieveDataServerURI = [self.settings valueForKey:@"recieveDataServerURI"];
    }
    return _recieveDataServerURI;
}

- (NSString *)sendDataServerURI {
    if (!_sendDataServerURI) {
        _sendDataServerURI = [self.settings valueForKey:@"sendDataServerURI"];
    }
    return _sendDataServerURI;
}

- (NSString *)dataOffset {
    if (!_dataOffset) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _dataOffset = [defaults objectForKey:@"dataOffset"];
    }
    return _dataOffset;
}

- (void)setDataOffset:(NSString *)dataOffset {
    if (_dataOffset != dataOffset) {
        _dataOffset = dataOffset;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_dataOffset forKey:@"dataOffset"];
        [defaults synchronize];
    }
}

- (NSString *)requestParameters {
    NSString *dataOffsetString = self.dataOffset ? [NSString stringWithFormat:@"offset:=%@&", self.dataOffset] : @"";
    NSString *requestParameters = [NSString stringWithFormat:@"%@page-size:=%d", dataOffsetString, self.fetchLimit];
    return requestParameters;
}


#pragma mark - NSFetchedResultsController

- (NSFetchRequest *)nonsyncedTasksRequest {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentTask class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sqts"
                                                                                     ascending:YES
                                                                                      selector:@selector(compare:)]];
    [request setIncludesSubentities:YES];
    request.predicate = [NSPredicate predicateWithFormat:@"lts == %@ || ts > lts", nil];
    request.fetchLimit = self.fetchLimit;

    return request;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSManagedObjectContext *context = [(STSession *)self.session document].managedObjectContext;
        
        if (context) {
            
            _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self nonsyncedTasksRequest]
                                                                     managedObjectContext:context
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:nil];
            _resultsController.delegate = self;

        }

    }
    return _resultsController;
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"numberOfNonsyncedTasksChanged" object:self];
    
}

- (void)syncData {
    
    if (!self.syncing) {
        
        self.syncing = YES;
        self.newTasksCount = 0;
        
        NSArray *nonsyncedTasks = [self nonsyncedTasks];
        
        if (nonsyncedTasks.count > 0) {
            
            NSString *logMessage = [NSString stringWithFormat:@"unsynced tasks count %@", @(nonsyncedTasks.count)];
            [[(STSession *)self.session logger] saveLogMessageWithText:logMessage type:@""];
            
//            NSArray *nonsyncedObjects = [nonsyncedTasks arrayByAddingObjectsFromArray:[self nonsyncedLogMessages]];
            
            NSArray *nonsyncedObjects = nonsyncedTasks;
            
            if (nonsyncedObjects.count > 0) {
                [self sendData:[self JSONFrom:nonsyncedObjects] toServer:self.sendDataServerURI withParameters:nil];
            } else {
                [self sendData:nil toServer:self.recieveDataServerURI withParameters:self.requestParameters];
            }
            
        } else {
            [self sendData:nil toServer:self.recieveDataServerURI withParameters:self.requestParameters];
        }

    }
        
}

- (NSArray *)nonsyncedTasks {
    
    NSManagedObjectContext *context = [(STSession *)self.session document].managedObjectContext;
    
    if (context) {
        
        return [context executeFetchRequest:[self nonsyncedTasksRequest] error:nil];
        
    } else {
        
        return nil;
        
    }

}

- (NSArray *)nonsyncedLogMessages {

    NSManagedObjectContext *context = [(STSession *)self.session document].managedObjectContext;
    
    if (context) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STLogMessage class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sqts"
                                                                                         ascending:YES
                                                                                          selector:@selector(compare:)]];
        [request setIncludesSubentities:YES];
        request.predicate = [NSPredicate predicateWithFormat:@"ts != nil AND (lts == %@ || ts > lts)", nil];
        request.fetchLimit = self.fetchLimit;
        
        return [context executeFetchRequest:request error:nil];
        
    } else {
        
        return nil;
        
    }

}

- (NSData *)JSONFrom:(NSArray *)dataForSyncing {
    
    NSMutableArray *syncDataArray = [NSMutableArray array];
    
    for (NSManagedObject *object in dataForSyncing) {

        [object setPrimitiveValue:[NSDate date] forKey:@"sts"];

        NSMutableDictionary *objectDictionary = [self dictionaryForObject:object];
        NSMutableDictionary *propertiesDictionary = [self propertiesDictionaryForObject:object];
        
        objectDictionary[@"properties"] = propertiesDictionary;
        [syncDataArray addObject:objectDictionary];

        if ([object isKindOfClass:[STTTAgentTask class]]) {
            
            [syncDataArray addObjectsFromArray:[self arrayWithTaskRepaisToSync:(STTTAgentTask *)object]];
            [syncDataArray addObjectsFromArray:[self arrayWithTaskDefectsToSync:(STTTAgentTask *)object]];
            [syncDataArray addObjectsFromArray:[self arrayWithTaskComponentsToSync:(STTTAgentTask *)object]];
            
        }
        
    }
    
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObject:syncDataArray forKey:@"data"];
    
//    NSLog(@"dataDictionary %@", dataDictionary);
    
    NSError *error;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&error];
    
    return JSONData;
}

-(NSString *)stringWithXid:(NSData *)xid {
    
    NSString *result = [NSString stringWithFormat:@"%@", xid];
    NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
    return [[result stringByTrimmingCharactersInSet:charsToRemove] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
}

-(NSData*)xidWithString:(NSString*)string {
    return [self dataFromString:[string stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}

- (NSArray*)arrayWithTaskRepaisToSync:(STTTAgentTask*)task {
    
    NSMutableArray* results = [NSMutableArray array];
    
    for(STTTAgentTaskRepair *repair in task.repairs) {
        
        NSDictionary *propertiesDic = @{@"isdeleted": repair.isdeleted,
                                        @"taskxid": [self stringWithXid:task.xid],
                                        @"repairxid": [self stringWithXid:repair.repairCode.xid],
                                        @"repairName": repair.repairCode.repairName,
                                        @"ts":[NSString stringWithFormat:@"%@", repair.ts]};

        NSDictionary *objectDictionary = @{@"name": @"megaport.iAgentTaskRepair",
                                           @"xid": [self stringWithXid:repair.xid],
                                           @"properties": propertiesDic};
        
        [results addObject:objectDictionary];
        
    }
    return results;
    
}

- (NSArray*)arrayWithTaskDefectsToSync:(STTTAgentTask*)task {
    
    NSMutableArray *results = [NSMutableArray array];

    for(STTTAgentTaskDefect *defect in task.defects) {
        
        NSMutableDictionary *objectDictionary = [@{@"name"  : @"megaport.iAgentTaskDefect",
                                                   @"xid"   : [self stringWithXid:defect.xid]} mutableCopy];
        
        objectDictionary[@"properties"] = @{@"isdeleted": (defect.isdeleted) ? defect.isdeleted : @(NO),
                                            @"taskxid"  : [self stringWithXid:task.xid],
                                            @"defectxid": [self stringWithXid:defect.defectCode.xid],
                                            @"ts"       : [NSString stringWithFormat:@"%@", defect.ts]};
        
        [results addObject:objectDictionary];
        
    }
    return results;
    
}

- (NSArray*)arrayWithTaskComponentsToSync:(STTTAgentTask*)task {
    
    NSMutableArray *results = [NSMutableArray array];
    
    for (STTTAgentTaskComponent *taskComponent in task.components) {
        
        NSMutableDictionary *objectDictionary = [@{@"name"  : @"megaport.iAgentTaskComponent",
                                                   @"xid"   : [self stringWithXid:taskComponent.xid]} mutableCopy];
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        
        [properties addEntriesFromDictionary:@{@"isdeleted" : (taskComponent.isdeleted) ? taskComponent.isdeleted : @(NO),
                                               @"isBroken"  : (taskComponent.isBroken) ? taskComponent.isBroken : @(NO),
                                               @"taskxid"   : [self stringWithXid:task.xid],
                                               @"ts"        : [NSString stringWithFormat:@"%@", taskComponent.ts]}];
        
        if (taskComponent.component) {
            [properties addEntriesFromDictionary:@{@"componentxid" : [self stringWithXid:taskComponent.component.xid]}];
        }

        if (taskComponent.terminal) {
            [properties addEntriesFromDictionary:@{@"terminalxid" : [self stringWithXid:taskComponent.terminal.xid]}];
        }
        
        objectDictionary[@"properties"] = properties;
        
        [results addObject:objectDictionary];
        
    }
    return results;

}


- (NSMutableDictionary *)dictionaryForObject:(NSManagedObject *)object {
    
    NSString *name = @"";
    
    if ([object isKindOfClass:[STTTAgentTask class]]) {
        name = @"megaport.iAgentTask";
    } else if ([object isKindOfClass:[STLogMessage class]]) {
        name = @"megaport.iLogMessage";
    }

    NSString *xid = [NSString stringWithFormat:@"%@", [object valueForKey:@"xid"]];
    NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
    xid = [[xid stringByTrimmingCharactersInSet:charsToRemove] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return @{@"name": name, @"xid": xid}.mutableCopy;

}

- (NSMutableDictionary *)propertiesDictionaryForObject:(NSManagedObject *)object {
    
    if ([object isKindOfClass:[STTTAgentTask class]]) {
        
        STTTAgentTask *task = (STTTAgentTask *)object;

        double latitude = task.visitLocation.latitude.doubleValue;
        double longitude = task.visitLocation.longitude.doubleValue;
        
        NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
        
        propertiesDictionary[@"ts"] = [NSString stringWithFormat:@"%@", task.ts];
        propertiesDictionary[@"servstatus"] = task.servstatus;
        propertiesDictionary[@"commentText"] = task.commentText;
        propertiesDictionary[@"latitude"] = [NSNumber numberWithDouble:latitude];
        propertiesDictionary[@"longitude"] = [NSNumber numberWithDouble:longitude];
        propertiesDictionary[@"terminalBarcode"] = task.terminalBarcode;
        
        return propertiesDictionary;

    } else if ([object isKindOfClass:[STLogMessage class]]) {
        
        STLogMessage *logMessage = (STLogMessage *)object;

        NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
        
        propertiesDictionary[@"ts"] = [NSString stringWithFormat:@"%@", logMessage.ts];
        propertiesDictionary[@"text"] = logMessage.text;
        propertiesDictionary[@"type"] = logMessage.type;
        
        return propertiesDictionary;

    } else {
        
        return nil;
        
    }
    
}

- (void)parseResponse:(NSData *)responseData fromConnection:(NSURLConnection *)connection {
    
    NSError *error;
    id responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
//    NSLog(@"responseJSON %@", responseJSON);
//    NSLog(@"URL %@", connection.originalRequest.URL.absoluteString);
    
    if (![responseJSON isKindOfClass:[NSDictionary class]]) {
        
        [[(STSession *)self.session logger] saveLogMessageWithText:@"Sync: response is not dictionary" type:@"error"];
        self.syncing = NO;
        
    } else {
        
        NSString *errorString = [(NSDictionary *)responseJSON valueForKey:@"error"];
        
        if (errorString && ![errorString isEqualToString:@"ok"]) {
            
            [[(STSession *)self.session logger] saveLogMessageWithText:[NSString stringWithFormat:@"Sync: response error: %@", errorString] type:@"error"];
            self.syncing = NO;
            
        } else {
            
            id objectsArray = [(NSDictionary *)responseJSON valueForKey:@"data"];
            
            if ([objectsArray isKindOfClass:[NSArray class]]) {
                
                NSUInteger objectsCount = [(NSArray *)objectsArray count];
                
                NSLog(@"originalRequest.URL %@", connection.originalRequest.URL.absoluteString);
                
                NSString *logMessage = [NSString stringWithFormat:@"recieve %@ objects", @(objectsCount)];
                [[(STSession *)self.session logger] saveLogMessageWithText:logMessage type:@""];
                
                for (id object in (NSArray *)objectsArray) {
                    
                    if (![object isKindOfClass:[NSDictionary class]]) {
                        [[(STSession *)self.session logger] saveLogMessageWithText:@"Sync: object is not dictionary" type:@"error"];
                        self.syncing = NO;
                        break;
                        
                    } else {
                        
                        NSString *originalRequestURL = [NSString stringWithFormat:@"%@", connection.originalRequest.URL];

                        if ([originalRequestURL isEqualToString:self.recieveDataServerURI] || [originalRequestURL hasPrefix:self.restServerURI]) {
                            
                            [self newObject:(NSDictionary *)object];
                            
                        } else if ([originalRequestURL isEqualToString:self.sendDataServerURI]) {
                            
                            [self syncObject:object];
                            
                        }
                    }   
                    
                }
                
                [[self.session document] saveDocument:^(BOOL success) {
                    
                }];
                
                if (self.syncing) {
                    
                    self.syncing = NO;
                    
                    if ([[NSString stringWithFormat:@"%@", connection.originalRequest.URL] isEqualToString:self.recieveDataServerURI]) {
                        
                        self.dataOffset = [(NSDictionary *)responseJSON valueForKey:@"newsNextOffset"];
                        NSString *pageRowCount = [(NSDictionary *)responseJSON valueForKey:@"pageRowCount"];
                        NSString *pageSize = [(NSDictionary *)responseJSON valueForKey:@"pageSize"];

                        if ([pageRowCount intValue] < [pageSize intValue]) {

                            [[(STSession *)self.session logger] saveLogMessageWithText:@"All data received" type:@""];
                            [self showNewTaskNotification:nil];
                            self.newTasksCount = 0;
            
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerRecievedAllData" object:self];
                            
                            [self showDataInfo];

                        } else {

                            self.syncing = YES;
                            [self sendData:nil toServer:self.recieveDataServerURI withParameters:self.requestParameters];

                        }

                    } else if ([[NSString stringWithFormat:@"%@", connection.originalRequest.URL] isEqualToString:self.sendDataServerURI]) {
                        
                        [self syncData];
                        
                    } else if ([[NSString stringWithFormat:@"%@", connection.originalRequest.URL] hasPrefix:self.restServerURI]) {
                        
                        if (objectsCount > 0) {

                            NSLog(@"recieved object was stored");
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerRecievedAllData" object:self];

                            [self showDataInfo];

                        } else {
                            NSLog(@"no requested object recieved");
                        }
                        
                    }
                }
                
            }
            
        }
        
    }
    
}

- (void)syncObject:(NSDictionary *)object {
    
    NSString *result = [(NSDictionary *)object valueForKey:@"result"];
    NSString *name = [(NSDictionary *)object valueForKey:@"name"];
    NSString *xid = [(NSDictionary *)object valueForKey:@"xid"];
    NSString *xidString = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData *xidData = [self dataFromString:xidString];

    if (!result || ![result isEqualToString:@"ok"]) {
        
        [[(STSession *)self.session logger] saveLogMessageWithText:[NSString stringWithFormat:@"Sync result not ok xid: %@", xid] type:@"error"];
        
    } else {

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STDatum class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];
        
        NSError *error;
        NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
        STDatum *object = fetchResult.lastObject;
    
        if (object) {
            
            object.lts = object.sts;
            NSLog(@"sync %@ xid %@", name, xid);

            if ([object isKindOfClass:[STTTAgentTerminalComponent class]]) {
                
                STTTAgentTerminalComponent *terminalComponent = (STTTAgentTerminalComponent *)object;
                
                if (terminalComponent.isdeleted.boolValue) {
                    
                    NSLog(@"delete %@ xid %@", name, xid);
                    [[self.session document].managedObjectContext deleteObject:terminalComponent];
                    
                }
                
            }
            
        } else {
            
            [[(STSession *)self.session logger] saveLogMessageWithText:[NSString stringWithFormat:@"Sync: no object with xid: %@", xid] type:@"error"];
            
        }
    
    }

}

- (void)newObject:(NSDictionary *)object {
    
    NSString *name = [(NSDictionary *)object valueForKey:@"name"];
    NSString *xid = [(NSDictionary *)object valueForKey:@"xid"];
    NSString *xidString = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData *xidData = [self dataFromString:xidString];
    NSDictionary *properties = [(NSDictionary *)object valueForKey:@"properties"];
    
    if ([name isEqualToString:@"megaport.iAgentTerminal"]) {

        [self newTerminalWithXid:xidData andProperties:properties];
        
    } else if ([name isEqualToString:@"megaport.iAgentTask"]) {

        [self newTaskWithXid:xidData andProperties:properties];

    } else if ([name isEqualToString:@"megaport.iAgentSettings"]) {
        
        [self newSettingWithProperties:properties];
        
    } else if ([name isEqualToString:@"megaport.iAgentRepairCode"]) {
        
        [self newRepairCodeWithXid:xidData andProperties:properties];
        
    } else if ([name isEqualToString:@"megaport.iAgentTaskRepair"]) {
        
        [self newTaskRepairWithXid:xidData andProperties:properties];
        
    } else if ([name isEqualToString:@"megaport.iAgentDefectCode"]) {
        
        [self newDefectCodeWithXid:xidData andProperties:properties];
        
    } else if ([name isEqualToString:@"megaport.iAgentTaskDefect"]) {
        
        [self newTaskDefectWithXid:xidData andProperties:properties];
        
    } else if ([name isEqualToString:@"megaport.iAgentComponent"]) {
        
        [self newComponentWithXid:xidData andProperties:properties];
        
    } else if ([name isEqualToString:@"megaport.iAgentTaskComponent"]) {
        
        [self newTaskComponentWithXid:xidData andProperties:properties];

    } else if ([name isEqualToString:@"megaport.iAgentTerminalComponent"]) {
        
        [self newTerminalComponentWithXid:xidData andProperties:properties];
        
    } else if ([name isEqualToString:@"megaport.iAgentComponentGroup"]) {
        
        [self newComponentGroupWithXid:xidData andProperties:properties];

    } else if ([name isEqualToString:@"megaport.iAgentBarcodeType"]) {
        
        [self newBarcodeTypeWithXid:xidData andProperties:properties];
        
    } else {
        
        NSLog(@"object %@", object);
        
    }

}

- (STTTAgentTask *)taskForReceivingDataWithXid:(NSData *)xid {

    STTTAgentTask *task = (STTTAgentTask *)[self entityByClass:[STTTAgentTask class]
                                                        andXid:xid];
    
    return (task.ts && [task.lts compare:task.ts] == NSOrderedAscending) ? nil : task;
        
}

- (void)taskRelationshipInitForRelationshipObject:(NSManagedObject *)object andTask:(STTTAgentTask *)task {
    
    [self setValue:@NO forKey:@"isdeleted" forObject:object];
    [self setValue:@NO forKey:@"isBroken" forObject:object];
    if (task) [self setValue:task forKey:@"task" forObject:object];
    [self setValue:[NSDate date] forKey:@"lts" forObject:object];
    
}

- (void)setValue:(id)value forKey:(NSString *)key forObject:(NSManagedObject *)object {

    if ([[object.entity propertiesByName] objectForKey:key] != nil) {
        [object setValue:value forKey:key];
    } else {
        NSLog(@"object %@ has no property with name %@", object.entity.name, key);
    }

}

- (void)newTaskDefectWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    NSDictionary *taskData = [properties valueForKey:@"taskxid"];

    STTTAgentTask *task = [self taskForReceivingDataWithXid:[self xidWithString:[taskData valueForKey:@"id"]]];
    
    if (!task) {
        
        NSLog(@"task has local changes and not synced yet, server's data will be ignored for taskDefect %@", xidData);
        
    } else {
    
        STTTAgentTaskDefect *defect = (STTTAgentTaskDefect*)[self entityByClass:[STTTAgentTaskDefect class] andXid:xidData];
        
        if ([defect.isdeleted boolValue]) {
            
            NSLog(@"local taskDefect isdeleted, server's data will be ignored for taskDefect %@", xidData);
            
        } else {
            
            defect.defectCode = (STTTAgentDefectCode *)[self entityByClass:[STTTAgentDefectCode class] andXid:[self xidWithString:[properties valueForKey:@"defectxid"]]];
            
            [self taskRelationshipInitForRelationshipObject:defect andTask:task];
            
            NSLog(@"get taskDefect.xid %@", defect.xid);

        }
    }
    
}

- (void)newDefectCodeWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentDefectCode *defectCode = (STTTAgentDefectCode *)[self entityByClass:[STTTAgentDefectCode class] andXid:xidData];
    defectCode.name = [properties valueForKey:@"name"];
    defectCode.active = [NSNumber numberWithBool:[[properties valueForKey:@"active"] boolValue]];
    defectCode.lts = [NSDate date];
    NSLog(@"get defect_code.xid %@", defectCode.xid);

}

- (void)newTaskComponentWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    NSDictionary *taskData = [properties valueForKey:@"taskxid"];

    STTTAgentTask *task = [self taskForReceivingDataWithXid:[self xidWithString:[taskData valueForKey:@"id"]]];
    
    if (!task) {
        
        NSLog(@"task has local changes and not synced yet, server's data will be ignored for taskComponent %@", xidData);
        
    } else {

        STTTAgentTaskComponent *taskComponent = (STTTAgentTaskComponent *)[self entityByClass:[STTTAgentTaskComponent class] andXid:xidData];
        
        if ([taskComponent.isdeleted boolValue]) {
            
            NSLog(@"local taskComponent isdeleted, server's data will be ignored for taskComponent %@", xidData);
            
        } else {
            
            taskComponent.component = (STTTAgentComponent *)[self entityByClass:[STTTAgentComponent class] andXid:[self xidWithString:[properties valueForKey:@"componentxid"]]];
            
            [self taskRelationshipInitForRelationshipObject:taskComponent andTask:task];
            
            NSLog(@"get taskComponent.xid %@", taskComponent.xid);

        }
        
    }

}

- (void)newTerminalComponentWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentTerminalComponent *terminalComponent = (STTTAgentTerminalComponent *)[self entityByClass:[STTTAgentTerminalComponent class] andXid:xidData];
    
    if ([terminalComponent.isdeleted boolValue]) {
        
        NSLog(@"local terminalComponent isdeleted, server's data will be ignored for terminalComponent %@", xidData);
        
    } else {
        
        STTTAgentComponent *component = (STTTAgentComponent *)[self entityByClass:[STTTAgentComponent class] andXid:[self xidWithString:[properties valueForKey:@"componentxid"]]];
        
        component.wasInitiallyInstalled = @(YES);
        
        terminalComponent.component = component;
        
        terminalComponent.terminal = (STTTAgentTerminal *)[self entityByClass:[STTTAgentTerminal class] andXid:[self xidWithString:[properties valueForKey:@"terminalxid"]]];
        
        [self taskRelationshipInitForRelationshipObject:terminalComponent andTask:nil];
        
        NSLog(@"get terminalComponent.xid %@", terminalComponent.xid);
        
    }
    
}

- (void)newComponentGroupWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentComponentGroup *group = (STTTAgentComponentGroup *)[self entityByClass:[STTTAgentComponentGroup class] andXid:xidData];
    group.isManualReplacement = @([[properties valueForKey:@"isManualReplacement"] boolValue]);
    group.name = [properties valueForKey:@"name"];
    group.lts = [NSDate date];
    
    NSLog(@"get componentGroup.xid %@", group.xid);
    
}

- (void)newComponentWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentComponent *component = (STTTAgentComponent *)[self entityByClass:[STTTAgentComponent class] andXid:xidData];
    component.shortName = [properties valueForKey:@"short_name"];
    component.serial = [properties valueForKey:@"serial"];
    
    NSString *groupXid = [properties valueForKey:@"componentgroupxid"];
    NSString *groupXidString = [groupXid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData *groupXidData = [self dataFromString:groupXidString];
    component.componentGroup = (STTTAgentComponentGroup *)[self entityByClass:[STTTAgentComponentGroup class] andXid:groupXidData];
    
    component.lts = [NSDate date];

    NSLog(@"get component.xid %@", component.xid);

}

- (void)newTaskRepairWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    NSDictionary *taskData = [properties valueForKey:@"taskxid"];
    
    STTTAgentTask *task = [self taskForReceivingDataWithXid:[self xidWithString:[taskData valueForKey:@"id"]]];
    
    if (!task) {
        
        NSLog(@"task has local changes and not synced yet, server's data will be ignored for taskRepair %@", xidData);
        
    } else {

        STTTAgentTaskRepair *repair = (STTTAgentTaskRepair*)[self entityByClass:[STTTAgentTaskRepair class] andXid:xidData];
        
        if ([repair.isdeleted boolValue]) {
            
            NSLog(@"local taskRepair isdeleted, server's data will be ignored for taskRepair %@", xidData);
            
        } else {

            repair.repairCode = (STTTAgentRepairCode*)[self entityByClass:[STTTAgentRepairCode class] andXid:[self xidWithString:[properties valueForKey:@"repairxid"]]];
            
            [self taskRelationshipInitForRelationshipObject:repair andTask:task];
            
            NSLog(@"get taskRepair.xid %@", repair.xid);

        }

    }
    
}

- (void)newRepairCodeWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentRepairCode *repairCode = (STTTAgentRepairCode*)[self entityByClass:[STTTAgentRepairCode class] andXid:xidData];
    repairCode.repairName = [properties valueForKey:@"repair_name"];
    repairCode.active = [NSNumber numberWithBool:[[properties valueForKey:@"active"] boolValue]];
    repairCode.lts = [NSDate date];
    
    NSLog(@"get repair_code.xid %@", repairCode.xid);
    
}

- (void)newTerminalWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentTerminal *terminal = (STTTAgentTerminal*)[self entityByClass:[STTTAgentTerminal class] andXid:xidData];
    
    if (!terminal.location) {
        
        NSString *locationEntityName = NSStringFromClass([STTTTerminalLocation class]);
        
        STTTTerminalLocation *location = (STTTTerminalLocation *)[NSEntityDescription insertNewObjectForEntityForName:locationEntityName
                                                                                               inManagedObjectContext:self.session.document.managedObjectContext];
        terminal.location = location;
        
    }
    
    terminal.code = properties[@"code"];
    terminal.errorText = properties[@"errortext"];
    terminal.srcSystemName = properties[@"src_system_name"];
    terminal.mobileop = properties[@"mobileop"];
    
    NSDate *lastActivityTime = [self extractDateFrom:properties forKey:@"lastactivitytime"];
    terminal.lastActivityTime = lastActivityTime;
    
    NSDate *lastPaymentTime = [self extractDateFrom:properties forKey:@"lastpaymenttime"];
    terminal.lastPaymentTime = lastPaymentTime;

    if (properties[@"address"]) {
        terminal.address = [NSString stringWithUTF8String:[properties[@"address"] UTF8String]];
    }
    
    terminal.lts = [NSDate date];

    id latitude = properties[@"latitude"];
    id longitude = properties[@"longitude"];
    terminal.location.latitude = [latitude isKindOfClass:[NSNumber class]] ? latitude : @([latitude doubleValue]);
    terminal.location.longitude = [longitude isKindOfClass:[NSNumber class]] ? longitude : @([longitude doubleValue]);
    
    if (!terminal.location.latitude || !terminal.location.longitude) {
        
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder geocodeAddressString:terminal.address completionHandler:^(NSArray *placemarks, NSError *error) {

            if (error) {
                NSLog(@"error %@", error.localizedDescription);
                terminal.location = nil;
            } else {
                CLPlacemark *place = [placemarks lastObject];
                terminal.location.latitude = [NSNumber numberWithDouble:place.location.coordinate.latitude];
                terminal.location.longitude = [NSNumber numberWithDouble:place.location.coordinate.longitude];
            }
            
        }];
        
    }
    
    NSLog(@"get terminal.xid %@", terminal.xid);

}

- (void)newTaskWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentTask *task = [self taskForReceivingDataWithXid:xidData];
    
    if (!task) {
        
        NSLog(@"task has local changes and not synced yet, server's data will be ignored for task %@", xidData);
        
    } else {

        task.terminalBarcode = [properties valueForKey:@"terminalBarcode"];
        task.terminalBreakName = [properties valueForKey:@"terminal_break_name"];
        task.commentText = [properties valueForKey:@"techinfo"];
        id routePriority = [properties valueForKey:@"route_priority"];
        task.routePriority = [routePriority respondsToSelector:@selector(integerValue)] ? [NSNumber numberWithInteger:[routePriority integerValue]] : @0;
        
        id servstatus = [properties valueForKey:@"servstatus"];
        task.servstatus = task.recentlyVisited ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:[servstatus boolValue]];
        
        NSDate *doBeforeDate = [self extractDateFrom:properties forKey:@"do-before"];
        task.doBefore = doBeforeDate;
        
        NSDate *servstatusDate = [self extractDateFrom:properties forKey:@"servstatus_date"];
        task.servstatusDate = servstatusDate;
        
        NSDictionary *terminalData = [properties valueForKey:@"terminal"];
        NSData *terminalXid = [self dataFromString:[[terminalData valueForKey:@"xid"] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        
        STTTAgentTerminal *terminal = (STTTAgentTerminal*)[self entityByClass:[STTTAgentTerminal class] andXid:terminalXid];
        task.terminal = terminal;
        if (task.lts == nil) {
            self.newTasksCount++;
        }
        task.lts = [NSDate date];
        
        NSLog(@"get task.xid %@", task.xid);

    }

}

- (void)newBarcodeTypeWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentBarcodeType *barcodeType = (STTTAgentBarcodeType *)[self entityByClass:[STTTAgentBarcodeType class] andXid:xidData];
    barcodeType.name = [properties valueForKey:@"name"];
    barcodeType.type = [properties valueForKey:@"type"];
    barcodeType.mask = [properties valueForKey:@"mask"];
    barcodeType.symbology = [properties valueForKey:@"symbology"];

    barcodeType.lts = [NSDate date];
    
    NSLog(@"get barcodeType.xid %@", barcodeType.xid);

}


- (NSDate*)extractDateFrom:(NSDictionary*)properties forKey:(NSString*)key{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS Z"];
    NSString *dateString = [NSString stringWithFormat:@"%@ %@", [properties valueForKey:key], [[[self.session settingsController] currentSettingsForGroup:@"general"] valueForKey:@"Timezone"]];
    return [dateFormatter dateFromString:dateString];
}

- (void) showNewTaskNotification:(STTTAgentTask *) task {
    if (self.newTasksCount == 0) {
        return;
    }
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (self.newTasksCount == 1) {
        localNotif.alertBody = @"Добавлено новое задание";
    } else {
        localNotif.alertBody = [NSString stringWithFormat:@"Добавлено новых заданий: %@", @(self.newTasksCount)];
    }
    
    localNotif.alertAction = @"Посмотреть";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}

- (void)newSettingWithProperties:(NSDictionary *)properties {
    
    NSString *group = [properties valueForKey:@"group"];
    NSString *name = [properties valueForKey:@"name"];
    id newValue = [properties valueForKey:@"value"];
    NSString *value = [newValue isKindOfClass:[NSString class]] ? newValue : [newValue stringValue];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STSettings class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.group == %@ && SELF.name == %@", group, name];
    
    NSError *error;
    NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([fetchResult lastObject]) {
        
        STSettings *settingsObject = [fetchResult lastObject];
        
        NSString *oldValue = [settingsObject valueForKey:@"value"];
        
        if (![value isEqualToString:oldValue]) {
            
            NSString *newValue = [[(STSession *)self.session settingsController] normalizeValue:value forKey:name];
            
            if (newValue) {
                
                [settingsObject setValue:newValue forKey:@"value"];
                NSLog(@"set %@ to %@", name, newValue);
                
            }
            
        }
        
    }
    
}

- (STComment*)entityByClass:(Class)entityClass andXid:(NSData *)xid {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(entityClass)];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xid];
    
    NSError *error;
    NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    STComment *entity;
    
    if ([fetchResult lastObject]) {
        
        entity = [fetchResult lastObject];
        
    } else {
        
        entity = (STComment *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(entityClass)
                                                            inManagedObjectContext:self.session.document.managedObjectContext];
        entity.ts = [NSDate date];
        entity.xid = xid;
        
    }
    return entity;
    
}

- (void)syncerSettingsChanged:(NSNotification *)notification {
    
    [super syncerSettingsChanged:notification];
    
    [self.settings addEntriesFromDictionary:notification.userInfo];
    NSString *key = [[notification.userInfo allKeys] lastObject];
    
    //    NSLog(@"%@ %@", [notification.userInfo valueForKey:key], key);
    if ([key isEqualToString:@"recieveDataServerURI"]) {
        self.recieveDataServerURI = [notification.userInfo valueForKey:key];
        
    } else if ([key isEqualToString:@"sendDataServerURI"]) {
        self.sendDataServerURI = [notification.userInfo valueForKey:key];
        
    }
    
}


#pragma mark - info methods

- (void)showDataInfo {
    
#ifdef DEBUG
    
    NSArray *entityNames = @[NSStringFromClass([STTTAgentTask class]),
                             NSStringFromClass([STTTAgentTerminal class]),
                             NSStringFromClass([STTTAgentRepairCode class]),
                             NSStringFromClass([STTTAgentDefectCode class]),
                             NSStringFromClass([STTTAgentComponent class]),
                             NSStringFromClass([STTTAgentComponentGroup class]),
                             NSStringFromClass([STTTAgentBarcodeType class])];

    for (NSString *entityName in entityNames) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
        
        NSUInteger resultCount = [[(STSession *)self.session document].managedObjectContext countForFetchRequest:request error:nil];
        
        NSLog(@"%@ — %@", entityName, @(resultCount));
        
    }
    
    
#endif
    
}


@end
