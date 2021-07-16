//
//  ratingCell.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ratingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end

NS_ASSUME_NONNULL_END
