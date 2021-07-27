//
//  ContainerFeedViewController.h
//  foodsta
//
//  Created by constanceh on 7/26/21.
//

#import <UIKit/UIKit.h>
#import "FeedDataSource.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ContainerFeedViewController : UIViewController

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) FeedDataSource *feedDataSource;

@end

NS_ASSUME_NONNULL_END
