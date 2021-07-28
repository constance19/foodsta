//
//  imageCell.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "LikeCell.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@protocol ImageCellDelegate;

@interface ImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *locationImage;
@property (weak, nonatomic) IBOutlet PFImageView *selfLocationImage;
@property (weak, nonatomic) IBOutlet UIImageView *containerLocationImage;

@property (nonatomic, strong) Post *post;
@property (weak, nonatomic) IBOutlet UIImageView *likeHeart;
@property (nonatomic, weak) id<ImageCellDelegate> delegate;

@end


@protocol ImageCellDelegate
- (void)imageCell:(ImageCell *) imageCell didDoubleTap:(NSString *)likes;
@end

NS_ASSUME_NONNULL_END
