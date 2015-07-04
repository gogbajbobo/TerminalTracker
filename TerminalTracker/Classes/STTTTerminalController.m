//
//  STTTTerminalController.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTTerminalController.h"
#import "STTTTerminalLocation.h"
#import "STTTLocationController.h"
#import "STTTAgentTask+remainingTime.h"
#import "STUtilities.h"

@interface STTTTerminalController() <NSFetchedResultsControllerDelegate>

@end


@implementation STTTTerminalController

- (void)setSession:(STSession *)session {

    if (session != _session) {
        _session = session;
        [self performFetch];
    }

}

- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentTerminal class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES selector:@selector(compare:)]];
//        request.predicate = [NSPredicate predicateWithFormat:@"errorText != nil"];
        request.predicate = [NSPredicate predicateWithFormat:@"errorText != nil AND (ANY tasks.servstatus == 0 OR tasks.@count == 0)"];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:@"sectionNumber" cacheName:nil];
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
//        for (NSManagedObject *object in self.resultsController.fetchedObjects) {
            //                NSLog(@"distance %@", [object valueForKey:@"distance"]);
//        }
    }
}

- (void)calculateDistance {
    
    for (STTTAgentTerminal *terminal in self.resultsController.fetchedObjects) {
        [self calculateDistanceFor:terminal];
    }
    
}

- (void)calculateDistanceFor:(STTTAgentTerminal *)terminal {

    CLLocation *currentLocation = [[STTTLocationController sharedLC] currentLocation];
    CLLocation *terminalLocation = [[CLLocation alloc] initWithLatitude:[terminal.location.latitude doubleValue] longitude:[terminal.location.longitude doubleValue]];
    
    if (!currentLocation || !terminalLocation) {
        [terminal setValue:0 forKey:@"distance"];
    } else {
        CLLocationDistance distance = [currentLocation distanceFromLocation:terminalLocation];
        [terminal setValue:[NSNumber numberWithDouble:distance] forKey:@"distance"];
    }

}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerWillChangeContent");
//    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerDidChangeContent");
//    [self.tableView endUpdates];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"terminalControllerDidChangeContent" object:self];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //    NSLog(@"controller didChangeObject");
    
    
    if ([[self.session status] isEqualToString:@"running"]) {
    
        
        if (type == NSFetchedResultsChangeDelete) {
            
            
        } else if (type == NSFetchedResultsChangeInsert) {
            
            
        } else if (type == NSFetchedResultsChangeUpdate) {
            

        }
        
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
            return @"менее 1 км";
            break;
        case 1:
            return @"от 1 до 2 км";
            break;
        case 2:
            return @"от 2 до 5 км";
            break;
        case 3:
            return @"более 5 км";
            break;
            
        default:
            return @"";
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"terminalCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    STTTAgentTerminal *terminal = (STTTAgentTerminal *)[[sectionInfo objects] objectAtIndex:indexPath.row];

    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"doBefore" ascending:YES selector:@selector(compare:)];
    NSArray *sortedTasks = [terminal.tasks sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    STTTAgentTask *lastTask;
    if (sortedTasks.count > 0) {
         lastTask = (STTTAgentTask *)[sortedTasks objectAtIndex:0];
    }
    
    NSString *code = terminal.code ? terminal.code : @"Н/Д";

    cell.textLabel.text = [NSString stringWithFormat:@"%@", code];
    cell.detailTextLabel.text = terminal.address ? terminal.address : @"Нет данных";
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *infoText = [STUtilities stringWithRelativeDateFromDate:terminal.lastActivityTime];
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
    infoLabel.tag = 666;
    infoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [[cell.contentView viewWithTag:666] removeFromSuperview];
    [cell.contentView addSubview:infoLabel];

    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}




@end
