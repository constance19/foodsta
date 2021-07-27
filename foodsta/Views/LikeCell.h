//
//  likeCell.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface LikeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *selfLikeButton;
@property (weak, nonatomic) IBOutlet UIButton *containerLikeButton;
@property (nonatomic, strong) Post *post;

@end

NS_ASSUME_NONNULL_END
