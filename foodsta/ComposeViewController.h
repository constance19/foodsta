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

@end

NS_ASSUME_NONNULL_END