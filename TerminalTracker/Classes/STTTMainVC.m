//
//  STMainVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/24/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTMainVC.h"
#import <STManagedTracker/STSessionManager.h>

@interface STTTMainVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *terminalView;
@property (nonatomic, strong) UIView *taskView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) BOOL tableViewIsShown;
@property (nonatomic) BOOL tasksIsShown;
@property (nonatomic) BOOL terminalsIsShown;

@end

@implementation STTTMainVC


- (void)taskViewTap {
    NSLog(@"taskViewTap");
    if (!self.tableViewIsShown) {
        [self shrinkInfoViews];
        self.tasksIsShown = YES;
        [self showTableView];
        
    } else {
        if (self.tasksIsShown) {
            self.tasksIsShown = NO;
            [self.tableView removeFromSuperview];
            self.tableView = nil;
            self.tableViewIsShown = NO;
            [self fullSizeInfoViews];
        } else {
            NSLog(@"show tasks table");
            self.terminalsIsShown = NO;
            self.tasksIsShown = YES;
            [self.tableView reloadData];
        }
    }
}

- (void)terminalViewTap {
    NSLog(@"terminalViewTap");
    if (!self.tableViewIsShown) {
        [self shrinkInfoViews];
        self.terminalsIsShown = YES;
        [self showTableView];
        
    } else {
        if (self.terminalsIsShown) {
            self.terminalsIsShown = NO;
            [self.tableView removeFromSuperview];
            self.tableView = nil;
            self.tableViewIsShown = NO;
            [self fullSizeInfoViews];
        } else {
            NSLog(@"show terminals table");
            self.tasksIsShown = NO;
            self.terminalsIsShown = YES;
            [self.tableView reloadData];
        }
    }

}

- (void)shrinkInfoViews {
    self.taskView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 54);
    self.terminalView.frame = CGRectMake(0, self.view.bounds.size.height - 54, self.view.bounds.size.width, 54);
}

- (void)fullSizeInfoViews {
    self.taskView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2);
    self.terminalView.frame = CGRectMake(0, self.view.bounds.size.height / 2, self.view.bounds.size.width, self.view.bounds.size.height / 2);
}

- (void)showTableView {
    self.tableViewIsShown = YES;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, self.view.bounds.size.width, self.view.bounds.size.height - 108) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}


- (void)viewInit {
//    NSLog(@"self.view %@", self.view);
//    NSLog(@"self.navigationController.navigationBar %@", self.navigationController.navigationBar);
    
    CGFloat halfHeight = (self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height) / 2;

    self.taskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, halfHeight)];
    self.taskView.backgroundColor = [UIColor greenColor];
    
    UIGestureRecognizer *taskViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taskViewTap)];
    [self.taskView addGestureRecognizer:taskViewTap];
    
//    UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
//    taskLabel.text = @"TASK";
//    [self.taskView addSubview:taskLabel];
    
    self.terminalView = [[UIView alloc] initWithFrame:CGRectMake(0, halfHeight, self.view.bounds.size.width, halfHeight)];
    self.terminalView.backgroundColor = [UIColor blueColor];
    
    UIGestureRecognizer *terminalViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(terminalViewTap)];
    [self.terminalView addGestureRecognizer:terminalViewTap];
    
//    UILabel *terminalLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.height / 2, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
//    terminalLabel.text = @"TERMINAL";
//    [self.terminalView addSubview:terminalLabel];
    
    [self.view addSubview:self.taskView];
    [self.view addSubview:self.terminalView];
    
    self.terminalController = [[STTTTerminalController alloc] init];
    self.terminalController.session = [[STSessionManager sharedManager] currentSession];
    
    self.locationController = [[STTTLocationController alloc] init];
    
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
    static NSString *cellIdentifier = @"checkCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 140, 24)];
    
    NSString *text = self.terminalsIsShown ? @"terminal" : @"task";
    
    firstLabel.text = text;
    
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

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:indexPath.section];
//    STHTLocation *location = (STHTLocation *)[[sectionInfo objects] objectAtIndex:indexPath.row];
//    NSString *message = [NSString stringWithFormat:@"timestamp %@ \r\n accuracy %@ \r\n", location.timestamp, location.horizontalAccuracy];
//
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location info" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    [alert show];
//}



#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewInit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
