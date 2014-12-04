//
//  STTTAgentRepairCode.h
//  TerminalTracker
//
//  Created by Sergey on 9/10/2014.
//  Copyright (c) 2014 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"


@interface STTTAgentRepairCode : STComment

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * repairName;

@end
