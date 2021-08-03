//
//  UsernameTimestampCell.m
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import "UsernameTimestampCell.h"

@implementation UsernameTimestampCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *usernameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUsername:)];
    [self.usernameLabel addGestureRecognizer:usernameTap];
    [self.usernameLabel setUserInteractionEnabled:YES];
    
    // Round corners of username label
    self.usernameLabel.layer.masksToBounds = YES;
    self.usernameLabel.layer.cornerRadius = 8.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)didTapUsername:(UITapGestureRecognizer *)sender{
    [self.delegate usernameTimestampCell:self didTap:self.post.author];
}

@end
