//
//  STTTTerminalController.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTTerminalController.h"
#import "STTTAgentTerminal.h"
#import "STTTTerminalLocation.h"
#import "STTTLocationController.h"

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
//        request.predicate = [NSPredicate predicateWithFormat:@"SELF.track == %@", self.track];
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
        for (NSManagedObject *object in self.resultsController.fetchedObjects) {
            //                NSLog(@"distance %@", [object valueForKey:@"distance"]);
        }
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
//        NSLog(@"0");
//        [terminal setPrimitiveValue:0 forKey:@"distance"];
        [terminal setValue:0 forKey:@"distance"];
    } else {
        CLLocationDistance distance = [currentLocation distanceFromLocation:terminalLocation];
//        NSLog(@"%f", distance);
//        [terminal setPrimitiveValue:[NSNumber numberWithDouble:distance] forKey:@"distance"];
        [terminal setValue:[NSNumber numberWithDouble:distance] forKey:@"distance"];
    }

}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerWillChangeContent");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"controllerDidChangeContent");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"terminalControllerDidChangeContent" object:self];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //    NSLog(@"controller didChangeObject");
    
    if ([[self.session status] isEqualToString:@"running"]) {
    
        
        if (type == NSFetchedResultsChangeDelete) {
            
            //        NSLog(@"NSFetchedResultsChangeDelete");
            
//            if ([self.tableView numberOfRowsInSection:indexPath.section] == 1) {
//                [self.tableView reloadData];
//            } else {
//                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
//                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
//            }
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"trackDeleted" object:self.currentSession userInfo:[NSDictionary dictionaryWithObject:anObject forKey:@"track"]];
            
            
        } else if (type == NSFetchedResultsChangeInsert) {
            
            //        NSLog(@"NSFetchedResultsChangeInsert");
            
//            [self.tableView reloadData];
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"trackInserted" object:self.currentSession userInfo:[NSDictionary dictionaryWithObject:anObject forKey:@"track"]];
            
            
        } else if (type == NSFetchedResultsChangeUpdate) {
            
            //        NSLog(@"NSFetchedResultsChangeUpdate");
            
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"trackUpdated" object:self.currentSession userInfo:[NSDictionary dictionaryWithObject:anObject forKey:@"track"]];
            
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
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
    STTTAgentTerminal *terminal = (STTTAgentTerminal *)[[sectionInfo objects] objectAtIndex:indexPath.row];
    
//    NSLog(@"terminal.location.latitude %@, terminal.location.longitude %@", terminal.location.latitude, terminal.location.longitude);
    
    NSString *code = terminal.code ? terminal.code : @"Нет данных";
    NSString *errorText = terminal.errorText ? terminal.errorText : @"";
    NSString *address = terminal.address ? terminal.address : @"Нет данных";

    cell.textLabel.text = [NSString stringWithFormat:@"%@\t%@", code, errorText];
    cell.detailTextLabel.text = address;
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


@end
