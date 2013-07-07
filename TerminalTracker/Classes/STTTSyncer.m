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
@property (nonatomic, strong) NSString *dataOffset;

@end


@implementation STTTSyncer

@synthesize dataOffset = _dataOffset;

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
//        NSString *dataOffset = [defaults objectForKey:@"dataOffset"];
//        if (!dataOffset) {
//            NSDate *date = [NSDate date];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            dateFormatter.dateFormat = @"yyyyMMdd";
//            dataOffset = [dateFormatter stringFromDate:date];
//            [defaults setObject:dataOffset forKey:@"dataOffset"];
//            [defaults synchronize];
//        }
//        _dataOffset = dataOffset;
    }
//    NSLog(@"_dataOffset %@", _dataOffset);
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
//    NSLog(@"requestParameters %@", requestParameters);
    return requestParameters;
}

//- (void)onTimerTick:(NSTimer *)timer {
//    [self setRequestType:@"megaport.iAgentTerminal"];
//    [self setRequestType:@"megaport.iAgentTask"];
//    [super onTimerTick:timer];
//}

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
//                [self sendData:[self JSONFrom:fetchResult] toServer:self.sendDataServerURI withParameters:nil];
                [self sendData:nil toServer:self.recieveDataServerURI withParameters:self.requestParameters];
            } else {
                [self sendData:[self JSONFrom:fetchResult] toServer:self.sendDataServerURI withParameters:nil];
//                [self sendData:nil toServer:self.recieveDataServerURI withParameters:self.requestParameters];
            }
            
        }
    }
        
}

//- (void)sendData:(NSData *)requestData toServer:(NSString *)serverUrlString withParameters:(NSString *)parameters {
//        [super sendData:requestData toServer:serverUrlString withParameters:parameters];
//}

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
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&error];
//    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&error];
    
    NSLog(@"JSONData %@", JSONData);
    
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    NSLog(@"JSONString %@", JSONString);
    
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
    [propertiesDictionary setValue:[object valueForKey:@"visited"] forKey:@"visited"];
    [propertiesDictionary setValue:[object valueForKey:@"commentText"] forKey:@"commentText"];
    [propertiesDictionary setValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [propertiesDictionary setValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    
//    NSLog(@"propertiesDictionary %@", propertiesDictionary);
    return propertiesDictionary;
}

- (void)parseResponse:(NSData *)responseData fromConnection:(NSURLConnection *)connection {
        
//    NSLog(@"parseResponse");
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"responseData %@", responseString);
    
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
                for (id object in (NSArray *)objectsArray) {
                    
                    if (![object isKindOfClass:[NSDictionary class]]) {
                        [[(STSession *)self.session logger] saveLogMessageWithText:@"Sync: object is not dictionary" type:@"error"];
                        self.syncing = NO;
                        break;
                        
                    } else {
//                        NSLog(@"object %@", object);

                        if ([[NSString stringWithFormat:@"%@", connection.originalRequest.URL] isEqualToString:self.recieveDataServerURI]) {
                            
                            [self newObject:(NSDictionary *)object];
                            
                        } else if ([[NSString stringWithFormat:@"%@", connection.originalRequest.URL] isEqualToString:self.sendDataServerURI]) {
                            
                            [self syncObject:object];
                            
                        }
                    }   
                    
                }
                
                if (self.syncing) {
                    self.syncing = NO;
//                    NSLog(@"newsNextOffset %@", [(NSDictionary *)responseJSON valueForKey:@"newsNextOffset"]);
                    self.dataOffset = [(NSDictionary *)responseJSON valueForKey:@"newsNextOffset"];
                    NSString *pageRowCount = [(NSDictionary *)responseJSON valueForKey:@"pageRowCount"];
                    NSString *pageSize = [(NSDictionary *)responseJSON valueForKey:@"pageSize"];
//                    NSLog(@"pageRowCount %@", pageRowCount);
                    if ([pageRowCount isEqualToString:pageSize]) {
                        self.syncing = YES;
                        [self sendData:nil toServer:self.recieveDataServerURI withParameters:self.requestParameters];
                    } else {
                        NSLog(@"All data recieved");
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

    if (result && ![result isEqualToString:@"ok"]) {
        
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
//                NSLog(@"xid %@", xid);
//                NSLog(@"ts %@", [self.syncObject valueForKey:@"ts"]);
//                NSLog(@"lts %@", [self.syncObject valueForKey:@"lts"]);
                
            } else {
                
                [[(STSession *)self.session logger] saveLogMessageWithText:[NSString stringWithFormat:@"Sync: object wrong xid: %@", xid] type:@"error"];
                
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
    terminal.location.latitude = [NSNumber numberWithDouble:[[properties valueForKey:@"latitude"] doubleValue]];
    terminal.location.longitude = [NSNumber numberWithDouble:[[properties valueForKey:@"longitude"] doubleValue]];
    
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
    NSLog(@"terminal.xid %@", terminal.xid);

}

- (void)newTaskWithXid:(NSData *)xidData andProperties:(NSDictionary *)properties {
    
    STTTAgentTask *task = [self taskByXid:xidData];
    
    task.terminalBreakName = [properties valueForKey:@"terminal_break_name"];
    task.visited = [NSNumber numberWithBool:[[properties valueForKey:@"visited"] boolValue]];
    
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
    NSLog(@"task.xid %@", task.xid);

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

@end
