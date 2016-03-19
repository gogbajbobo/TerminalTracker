//
//  STTTSubtitleTableViewCell.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 23/01/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import "STTTSubtitleTableViewCell.h"


@implementation STTTSubtitleTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
    
}


@end
