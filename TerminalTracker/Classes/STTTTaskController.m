//
//  STTTTaskController.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTTaskController.h"
#import "STTTTaskLocation.h"

@interface STTTTaskController() <NSFetchedResultsControllerDelegate>

@end


@implementation STTTTaskController


- (void)setSession:(STSession *)session {

    if (session != _session) {
        _session = session;
        [self performFetch];
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
    NSLog(@"controllerWillChangeContent");
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerDidChangeContent");
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"taskControllerDidChangeContent" object:self];
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
            
//            NSLog(@"NSFetchedResultsChangeUpdate");
//            NSLog(@"anObject %@", anObject);
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
    cell.textLabel.text = task.terminalBreakName;
    cell.detailTextLabel.text = task.terminal.address;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *infoText;
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:task.doBefore];
    
    if (timeInterval > 0 && timeInterval <= 24 * 3600) {
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else if (timeInterval <= 7 * 24 * 3600) {
        dateFormatter.dateFormat = @"EEEE";
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
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
    infoLabel.tag = 666;
    
    [[cell.contentView viewWithTag:666] removeFromSuperview];
    [cell.contentView addSubview:infoLabel];

    
    NSTimeInterval remainingTime = [task remainingTime];
    UIColor *backgroundColor = cell.contentView.backgroundColor;
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
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
//    NSLog(@"backgroundColor %@", backgroundColor);
//    NSLog(@"textColor %@", textColor);
    
    
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
