//
//  MapLocationCell.h
//  foodsta
//
//  Created by constanceh on 7/24/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapLocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *locationView;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

NS_ASSUME_NONNULL_END
