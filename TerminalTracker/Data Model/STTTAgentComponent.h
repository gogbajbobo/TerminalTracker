//
//  STTTAgentComponent.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 04/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STTTAgentTaskComponent;

@interface STTTAgentComponent : STComment

@property (nonatomic, retain) NSString * serial;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) STTTAgentTaskComponent *taskComponent;

@end
