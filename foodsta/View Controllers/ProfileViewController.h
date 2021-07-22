//
//  ProfileViewController.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController

@property PFUser *user;
@property (nonatomic) bool hideBackButton;

@end

NS_ASSUME_NONNULL_END
