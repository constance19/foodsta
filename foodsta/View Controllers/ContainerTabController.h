//
//  ContainerTabController.h
//  foodsta
//
//  Created by constanceh on 7/26/21.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ContainerTabController : UITabBarController

@property (nonatomic, strong) PFUser *user;

@end

NS_ASSUME_NONNULL_END
