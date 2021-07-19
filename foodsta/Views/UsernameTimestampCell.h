//
//  UsernameTimestampCell.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UsernameTimestampCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

@property (weak, nonatomic) IBOutlet UILabel *selfUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *selfTimestampLabel;


@end

NS_ASSUME_NONNULL_END
