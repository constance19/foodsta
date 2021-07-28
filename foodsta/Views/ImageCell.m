//
//  imageCell.m
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import "ImageCell.h"
#import "Post.h"

@implementation ImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Add double tap gesture recognizer to post image
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapImage:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.locationImage addGestureRecognizer:doubleTap];
}

// Like the post, use delegate to toggle like button and set like count
- (void)doubleTapImage:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        PFUser *currentUser = [PFUser currentUser];
        Post *post = self.post;
        
        // If post is already liked, do not do anything except show the heart animation
        NSMutableArray *liked = currentUser[@"liked"];
        if ([liked containsObject:self.post.objectId]) {
            // Animate heart that appears upon double tapping
            [self animateHeart];
            return;
        }
        
        // Initialize current user's liked array if necessary
        if (liked == nil) {
            currentUser[@"liked"] = [[NSMutableArray alloc] init];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error updating current user's liked array", error.localizedDescription);
                } else {
                    NSLog(@"Successfully updated current user's liked array!");
                }
            }];
        }
        
        // Add newly liked post to user's "liked" array
        [liked addObject: post.objectId];
        currentUser[@"liked"] = liked;
        
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
        
        // Animate heart that appears upon double tapping
        [self animateHeart];
    }
}

// Animate heart that appears upon double tapping
- (void) animateHeart {
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.likeHeart.transform = CGAffineTransformMakeScale(1.3, 1.3);
            self.likeHeart.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.likeHeart.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.likeHeart.transform = CGAffineTransformMakeScale(1.3, 1.3);
                self.likeHeart.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.likeHeart.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }];
    }];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
