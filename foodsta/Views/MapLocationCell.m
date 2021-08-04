//
//  MapLocationCell.m
//  foodsta
//
//  Created by constanceh on 7/24/21.
//

#import "MapLocationCell.h"

@implementation MapLocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Add tap gesture recognizer for username label
    UITapGestureRecognizer *usernameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUsername:)];
    [self.usernameLabel addGestureRecognizer:usernameTap];
    [self.usernameLabel setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)didTapUsername:(UITapGestureRecognizer *)sender{
    [self.delegate mapLocationCell:self didTap:self.user];
}


@end
