//
//  STTTComponentsController.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 05/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <STManagedTracker/STSessionManagement.h>


@interface STTTComponentsController : NSObject

+ (void)checkExpiredComponentsForSession:(id <STSession>)session;

+ (NSDate *)expiredDate;

@end
