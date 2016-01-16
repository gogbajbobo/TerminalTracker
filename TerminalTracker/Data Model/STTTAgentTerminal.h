//
//  STTTAgentTerminal.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 16/01/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STComment.h"

@class STTTAgentTask, STTTTerminalLocation;

NS_ASSUME_NONNULL_BEGIN

@interface STTTAgentTerminal : STComment

- (UIImage *)mobileOpLogo;


@end

NS_ASSUME_NONNULL_END

#import "STTTAgentTerminal+CoreDataProperties.h"
