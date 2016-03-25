//
//  STTTAgentComponent.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 22/03/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import "STTTAgentComponent.h"
#import "STTTAgentComponentGroup.h"
#import "STTTAgentTerminalComponent.h"

@implementation STTTAgentComponent

- (STTTAgentTerminalComponent *)actualTerminalComponent {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isdeleted == NO"];
    NSSet *terminalComponents = [self.terminalComponents filteredSetUsingPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)];
    STTTAgentTerminalComponent *terminalComponent = [terminalComponents sortedArrayUsingDescriptors:@[sortDescriptor]].lastObject;
    
    return terminalComponent;
    
}

- (BOOL)isBroken {
    return ([self actualTerminalComponent]) ? [self actualTerminalComponent].isBroken.boolValue : NO;
}

- (BOOL)isInstalled {

    if (self.wasInitiallyInstalled) {
        return ![self isBroken];
    } else {
        return ([self actualTerminalComponent] != nil);
    }

}


@end
