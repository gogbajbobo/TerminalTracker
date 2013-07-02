//
//  STTTTaskController.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTTaskController.h"

@implementation STTTTaskController


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
    static NSString *cellIdentifier = @"taskCell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 140, 24)];
    
    firstLabel.text = @"task";
    
    firstLabel.font = font;
    [cell.contentView addSubview:firstLabel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



@end
