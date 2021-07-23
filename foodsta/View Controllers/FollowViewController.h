//
//  FollowViewController.h
//  foodsta
//
//  Created by constanceh on 7/22/21.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface FollowViewController : UIViewController

@property (nonatomic, strong) PFUser *user;
@property (nonatomic) bool isFollowing; // Whether view controller should display the user's followers or followings

@end

NS_ASSUME_NONNULL_END
