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

@interface STTTSyncer()

//@property (nonatomic, strong) NSManagedObject *syncObject;


@end


@implementation STTTSyncer

- (NSString *)requestParameters {
    return @"@shift=-17&page-size:=20&page-number:=1";
}

- (void)onTimerTick:(NSTimer *)timer {
    [self setRequestType:@"megaport.iAgentTerminal"];
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
        
//    NSLog(@"parseResponse");
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
                for (id object in (NSArray *)objectsArray) {
                    
                    if (![object isKindOfClass:[NSDictionary class]]) {
                        [[(STSession *)self.session logger] saveLogMessageWithText:@"Sync: object is not dictionary" type:@"error"];
                        self.syncing = NO;
                        break;
                        
                    } else {
//                        NSLog(@"object %@", object);
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

        NSString *xidString = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSData *xidData = [self dataFromString:xidString];
//        terminal.xid = xidData;
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentTerminal class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];
        
        NSError *error;
        NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
        
        STTTAgentTerminal *terminal;
        
        if ([fetchResult lastObject]) {
            terminal = [fetchResult lastObject];
        } else {
            terminal = (STTTAgentTerminal *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STTTAgentTerminal class]) inManagedObjectContext:self.session.document.managedObjectContext];
            terminal.xid = xidData;
        }
        
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
//        NSLog(@"lastactivitytime %@", [properties valueForKey:@"lastactivitytime"]);
//        NSLog(@"lastActivityTime %@", lastActivityTime);
        
        terminal.lastActivityTime = lastActivityTime;
        terminal.address = [NSString stringWithUTF8String:[[properties valueForKey:@"address"] UTF8String]];
        
        terminal.lts = [NSDate date];
        terminal.location.latitude = [NSNumber numberWithDouble:[[properties valueForKey:@"latitude"] doubleValue]];
        terminal.location.longitude = [NSNumber numberWithDouble:[[properties valueForKey:@"longitude"] doubleValue]];
        
//        NSLog(@"self.syncObject %@", self.syncObject);
//        NSLog(@"address %@", [NSString stringWithUTF8String:[[properties valueForKey:@"address"] UTF8String]]);

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
        
//        NSLog(@"latitude %@", [properties valueForKey:@"latitude"]);
//        NSLog(@"longitude %@", [properties valueForKey:@"longitude"]);
//        NSLog(@"terminal.location %@", terminal.location);
        
        
    }

}


@end
