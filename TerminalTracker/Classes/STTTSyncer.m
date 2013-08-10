//
//  STTTSyncer.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTSyncer.h"
#import <STManagedTracker/STSession.h>
#import "STTTAgentTerminal.h"
#import "STTTAgentTask.h"
#import "STTTTerminalLocation.h"
#import "STTTTaskLocation.h"

@interface STTTSyncer()

@property (nonatomic, strong) NSString *recieveDataServerURI;
@property (nonatomic, strong) NSString *sendDataServerURI;

@end


@implementation STTTSyncer

@synthesize dataOffset = _dataOffset;

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

- (void)syncData {
    
    if (!self.syncing) {
        
        self.syncing = YES;
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentTask class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sqts" ascending:YES selector:@selector(compare:)]];
        [request setIncludesSubentities:YES];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.lts == %@ || SELF.ts > SELF.lts", nil];
        request.fetchLimit = self.fetchLimit;
        
        NSError *error;
        NSArray *fetchResult = [[(STSession *)self.session document].managedObjectContext executeFetchRequest:request error:&error];
        
        if (error) {
            NSLog(@"syncer executeFetchRequest error: %@", error);
        } else {
            NSLog(@"fetchResult.count %d", fetchResult.count);
            if (fetchResult.count == 0) {
                [self sendData:nil toServer:self.recieveDataServerURI withParameters:self.requestParameters];
            } else {
                [self sendData:[self JSONFrom:fetchResult] toServer:self.sendDataServerURI withParameters:nil];
            }
            
        }
    }
        
}

- (NSData *)JSONFrom:(NSArray *)dataForSyncing {
    
    NSMutableArray *syncDataArray = [NSMutableArray array];
    
    for (NSManagedObject *object in dataForSyncing) {
        if ([object isKindOfClass:[STTTAgentTask class]]) {
            [object setPrimitiveValue:[NSDate date] forKey:@"sts"];
            NSMutableDictionary *objectDictionary = [self dictionaryForObject:object];
            NSMutableDictionary *propertiesDictionary = [self propertiesDictionaryForObject:object];
            
            [objectDictionary setObject:propertiesDictionary forKey:@"properties"];
            [syncDataArray addObject:objectDictionary];
        }
    }
    
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObject:syncDataArray forKey:@"data"];
    
    NSError *error;
//    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&error];
    
//    NSLog(@"JSONData %@", JSONData);
    
//    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
//    NSLog(@"JSONString %@", JSONString);
    
    return JSONData;
}

- (NSMutableDictionary *)dictionaryForObject:(NSManagedObject *)object {
    
    NSString *name = @"megaport.iAgentTask";
    NSString *xid = [NSString stringWithFormat:@"%@", [object valueForKey:@"xid"]];
    NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
    xid = [[xid stringByTrimmingCharactersInSet:charsToRemove] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"name", xid, @"xid", nil];
    
}

- (NSMutableDictionary *)propertiesDictionaryForObject:(NSManagedObject *)object {
    
//    NSLog(@"object %@", object);
//
//    NSLog(@"ts %@", [object valueForKey:@"ts"]);
//    NSLog(@"visited %@", [object valueForKey:@"visited"]);
//    NSLog(@"commentText %@", [object valueForKey:@"commentText"]);
    
    double latitude = [[(STTTAgentTask *)object visitLocation].latitude doubleValue];
    double longitude = [[(STTTAgentTask *)object visitLocation].longitude doubleValue];

    NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
    
    [propertiesDictionary setValue:[NSString stringWithFormat:@"%@", [object valueForKey:@"ts"]] forKey:@"ts"];
    [propertiesDictionary setValue:[object valueForKey:@"servstatus"] forKey:@"servstatus"];
    [propertiesDictionary setValue:[object valueForKey:@"commentText"] forKey:@"commentText"];
    [propertiesDictionary setValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [propertiesDictionary setValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    
//    NSLog(@"propertiesDictionary %@", propertiesDictionary);
    return propertiesDictionary;
}

- (void)parseResponse:(NSData *)responseData fromConnection:(NSURLConnection *)connection {
        
//    NSLog(@"parseResponse");

//    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"STTTtest" ofType:@"json"];
//    responseData = [NSData dataWithContentsOfFile:dataPath];

//    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"responseData %@", responseString);
    
    NSError *error;
    id responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
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
                NSLog(@"recieve %d objects", objectsCount);
                for (id object in (NSArray *)objectsArray) {
                    
                    if (![object isKindOfClass:[NSDictionary class]]) {
                        [[(STSession *)self.session logger] saveLogMessageWithText:@"Sync: object is not dictionary" type:@"error"];
                        self.syncing = NO;
                        break;
                        
                    } else {
//                        NSLog(@"object %@", object);
                        
                        NSString *originalRequestURL = [NSString stringWithFormat:@"%@", connection.originalRequest.URL];

                        if ([originalRequestURL isEqualToString:self.recieveDataServerURI] || [originalRequestURL hasPrefix:self.restServerURI]) {
                            
                            [self newObject:(NSDictionary *)object];
                            
                        } else if ([originalRequestURL isEqualToString:self.sendDataServerURI]) {
                            
                            [self syncObject:object];
                            
                        }
                    }   
                    
                }
                
                if (self.syncing) {
                    self.syncing = NO;
                    if ([[NSString stringWithFormat:@"%@", connection.originalRequest.URL] isEqualToString:self.recieveDataServerURI]) {
                        
                        //                    NSLog(@"newsNextOffset %@", [(NSDictionary *)responseJSON valueForKey:@"newsNextOffset"]);
                        self.dataOffset = [(NSDictionary *)responseJSON valueForKey:@"newsNextOffset"];
                        NSString *pageRowCount = [(NSDictionary *)responseJSON valueForKey:@"pageRowCount"];
                        NSString *pageSize = [(NSDictionary *)responseJSON valueForKey:@"pageSize"];
                        //                    NSLog(@"pageRowCount %@", pageRowCount);
                        if ([pageRowCount intValue] < [pageSize intValue]) {

                            NSLog(@"All recieved data were stored");
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerRecievedAllData" object:self];

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
        
        if ([name isEqualToString:@"megaport.iAgentTask"]) {
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentTask class])];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];
            
            NSError *error;
            NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
            
            if ([fetchResult lastObject]) {
                
                STTTAgentTask *task = [fetchResult lastObject];
                [task setValue:[task valueForKey:@"sts"] forKey:@"lts"];
                NSLog(@"sync object xid %@", xid);
//                NSLog(@"ts %@", [self.syncObject valueForKey:@"ts"]);
//                NSLog(@"lts %@", [self.syncObject valueForKey:@"lts"]);
                
            } else {
                
                [[(STSession *)self.session logger] saveLogMessageWithText:[NSString stringWithFormat:@"Sync: no object with xid: %@", xid] type:@"error"];
                
            }

        }
        
    }

}

- (void)newObject:(NSDictionary *)object {
    
//    NSString *result = [(NSDictionary *)object valueForKey:@"result"];
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
        
    }

}

- (void)newTerminalWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentTerminal *terminal = [self terminalByXid:xidData];
    
    if (!terminal.location) {
        STTTTerminalLocation *location = (STTTTerminalLocation *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STTTTerminalLocation class]) inManagedObjectContext:self.session.document.managedObjectContext];
        terminal.location = location;
    }
    
    terminal.code = [properties valueForKey:@"code"];
    terminal.errorText = [properties valueForKey:@"errortext"];
    terminal.srcSystemName = [properties valueForKey:@"src_system_name"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *lastActivityTime = [dateFormatter dateFromString:[properties valueForKey:@"lastactivitytime"]];
    
    terminal.lastActivityTime = lastActivityTime;
    terminal.address = [NSString stringWithUTF8String:[[properties valueForKey:@"address"] UTF8String]];
    
    terminal.lts = [NSDate date];
//    terminal.location.latitude = [NSNumber numberWithDouble:[[properties valueForKey:@"latitude"] doubleValue]];
//    terminal.location.longitude = [NSNumber numberWithDouble:[[properties valueForKey:@"longitude"] doubleValue]];
    id latitude = [properties valueForKey:@"latitude"];
    id longitude = [properties valueForKey:@"longitude"];
    terminal.location.latitude = [latitude isKindOfClass:[NSNumber class]] ? latitude : [NSNumber numberWithDouble:[latitude doubleValue]];
    terminal.location.longitude = [longitude isKindOfClass:[NSNumber class]] ? longitude : [NSNumber numberWithDouble:[longitude doubleValue]];;
    
    if (!terminal.location.latitude || !terminal.location.longitude) {
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder geocodeAddressString:terminal.address completionHandler:^(NSArray *placemarks, NSError *error) {
            //                NSLog(@"address %@", terminal.address);
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
    
    //        NSLog(@"terminal %@", terminal);
    NSLog(@"get terminal.xid %@", terminal.xid);

}

- (void)newTaskWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentTask *task = [self taskByXid:xidData];
    
    task.terminalBreakName = [properties valueForKey:@"terminal_break_name"];
    
//    NSLog(@"valueForKey:visited %@", [properties valueForKey:@"visited"]);
//    NSLog(@"boolValue %d", [[properties valueForKey:@"visited"] boolValue]);
//    NSLog(@"numberWithBool %@", [NSNumber numberWithBool:[[properties valueForKey:@"visited"] boolValue]]);
    
//    task.visited = [NSNumber numberWithBool:[[properties valueForKey:@"visited"] boolValue]];
    id servstatus = [properties valueForKey:@"servstatus"];
    task.servstatus = [servstatus isKindOfClass:[NSNumber class]] ? servstatus : [NSNumber numberWithBool:[servstatus boolValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *doBeforeDate = [dateFormatter dateFromString:[properties valueForKey:@"do-before"]];
    
    task.doBefore = doBeforeDate;
    task.lts = [NSDate date];
    
    NSDictionary *terminalData = [properties valueForKey:@"terminal"];
    NSData *terminalXid = [self dataFromString:[[terminalData valueForKey:@"xid"] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    
    STTTAgentTerminal *terminal = [self terminalByXid:terminalXid];
    
    task.terminal = terminal;
    
    //        NSLog(@"task %@", task);
    NSLog(@"get task.xid %@", task.xid);

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

- (STTTAgentTerminal *)terminalByXid:(NSData *)xid {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentTerminal class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xid];
    NSError *error;
    NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    STTTAgentTerminal *terminal;
    
    if ([fetchResult lastObject]) {
        terminal = [fetchResult lastObject];
    } else {
        terminal = (STTTAgentTerminal *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STTTAgentTerminal class]) inManagedObjectContext:self.session.document.managedObjectContext];
        terminal.xid = xid;
    }
    
    return terminal;

}

- (STTTAgentTask *)taskByXid:(NSData *)xid {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentTask class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xid];
    
    NSError *error;
    NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    STTTAgentTask *task;
    
    if ([fetchResult lastObject]) {
        task = [fetchResult lastObject];
    } else {
        task = (STTTAgentTask *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STTTAgentTask class]) inManagedObjectContext:self.session.document.managedObjectContext];
        task.xid = xid;
    }
    
    return task;

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


@end
