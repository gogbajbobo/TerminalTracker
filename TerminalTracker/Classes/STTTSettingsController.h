//
//  STTTSettingsController.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STSettingsController.h"

@interface STTTSettingsController : STSettingsController
+ (id)sharedSTTTSettingsController;
- (NSString*)getSettingValueForName:(NSString *)name inGroup:(NSString*)group;
@end
