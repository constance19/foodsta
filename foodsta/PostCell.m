//
//  PostCell.m
//  foodsta
//
//  Created by constanceh on 7/13/21.
//

#import "PostCell.h"

@implementation PostCell


- (void)setPost:(Post *)post {
    _post = post;
//    NSLog(@"%@", post[@"image"]);
    self.locationImage.file = post[@"image"];
    [self.locationImage loadInBackground];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
