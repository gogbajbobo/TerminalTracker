//
//  STTTSettingsController.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTSettingsController.h"
#import "STSettings.h"

@implementation STTTSettingsController

+ (id)sharedSTTTSettingsController {
    static STTTSettingsController *sharedSTTTSettingsController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSTTTSettingsController = [[self alloc] init];
    });
    return sharedSTTTSettingsController;
}

- (NSDictionary *)defaultSettings {
    NSMutableDictionary *defaultSettings = [[super defaultSettings] mutableCopy];
    
    NSMutableDictionary *locationTrackerSettings = [NSMutableDictionary dictionary];
    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%f", kCLLocationAccuracyBestForNavigation] forKey:@"desiredAccuracy"];
    [locationTrackerSettings setValue:@"10.0" forKey:@"requiredAccuracy"];
    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%f", kCLDistanceFilterNone] forKey:@"distanceFilter"];
    [locationTrackerSettings setValue:@"0" forKey:@"timeFilter"];
    
    [locationTrackerSettings setValue:@"300.0" forKey:@"trackDetectionTime"];
    [locationTrackerSettings setValue:@"100.0" forKey:@"trackSeparationDistance"];
    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%d", NO] forKey:@"locationTrackerAutoStart"];
    [locationTrackerSettings setValue:@"8.0" forKey:@"locationTrackerStartTime"];
    [locationTrackerSettings setValue:@"20.0" forKey:@"locationTrackerFinishTime"];
    [locationTrackerSettings setValue:@"100.0" forKey:@"maxSpeedThreshold"];
    [locationTrackerSettings setValue:[NSString stringWithFormat:@"%d", NO] forKey:@"getLocationsWithNegativeSpeed"];
        
    [defaultSettings setValue:locationTrackerSettings forKey:@"location"];
    
    
    NSMutableDictionary *mapSettings = [NSMutableDictionary dictionary];
    [mapSettings setValue:[NSString stringWithFormat:@"%d", MKUserTrackingModeNone] forKey:@"mapHeading"];
    [mapSettings setValue:[NSString stringWithFormat:@"%d", MKMapTypeStandard] forKey:@"mapType"];
    [mapSettings setValue:@"1.5" forKey:@"trackScale"];
    [mapSettings setValue:[NSString stringWithFormat:@"%d", NO] forKey:@"showLocationInsteadOfMap"];
    
    [defaultSettings setValue:mapSettings forKey:@"map"];
    
    
    NSMutableDictionary *syncerSettings = [NSMutableDictionary dictionary];
    [syncerSettings setValue:@"20" forKey:@"fetchLimit"];
    [syncerSettings setValue:@"240.0" forKey:@"syncInterval"];
    [syncerSettings setValue:@"https://system.unact.ru/iproxy/rest" forKey:@"restServerURI"];
    [syncerSettings setValue:@"https://system.unact.ru/iproxy/news/megaport" forKey:@"recieveDataServerURI"];
    [syncerSettings setValue:@"https://system.unact.ru/iproxy/chest/test" forKey:@"sendDataServerURI"];
    [syncerSettings setValue:@"https://github.com/sys-team/ASA.chest" forKey:@"xmlNamespace"];
    
    [defaultSettings setValue:syncerSettings forKey:@"syncer"];
    
    NSMutableDictionary *batteryTrackerSettings = [NSMutableDictionary dictionary];
    [batteryTrackerSettings setValue:[NSString stringWithFormat:@"%d", NO] forKey:@"batteryTrackerAutoStart"];
    [batteryTrackerSettings setValue:@"8.0" forKey:@"batteryTrackerStartTime"];
    [batteryTrackerSettings setValue:@"20.0" forKey:@"batteryTrackerFinishTime"];
    
    [defaultSettings setValue:batteryTrackerSettings forKey:@"battery"];
    
    
    NSMutableDictionary *generalSettings = [NSMutableDictionary dictionary];
    [generalSettings setValue:[NSString stringWithFormat:@"%d", YES] forKey:@"localAccessToSettings"];
    [generalSettings setValue:@"120" forKey:@"blockInterval"];
    [generalSettings setValue:@"1000" forKey:@"maxOkDistanceFromTerminal"];
    [generalSettings setValue:@"20" forKey:@"OkInterval"];
    [generalSettings setValue:@"+0300" forKey:@"Timezone"];
    
    [defaultSettings setValue:generalSettings forKey:@"general"];
    
    return [defaultSettings copy];
    
}

- (NSString *)normalizeValue:(NSString *)value forKey:(NSString *)key {
    
//    [super normalizeValue:value forKey:key];
    
    NSArray *positiveDouble = @[@"requiredAccuracy", @"trackDetectionTime", @"trackSeparationDistance", @"trackScale", @"fetchLimit", @"syncInterval", @"HTCheckpointInterval", @"deviceMotionUpdateInterval", @"blockInterval", @"maxOkDistanceFromTerminal", @"OkInterval"];
    
    NSArray *boolValue = @[@"TrackerAutoStart", @"localAccessToSettings", @"deviceMotionUpdate", @"getLocationsWithNegativeSpeed", @"showLocationInsteadOfMap"];
    
    NSArray *URIValue = @[@"restServerURI", @"xmlNamespace", @"recieveDataServerURI", @"sendDataServerURI"];
    
    NSArray *stingValue = @[@"Timezone"];
    
    if ([positiveDouble containsObject:key]) {
        if ([self isPositiveDouble:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else  if ([boolValue containsObject:key]) {
        if ([self isBool:value]) {
            return [NSString stringWithFormat:@"%d", [value boolValue]];
        }
        
    } else if ([URIValue containsObject:key]) {
        if ([self isValidURI:value]) {
            return value;
        }
    } else if ([stingValue containsObject:key] && [value isKindOfClass:[NSString class]]) {
            return value;
        
    } else if ([key isEqualToString:@"desiredAccuracy"]) {
        double dValue = [value doubleValue];
        if (dValue == -2 || dValue == -1 || dValue == 10 || dValue == 100 || dValue == 1000 || dValue == 3000) {
            return [NSString stringWithFormat:@"%f", dValue];
        }
        
    } else if ([key isEqualToString:@"distanceFilter"]) {
        double dValue = [value doubleValue];
        if (dValue == -1 || dValue >= 0) {
            return [NSString stringWithFormat:@"%f", dValue];
        }
        
    } else if ([key isEqualToString:@"timeFilter"] || [key isEqualToString:@"maxSpeedThreshold"]) {
        double dValue = [value doubleValue];
        if (dValue >= 0) {
            return [NSString stringWithFormat:@"%f", dValue];
        }
        
    } else if ([key isEqualToString:@"HTSlowdownValue"]) {
        double dValue = [value doubleValue];
        if (dValue > 0 && dValue < 1) {
            return [NSString stringWithFormat:@"%f", dValue];
        }
        
    } else if ([key hasSuffix:@"TrackerStartTime"] || [key hasSuffix:@"TrackerFinishTime"]) {
        if ([self isValidTime:value]) {
            return [NSString stringWithFormat:@"%f", [value doubleValue]];
        }
        
    } else if ([key isEqualToString:@"mapHeading"] || [key isEqualToString:@"mapType"]) {
        double iValue = [value doubleValue];
        if (iValue == 0 || iValue == 1 || iValue == 2) {
            return [NSString stringWithFormat:@"%.f", iValue];
        }
        
    } else if ([key isEqualToString:@"mapProvider"]) {
        double iValue = [value doubleValue];
        if (iValue == 0 || iValue == 1) {
            return [NSString stringWithFormat:@"%.f", iValue];
        }
    }
    
    return nil;
}

-(NSString*)getSettingValueForName:(NSString *)name inGroup:(NSString*)group {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.group == %@ && SELF.name == %@", group, name];
    STSettings *setting = [[[self currentSettings] filteredArrayUsingPredicate:predicate] lastObject];
    return setting.value;
}

@end
