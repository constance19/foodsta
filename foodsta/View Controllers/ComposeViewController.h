//
//  ComposeViewController.h
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface ComposeViewController : UIViewController

@property (strong, nonatomic) Location *location;
@property (nonatomic) int *locationSelected;
@property (nonatomic) BOOL hideCancelButton;

@property (nonatomic) double ratingValue;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UIImage *postImage;
@property (nonatomic) BOOL hasCaption;
@property (nonatomic) BOOL hasImage;

@end

NS_ASSUME_NONNULL_END
