//
//  SelfViewController.h
//  foodsta
//
//  Created by constanceh on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "FeedDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelfViewController : UIViewController

@property (nonatomic, strong) FeedDataSource *feedDataSource;

@end

NS_ASSUME_NONNULL_END
