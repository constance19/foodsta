//
//  imageCell.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *locationImage;

@property (weak, nonatomic) IBOutlet PFImageView *selfLocationImage;

@property (weak, nonatomic) IBOutlet UIImageView *containerLocationImage;

@end

NS_ASSUME_NONNULL_END
