//
//  STUtilities.m
//  TerminalTracker
//
//  Created by Sergey on 13/1/2014.
//  Copyright (c) 2014 Maxim Grigoriev. All rights reserved.
//

#import "STUtilities.h"

@implementation STUtilities

+ (NSString*) stringWithRelativeDateFromDate:(NSDate*) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *formattedString;
    
    dateFormatter.doesRelativeDateFormatting = YES;
    dateFormatter.dateStyle = [self isTodayDate:date] ? NSDateFormatterNoStyle : NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    formattedString = [dateFormatter stringFromDate:date];
    return formattedString;
}

+ (BOOL) isTodayDate:(NSDate*)date {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    return [today isEqualToDate:otherDate];
}
@end
