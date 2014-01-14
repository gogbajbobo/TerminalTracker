//
//  STUtilities.h
//  TerminalTracker
//
//  Created by Sergey on 13/1/2014.
//  Copyright (c) 2014 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STUtilities : NSObject
+ (NSString*) stringWithRelativeDateFromDate:(NSDate*) date;
+ (BOOL) isTodayDate:(NSDate*)date;
@end
