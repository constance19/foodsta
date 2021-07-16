//
//  imageCell.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface imageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *locationImage;

@end

NS_ASSUME_NONNULL_END
