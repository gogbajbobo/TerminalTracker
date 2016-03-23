//
//  STTTAgentTerminal.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 22/03/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import "STTTAgentTerminal.h"
#import "STTTAgentTask.h"
#import "STTTAgentTerminalComponent.h"
#import "STTTTerminalLocation.h"

@implementation STTTAgentTerminal

- (NSNumber *)sectionNumber {
    
    double distance = [self.distance doubleValue];
    
    //    NSLog(@"distance %f", distance);
    
    if (distance < 1000) {
        return [NSNumber numberWithInt:0];
    } else if (distance >= 1000 && distance < 2000) {
        return [NSNumber numberWithInt:1];
    } else if (distance >= 2000 && distance < 5000) {
        return [NSNumber numberWithInt:2];
    } else if (distance >= 5000) {
        return [NSNumber numberWithInt:3];
    } else {
        return [NSNumber numberWithInt:0];
    }
    
}

- (UIImage *)mobileOpLogo {
    
    CGSize logoSize = CGSizeMake(22, 22);
    
    if ([self.mobileop isEqualToString:@"Билайн"]) {
        
        return [self resizeImage:[UIImage imageNamed:@"beeline.png"] toSize:logoSize allowRetina:YES];
        
    } else if ([self.mobileop isEqualToString:@"Мегафон"]) {
        
        return [self resizeImage:[UIImage imageNamed:@"megafon.png"] toSize:logoSize allowRetina:YES];
        
    } else if ([self.mobileop isEqualToString:@"МТС"]) {
        
        return [self resizeImage:[UIImage imageNamed:@"mts.png"] toSize:logoSize allowRetina:YES];
        
    } else if ([self.mobileop isEqualToString:@"Теле2"]) {
        
        return [self resizeImage:[UIImage imageNamed:@"tele2.png"] toSize:logoSize allowRetina:YES];
        
    } else if ([self.mobileop isEqualToString:@"Неизвестный оператор"]) {
        
        return [self resizeImage:[UIImage imageNamed:@"unknown.png"] toSize:logoSize allowRetina:YES];
        
    } else {
        
        return nil;
        
    }
    
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size allowRetina:(BOOL)retina {
    
    if (image.size.height > 0 && image.size.width > 0) {
        
        CGFloat width = size.width;
        CGFloat height = size.height;
        
        if (image.size.width >= image.size.height) {
            
            height = width * image.size.height / image.size.width;
            
        } else {
            
            width = height * image.size.width / image.size.height;
            
        }
        
        // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1.0 to force exact pixel size.
        
        CGFloat scale = (retina) ? 0.0 : 1.0;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width ,height), NO, scale);
        [image drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage;
        
    } else {
        
        return nil;
        
    }
    
}

//- (void)awakeFromFetch {
//    [super awakeFromFetch];
//    NSLog(@"awakeFromFetch");
//    [self calculateDistance];
//}
//
//- (void)awakeFromInsert {
//    [super awakeFromInsert];
//    NSLog(@"awakeFromInsert");
//    [self calculateDistance];
//}
//
//
//- (void)calculateDistance {
//    CLLocation *currentLocation = [[STTTLocationController sharedLC] currentLocation];
//    CLLocation *terminalLocation = [[CLLocation alloc] initWithLatitude:[self.location.latitude doubleValue] longitude:[self.location.longitude doubleValue]];
//
//    if (!currentLocation || !terminalLocation) {
//        NSLog(@"0");
//        [self setPrimitiveValue:0 forKey:@"distance"];
//    } else {
//        CLLocationDistance distance = [currentLocation distanceFromLocation:terminalLocation];
//        NSLog(@"%f", distance);
//        [self setPrimitiveValue:[NSNumber numberWithDouble:distance] forKey:@"distance"];
//    }
//
//}


@end
