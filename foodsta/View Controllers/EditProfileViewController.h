//
//  EditProfileViewController.h
//  foodsta
//
//  Created by constanceh on 7/14/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditProfileViewController : UIViewController

@property (nonatomic, strong) void (^onDismiss)(UIViewController *sender, UIImage *profileImage, NSString *bio);

@end

NS_ASSUME_NONNULL_END
