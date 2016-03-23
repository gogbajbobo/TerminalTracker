//
//  STTTComponentsController.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 05/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import "STTTComponentsController.h"
#import "STTTAgentComponent.h"

#define EXPIRED_HOUR 4

@implementation STTTComponentsController

+ (void)checkExpiredComponentsForSession:(id<STSession>)session {
        
    NSArray *expiredComponents = [self expiredComponentsForSession:session];
    
    if (expiredComponents.count > 0) {
        
        NSLog(@"%d expiredComponents will be deleted", expiredComponents.count);
        
        for (STTTAgentComponent *component in expiredComponents) {
            
            [[session document].managedObjectContext deleteObject:component];
            
        }
        
        [[session document] saveDocument:^(BOOL success) {
            
        }];
        
    }
    
}

+ (NSArray *)expiredComponentsForSession:(id<STSession>)session {

#warning !!!!
    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentComponent class])];
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
//    request.sortDescriptors = @[sortDescriptor];
//    
//    NSDate *expiredDate = [self expiredDate];
//    request.predicate = [NSPredicate predicateWithFormat:@"taskComponent == %@ && cts <= %@", nil, expiredDate];
//    
//    NSError *error;
//    NSArray *result = [[session document].managedObjectContext executeFetchRequest:request error:&error];
//    
//    if (error) {
//        
//        NSLog(@"expiredComponents fetch request error: %@", error.localizedDescription);
//        return nil;
//        
//    } else {
//                
//        return result;
//        
//    }

    return @[];
    
}

+ (NSDate *)expiredDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *nowDate = [NSDate date];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    NSDate *today = [dateFormatter dateFromString:[dateFormatter stringFromDate:nowDate]];
    
    NSDate *expiredDate = [today dateByAddingTimeInterval:3600 * EXPIRED_HOUR];

    return expiredDate;
    
}

@end
