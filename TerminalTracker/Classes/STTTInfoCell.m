//
//  STTTMainInfoCell.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/31/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTInfoCell.h"

@implementation STTTInfoCell

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.infoLabel.font = [UIFont boldSystemFontOfSize:18];
    self.infoLabel.textAlignment = NSTextAlignmentRight;
    self.infoLabel.backgroundColor = [UIColor clearColor];

    CGFloat paddingX = 0;
    CGFloat paddingY = 0;
    CGFloat marginX = 10;
    CGSize size = [self.infoLabel.text sizeWithFont:self.infoLabel.font];
    CGFloat x = self.contentView.frame.size.width - size.width - 2 * paddingX - marginX;
    CGFloat y = (self.contentView.frame.size.height - size.height - 2 * paddingY) / 2;
    CGRect frame = CGRectMake(x, y, size.width + 2 * paddingX, size.height + 2 * paddingY);
    self.infoLabel.frame = frame;
    
    x = self.detailTextLabel.frame.origin.x;
    y = self.detailTextLabel.frame.origin.y;
    CGFloat height = self.detailTextLabel.frame.size.height;
    CGFloat width = self.infoLabel.frame.origin.x - x;
    frame = CGRectMake(x, y, width, height);
    self.detailTextLabel.frame = frame;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.infoLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.infoLabel];
    
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
