//
//  PostCell.h
//  foodsta
//
//  Created by constanceh on 7/13/21.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;
#import "HCSStarRatingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextView *locationView;
@property (weak, nonatomic) IBOutlet PFImageView *locationImage;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (nonatomic, strong) Post *post;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end

NS_ASSUME_NONNULL_END
