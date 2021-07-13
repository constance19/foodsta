//
//  LocationCell.h
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocationCell : UITableViewCell

@property (strong, nonatomic) Location *location;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;


@end

NS_ASSUME_NONNULL_END
