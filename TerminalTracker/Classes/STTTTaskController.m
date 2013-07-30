//
//  STTTTaskController.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTTaskController.h"
#import "STTTTaskLocation.h"
#import <STManagedTracker/STQueue.h>
#import "STTTSyncer.h"

@interface STTTTaskController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STQueue *noAddressTerminals;
//@property (nonatomic, weak) STTTSyncer *syncer;

@end


@implementation STTTTaskController


- (void)setSession:(STSession *)session {

    if (session != _session) {
        _session = session;
        [self performFetch];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNoAddressTasks) name:@"syncerRecievedAllData" object:self.session.syncer];
        [self checkNoAddressTasks];
    }
    
}

- (STQueue *)noAddressTerminals {
    if (!_noAddressTerminals) {
        _noAddressTerminals = [[STQueue alloc] init];
        _noAddressTerminals.queueLength = 1;
    }
    return _noAddressTerminals;
}

- (void)checkNoAddressTasks {
    [self.tableView reloadData];
//    NSLog(@"fetchedObjects.count %d", self.resultsController.fetchedObjects.count);
    for (STTTAgentTask *task in self.resultsController.fetchedObjects) {
//        NSLog(@"terminal.address %@", task.terminal.address);
        if (!task.terminal.address) {
            if (![self.noAddressTerminals containsObject:task.terminal]) {
                if (self.noAddressTerminals.queueLength == self.noAddressTerminals.count) {
                    self.noAddressTerminals.queueLength += 1;
                }
                [self.noAddressTerminals enqueue:task.terminal];
            }
        }
    }
    if (self.noAddressTerminals.count > 0) {
        NSLog(@"noAddressTasks.count %d", self.noAddressTerminals.count);
//        NSLog(@"queueLength %d", self.noAddressTerminals.queueLength);
        [self getAddressForNoAddressTasks];
    }
}

-(void)getAddressForNoAddressTasks {
    
    if (!self.session.syncer.syncing) {
        STTTAgentTerminal *terminal = [self.noAddressTerminals dequeue];
//        NSLog(@"terminal %@", terminal);
        if (!terminal) {
            self.noAddressTerminals = nil;
        } else {
            self.session.syncer.syncing = YES;
            NSString *serverURL = [NSString stringWithFormat:@"%@/megaport.iAgentTerminal/%@", [(STTTSyncer *)self.session.syncer restServerURI], CFUUIDCreateString(nil, CFUUIDCreateFromUUIDBytes(nil, *(CFUUIDBytes *)[terminal.xid bytes]))];
//            NSLog(@"serverURL %@", serverURL);
            [self.session.syncer sendData:nil toServer:serverURL withParameters:nil];
        }
    }
    
}


- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentTask class])];
        request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"visited" ascending:YES selector:@selector(compare:)], [NSSortDescriptor sortDescriptorWithKey:@"doBefore" ascending:YES selector:@selector(compare:)], nil];
        if (self.terminal) {
            request.predicate = [NSPredicate predicateWithFormat:@"SELF.terminal == %@", self.terminal];
        }
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:@"visited" cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
}

- (void)performFetch {
    self.resultsController = nil;
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"performFetch error %@", error);
    } else {
        //            NSLog(@"fetchedObjects %@", self.resultsController.fetchedObjects);
        for (NSManagedObject *object in self.resultsController.fetchedObjects) {
            //                NSLog(@"distance %@", [object valueForKey:@"distance"]);
        }
    }
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"controllerWillChangeContent");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"taskControllerDidChangeContent");
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"taskControllerDidChangeContent" object:self];
    [self checkNoAddressTasks];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
//    NSLog(@"controller didChangeObject");
//    NSLog(@"indexPath %@, newIndexPath %@", indexPath, newIndexPath);
    
    if ([[self.session status] isEqualToString:@"running"]) {
        
        
        if (type == NSFetchedResultsChangeDelete) {
            
//            NSLog(@"NSFetchedResultsChangeDelete");
            
        } else if (type == NSFetchedResultsChangeInsert) {
            
//            NSLog(@"NSFetchedResultsChangeInsert");
            
        } else if (type == NSFetchedResultsChangeUpdate) {
            
//            NSLog(@"NSFetchedResultsChangeUpdate");
            
        } else if (type == NSFetchedResultsChangeMove) {
            
//            NSLog(@"NSFetchedResultsChangeMove");
            
        }
        
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
//    NSLog(@"controller didChangeSection");
//    NSLog(@"sectionIndex %d", sectionIndex);
    
    if (type == NSFetchedResultsChangeDelete) {
        
//        NSLog(@"NSFetchedResultsChangeDelete");
    
    } else if (type == NSFetchedResultsChangeInsert) {
        
//        NSLog(@"NSFetchedResultsChangeInsert");
        
        
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.resultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:section];
    
    NSUInteger sectionName = [[sectionInfo name] integerValue];
    
    switch (sectionName) {
        case 0:
            return @"Невыполненные";
            break;
        case 1:
            return @"Выполненные";
            break;

        default:
            return @"";
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"taskCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    STTTAgentTask *task = (STTTAgentTask *)[[sectionInfo objects] objectAtIndex:indexPath.row];
    
//    NSLog(@"task.visited %@", task.visited);
//    NSLog(@"indexPath %@", indexPath);
//    NSLog(@"fetchedObjects.count %d", self.resultsController.fetchedObjects.count);
//    NSLog(@"sections.count %d", [self.resultsController sections].count);
//    NSLog(@"[sectionInfo objects].count %d", [sectionInfo objects].count);

    
    cell.textLabel.text = task.terminalBreakName;
    cell.detailTextLabel.text = task.terminal.address;
    
    NSTimeInterval remainingTime = [task remainingTime];
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *textColor = [UIColor blackColor];
    
    if (!task.lts || [task.ts compare:task.lts] == NSOrderedDescending) {
        textColor = [UIColor grayColor];
    } else {
        if (![task.visited boolValue]) {
            if (remainingTime < 0) {
                textColor = [UIColor redColor];
            } else if (remainingTime > 0 && remainingTime <= 60*60) {
                backgroundColor = [UIColor redColor];
                textColor = [UIColor whiteColor];
            } else if (remainingTime < 120*60) {
                backgroundColor = [UIColor yellowColor];
            } else if (remainingTime < 180*60) {
                backgroundColor = [UIColor colorWithRed:0.56 green:0.93 blue:0.56 alpha:1];
            }
        }
    }
    
    cell.contentView.backgroundColor = backgroundColor;
    cell.textLabel.backgroundColor = backgroundColor;
    cell.detailTextLabel.backgroundColor = backgroundColor;
    cell.textLabel.textColor = textColor;
    cell.detailTextLabel.textColor = textColor;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *infoText;
    
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    if ([[dateFormatter stringFromDate:[NSDate date]] isEqualToString:[dateFormatter stringFromDate:task.doBefore]]) {
    
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        
    } else {
        
        if ([[NSDate date] timeIntervalSinceDate:task.doBefore] <= 7 * 24 * 3600 &&
            [[NSDate date] timeIntervalSinceDate:task.doBefore] >= -7 * 24 * 3600) {
            dateFormatter.dateFormat = @"EEEE";
        } else {
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
        }

    }
    
    infoText = [dateFormatter stringFromDate:task.doBefore];
    
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = [infoText sizeWithFont:font];
    
    CGFloat paddingX = 0;
    CGFloat paddingY = 0;
    CGFloat marginX = 10;
    
    CGFloat x = cell.contentView.frame.size.width - size.width - 2 * paddingX - marginX;
    CGFloat y = cell.textLabel.bounds.origin.y;
    
    CGRect frame = CGRectMake(x, y, size.width + 2 * paddingX, size.height + 2 * paddingY);
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:frame];
    infoLabel.text = infoText;
    infoLabel.font = font;
    infoLabel.textColor = [UIColor blueColor];
    infoLabel.backgroundColor = cell.contentView.backgroundColor;
    infoLabel.tag = 666;
    
    [[cell.contentView viewWithTag:666] removeFromSuperview];
    [cell.contentView addSubview:infoLabel];
    
    return cell;
}


@end
