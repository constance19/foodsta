//
//  likeCell.m
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import "LikeCell.h"
#import "Post.h"

@implementation LikeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onTapLike:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    Post *post = self.post;
    int likeCount = [post.likeCount intValue];
    
    // Initialize current user's liked array if necessary
    if (currentUser[@"liked"] == nil) {
        currentUser[@"liked"] = [[NSMutableArray alloc] init];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error updating current user's liked array", error.localizedDescription);
            } else {
                NSLog(@"Successfully updated current user's liked array!");
            }
        }];
    }
    
    // Unlike
    if (self.likeButton.isSelected) {
        likeCount--;
        NSString *likes = [NSString stringWithFormat:@"%i", likeCount];
        [self.likeButton setTitle:likes forState:UIControlStateNormal];
        [self.likeButton setSelected:NO];
        
        NSMutableArray *liked = currentUser[@"liked"];
        [liked removeObject: post.objectId];
        currentUser[@"liked"] = liked;
    
    // Like
    } else {
        likeCount++;
        NSString *likes = [NSString stringWithFormat:@"%i", likeCount];
        [self.likeButton setTitle:likes forState:UIControlStateNormal];
        [self.likeButton setSelected:YES];
        
        NSMutableArray *liked = currentUser[@"liked"];
        [liked addObject: post.objectId];
        currentUser[@"liked"] = liked;
    }
    
    // Save current user's liked array updates to Parse
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error updating current user's liked array", error.localizedDescription);
        } else {
            NSLog(@"Successfully updated current user's liked array!");
        }
    }];
    
    // Save post's updated like count to Parse
    post.likeCount = [NSNumber numberWithInt:likeCount];
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error updating like count", error.localizedDescription);
        } else {
            NSLog(@"Successfully updated like count!");
            
        }
    }];
}

@end
