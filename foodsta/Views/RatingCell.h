//
//  ratingCell.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RatingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *selfRatingView;

@end

NS_ASSUME_NONNULL_END
