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
#import "STUtilities.h"
#import "STTTAgentTask+cellcoloring.h"

@interface STTTTaskController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STQueue *noAddressTerminals;
@property (nonatomic) BOOL checkingTasks;
//@property (nonatomic, weak) STTTSyncer *syncer;

@end


@implementation STTTTaskController


- (void)setSession:(STSession *)session {

    if (session != _session) {
        _session = session;
        [self performFetch];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncerRecievedAllData:) name:@"syncerRecievedAllData" object:self.session.syncer];
        [self checkNoAddressTasks];
    }
    
}

- (void)syncerRecievedAllData:(NSNotification *)notification {
    [self deleteRottenTasks];
    [self checkNoAddressTasks];
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

    if (!self.checkingTasks) {
        self.checkingTasks = YES;
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
    }
    
    
    if (self.noAddressTerminals.count > 0) {
        
        NSString *logMessage = [NSString stringWithFormat:@"No terminal data tasks count %d", self.noAddressTerminals.count];
        [[(STSession *)self.session logger] saveLogMessageWithText:logMessage type:@""];

        [self getAddressForNoAddressTasks];
        
    } else {
        
        self.noAddressTerminals = nil;
        self.checkingTasks = NO;
        
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
            NSString *terminalXid = [NSString stringWithFormat:@"%@", CFUUIDCreateString(nil, CFUUIDCreateFromUUIDBytes(nil, *(CFUUIDBytes *)[terminal.xid bytes]))];
            NSString *serverURL = [NSString stringWithFormat:@"%@/megaport.iAgentTerminal/%@", [(STTTSyncer *)self.session.syncer restServerURI], terminalXid];
            
            NSString *logMessage = [NSString stringWithFormat:@"Get data for terminal %@", terminalXid];
            [[(STSession *)self.session logger] saveLogMessageWithText:logMessage type:@""];

//            NSLog(@"serverURL %@", serverURL);
            [self.session.syncer sendData:nil toServer:serverURL withParameters:nil];
        }
    }
    
}

- (void)deleteRottenTasks {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentTask class])];
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"doBefore" ascending:YES selector:@selector(compare:)], nil];
    NSError *error;
    NSArray *allTasks = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *nowDate = [NSDate date];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSDate *today = [dateFormatter dateFromString:[dateFormatter stringFromDate:nowDate]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.doBefore <= %@ && SELF.servstatus == 0", today];
    
    for (STTTAgentTask *task in [allTasks filteredArrayUsingPredicate:predicate]) {
        [self.session.document.managedObjectContext deleteObject:task];
    }
    
}

- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentTask class])];

        request.sortDescriptors = [NSArray arrayWithObjects:
                                   [NSSortDescriptor sortDescriptorWithKey:@"servstatus" ascending:YES selector:@selector(compare:)],
                                   [NSSortDescriptor sortDescriptorWithKey:@"routePriority" ascending:NO selector:@selector(compare:)],
                                   [NSSortDescriptor sortDescriptorWithKey:@"doBefore" ascending:YES selector:@selector(compare:)],
                                   nil];
        if (self.terminal) {
            request.predicate = [NSPredicate predicateWithFormat:@"SELF.terminal == %@", self.terminal];
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSDate *nowDate = [NSDate date];
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            NSDate *today = [dateFormatter dateFromString:[dateFormatter stringFromDate:nowDate]];
            request.predicate = [NSPredicate predicateWithFormat:@"SELF.doBefore >= %@", today];
        }
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:@"servstatus" cacheName:nil];
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%i|%@ : %@",[task.routePriority intValue],task.terminal.code,task.terminalBreakName];
    cell.detailTextLabel.text = task.terminal.address;
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    cell.backgroundColor = [task getBackgroundColorForDisplaying];
    cell.textLabel.textColor = [task getTextColorForDisplaying];
    cell.detailTextLabel.textColor = [task getTextColorForDisplaying];

    NSString *infoText = [STUtilities stringWithRelativeDateFromDate:task.doBefore];
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
    infoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [[cell.contentView viewWithTag:666] removeFromSuperview];
    [cell.contentView addSubview:infoLabel];
    
    return cell;
}

@end
