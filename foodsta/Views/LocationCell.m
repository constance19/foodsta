//
//  LocationCell.m
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import "LocationCell.h"

@implementation LocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIColor *myGreen = [UIColor colorWithRed:0.429 green:0.604 blue:0.576 alpha:0.3];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = myGreen;
    [self setSelectedBackgroundView:bgColorView];
}

@end
