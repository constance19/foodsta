//
//  PostViewController.m
//  foodsta
//
//  Created by constanceh on 7/21/21.
//

#import "PostViewController.h"
#import "LocationAnnotationView.h"
#import "HCSStarRatingView.h"
#import "DateTools.h"
#import "ProfileViewController.h"
@import Parse;

@interface PostViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UITextView *locationView;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet PFImageView *locationImage;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likeHeart;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set rounded corners for the pop-up view
    self.popupView.layer.cornerRadius = 15;
    self.popupView.layer.masksToBounds = YES;
    
    // Set rounded corners of username label
    self.usernameLabel.layer.masksToBounds = YES;
    self.usernameLabel.layer.cornerRadius = 8.0;
    
    // Set username label
    PFUser *author = self.post.author;
    NSString *username = [[@" " stringByAppendingString:[NSString stringWithFormat:@"@%@", author.username]] stringByAppendingString:@" "];
    self.usernameLabel.text = username;
    
    // Format and set createdAtString, convert Date to String using DateTool relative time for timestamp label
    NSDate *createdAt = self.post.createdAt;
    NSString *timestamp = createdAt.shortTimeAgoSinceNow;
    self.timestampLabel.text = timestamp;
    
    // Set location view text that links to Yelp webpage
    NSMutableAttributedString *locationLink = [[NSMutableAttributedString alloc] initWithString:self.post.locationTitle];
    [locationLink addAttribute: NSLinkAttributeName value: self.post.locationUrl range: NSMakeRange(0, locationLink.length)];
    self.locationView.attributedText = locationLink;
    self.locationView.dataDetectorTypes = UIDataDetectorTypeLink;
    [self.locationView setFont:[UIFont systemFontOfSize:19 weight:UIFontWeightLight]];
    
    // Set rating view
    self.ratingView.value = [self.post.rating doubleValue];
    
    // Set post image
    self.locationImage.file = self.post.image;
    [self.locationImage loadInBackground];
    
    // Set like count
    PFUser *currentUser = [PFUser currentUser];
    NSArray *liked = currentUser[@"liked"];
    NSString *likeCount = [@" " stringByAppendingString:[NSString stringWithFormat:@"%@", self.post.likeCount]];

    // Set like button selected status
    if ([liked containsObject:self.post.objectId]) {
        [self.likeButton setSelected:YES];
        [self.likeButton setTitle:likeCount forState:UIControlStateSelected];
    } else {
        [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
    }
    
    // Set caption label
    self.captionLabel.text = self.post.caption;
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
    if ([currentUser[@"liked"] containsObject:post.objectId]) {
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

// Double tap to like gesture recognizer on the post image
- (IBAction)doubleTapImage:(id)sender {
    
    // If post is already liked, do not do anything except show the heart animation
    if (self.likeButton.isSelected) {
        [self animateHeart];
        return;
    }
    
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
    
    // Increment like count and set selected state of like button
    likeCount++;
    NSString *likes = [NSString stringWithFormat:@"%i", likeCount];
    [self.likeButton setTitle:likes forState:UIControlStateNormal];
    [self.likeButton setSelected:YES];
    
    // Add newly liked post to user's "liked" array
    NSMutableArray *liked = currentUser[@"liked"];
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

// Animate heart that appears upon double tapping
- (void)animateHeart {
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

- (IBAction)onTapClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"postProfileSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileController = navController.topViewController;
        profileController.user = self.post.author;
        profileController.hideBackButton = YES;
    }
}


@end
