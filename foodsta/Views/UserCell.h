//
//  UserCell.h
//  foodsta
//
//  Created by constanceh on 7/19/21.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) PFUser *user;

@property (weak, nonatomic) IBOutlet UIImageView *followProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *followUsernameLabel;


@end

NS_ASSUME_NONNULL_END
