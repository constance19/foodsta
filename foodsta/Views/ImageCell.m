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
    
    // Add double tap gesture recognizer to post image in main feed
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapImage:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.locationImage addGestureRecognizer:doubleTap];
    
    // Add double tap gesture recognizer to post image in profile container feed
    UITapGestureRecognizer *containerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containerDoubleTapImage:)];
    containerDoubleTap.numberOfTapsRequired = 2;
    [self.containerLocationImage addGestureRecognizer:containerDoubleTap];
}

// Like the post in the feed tab, use delegate to toggle like button and set like count
- (void)doubleTapImage:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        PFUser *currentUser = [PFUser currentUser];
        Post *post = self.post;
        
        // If post is already liked, do not do anything except show the heart animation
        NSMutableArray *liked = currentUser[@"liked"];
        if ([liked containsObject:self.post.objectId]) {
            // Animate heart that appears upon double tapping
            [self animateHeart:self.likeHeart];
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
        
        // Use delegate to increment like count and set selected state of like button
        int likeCount = [post.likeCount intValue];
        likeCount++;
        NSString *likes = [NSString stringWithFormat:@"%i", likeCount];
        [self.delegate imageCell:self didDoubleTap:likes];
        
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
        [self animateHeart:self.likeHeart];
    }
}

// Like the post in the profile container feed, use delegate to toggle like button and set like count
- (void)containerDoubleTapImage:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        PFUser *currentUser = [PFUser currentUser];
        Post *post = self.post;
        
        // If post is already liked, do not do anything except show the heart animation
        NSMutableArray *liked = currentUser[@"liked"];
        if ([liked containsObject:self.post.objectId]) {
            // Animate heart that appears upon double tapping
            [self animateHeart:self.containerLikeHeart];
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
        
        // Use delegate to increment like count and set selected state of like button
        int likeCount = [post.likeCount intValue];
        likeCount++;
        NSString *likes = [NSString stringWithFormat:@"%i", likeCount];
        [self.delegate imageCell:self didDoubleTap:likes];
        
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
        [self animateHeart:self.containerLikeHeart];
    }
}

// Animate heart that appears upon double tapping
- (void) animateHeart: (UIImageView *)heart {
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            heart.transform = CGAffineTransformMakeScale(1.3, 1.3);
            heart.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            heart.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                heart.transform = CGAffineTransformMakeScale(1.3, 1.3);
                heart.alpha = 0.0;
            } completion:^(BOOL finished) {
                heart.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }];
    }];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
