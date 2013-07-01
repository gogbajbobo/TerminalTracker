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

@implementation STTTSyncer

- (NSString *)requestParameters {
    return @"@shift=-17&page-size:=20&page-number:=1";
}

- (void)onTimerTick:(NSTimer *)timer {
    [self setRequestType:@"megaport.iAgentTask"];
    [super onTimerTick:timer];
}

- (void)sendData:(NSData *)requestData toServer:(NSString *)serverUrlString withParameters:(NSString *)parameters {
    NSLog(@"STTTSyncer sendData");
    if (!self.requestType) {
        NSLog(@"No request type");
        self.syncing = NO;
    } else {
        NSString *requestString = [NSString stringWithFormat:@"%@/%@", serverUrlString, self.requestType];
//        NSLog(@"requestString %@", requestString);
        [super sendData:nil toServer:requestString withParameters:self.requestParameters];
    }
}

- (void)parseResponse:(NSData *)responseData fromConnection:(NSURLConnection *)connection {
        
    NSLog(@"parseResponse");
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
                        NSLog(@"object %@", object);
                        [self syncObject:(NSDictionary *)object];
                    }
                    
                    
                }
//                [[(STSession *)self.session document] saveDocument:^(BOOL success) {
//                    if (success) {
//                        NSLog(@"save response success");
//                    }
//                }];
                //                [[(STSession *)self.session logger] saveLogMessageWithText:@"Sync done" type:@""];
                
                self.syncing = NO;
                
//                if (![[[connection currentRequest] HTTPMethod] isEqualToString:@"GET"]) {
//                    if (self.resultsController.fetchedObjects.count > 0) {
//                        //                        NSLog(@"fetchedObjects.count > 0");
//                        [self syncData];
//                    } else {
//                        //                        NSLog(@"fetchedObjects.count <= 0");
//                        self.syncing = YES;
//                        [self sendData:nil toServer:self.syncServerURI withParameters:nil];
//                    }
//                } else {
//                    if ([[(STSession *)self.session status] isEqualToString:@"finishing"]) {
//                        if (self.resultsController.fetchedObjects.count == 0) {
//                            [self stopSyncer];
//                            [[STSessionManager sharedManager] sessionCompletionFinished:self.session];
//                        } else {
//                            [self syncData];
//                        }
//                    }
//                }
                
                
            }
            
        }
        
    }
    
}


- (void)syncObject:(NSDictionary *)object {
    
//    NSString *result = [(NSDictionary *)object valueForKey:@"result"];
    NSString *name = [(NSDictionary *)object valueForKey:@"name"];
    NSString *xid = [(NSDictionary *)object valueForKey:@"xid"];
    NSDictionary *properties = [(NSDictionary *)object valueForKey:@"properties"];
    
    if ([name isEqualToString:@"megaport.iAgentTerminal"]) {

        STTTAgentTerminal *terminal = (STTTAgentTerminal *)[NSEntityDescription insertNewObjectForEntityForName:@"STTTAgentTerminal" inManagedObjectContext:[[(STSession *)self.session document] managedObjectContext]];

        NSString *xidString = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSData *xidData = [self dataFromString:xidString];
        terminal.xid = xidData;
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:terminal.entity.name inManagedObjectContext:[[(STSession *)self.session document] managedObjectContext]];
        NSArray *entityProperties = [entityDescription.propertiesByName allKeys];
        for (NSString *propertyName in entityProperties) {
            NSString *value = [properties valueForKey:propertyName];
            if (value) {
                if ([propertyName isEqualToString:@"id"]) {
                    [terminal setValue:[NSNumber numberWithInt:[value intValue]] forKey:propertyName];
                } else {
                    [terminal setValue:value forKey:propertyName];
                }
            }
            
        }
        
        [terminal setValue:[NSDate date] forKey:@"lts"];

    }
    
/*
    
    if (result && ![result isEqualToString:@"ok"]) {
        
        [[(STSession *)self.session logger] saveLogMessageWithText:[NSString stringWithFormat:@"Sync result not ok xid: %@", xid] type:@"error"];
        
    } else {
        
        if (!properties) {
            
            NSString *xidString = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSData *xidData = [self dataFromString:xidString];
 
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
            request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];
            
            NSError *error;
            NSArray *fetchResult = [self.document.managedObjectContext executeFetchRequest:request error:&error];
            
            if ([fetchResult lastObject]) {
                
                self.syncObject = [fetchResult lastObject];
                [self.syncObject setValue:[self.syncObject valueForKey:@"sts"] forKey:@"lts"];
                //                NSLog(@"xid %@", xid);
                //                NSLog(@"ts %@", [self.syncObject valueForKey:@"ts"]);
                //                NSLog(@"lts %@", [self.syncObject valueForKey:@"lts"]);
                
            } else {
                
                [[(STSession *)self.session logger] saveLogMessageWithText:[NSString stringWithFormat:@"Sync: object wrong xid: %@", xid] type:@"error"];
                
            }
            
        } else {
            
            if ([name isEqualToString:@"STSettings"]) {
                
                NSString *settingGroup = [properties valueForKey:@"group"];
                NSString *settingName = [properties valueForKey:@"name"];
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
                request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
                request.predicate = [NSPredicate predicateWithFormat:@"SELF.group == %@ && SELF.name == %@", settingGroup, settingName];
                
                NSError *error;
                NSArray *fetchResult = [self.document.managedObjectContext executeFetchRequest:request error:&error];
                
                if ([fetchResult lastObject]) {
                    
                    self.syncObject = [fetchResult lastObject];
                    
                    NSString *oldValue = [self.syncObject valueForKey:@"value"];
                    NSString *newValue = [properties valueForKey:@"value"];
                    
                    if (![newValue isEqualToString:oldValue]) {
                        
                        NSString *newValue = [[(STSession *)self.session settingsController] normalizeValue:[properties valueForKey:@"value"] forKey:settingName];
                        
                        if (newValue) {
                            
                            [self.syncObject setValue:newValue forKey:@"value"];
                            
                        }
                        
                    }
                    
                }
                
            } else {
                
            }
            
        }
        
    }

*/

}


@end
