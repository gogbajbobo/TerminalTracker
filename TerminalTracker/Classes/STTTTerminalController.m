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

@interface STTTTerminalController() <NSFetchedResultsControllerDelegate>

@end


@implementation STTTTerminalController

- (void)setSession:(STSession *)session {
    
    NSLog(@"TC setSession");
    
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
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.session.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
    //    NSLog(@"controllerDidChangeContent");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"trackControllerDidChangeContent" object:self];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"terminalCell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 140, 24)];
    
    firstLabel.text = @"terminal";
    
    firstLabel.font = font;
    [cell.contentView addSubview:firstLabel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
