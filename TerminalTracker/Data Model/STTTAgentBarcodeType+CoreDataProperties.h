//
//  STTTAgentBarcodeType+CoreDataProperties.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 10/02/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STTTAgentBarcodeType.h"

NS_ASSUME_NONNULL_BEGIN

@interface STTTAgentBarcodeType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *mask;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *symbology;

@end

NS_ASSUME_NONNULL_END
