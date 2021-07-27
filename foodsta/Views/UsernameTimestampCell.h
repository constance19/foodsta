//
//  UsernameTimestampCell.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UsernameTimestampCellDelegate;

@interface UsernameTimestampCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

@property (weak, nonatomic) IBOutlet UILabel *selfUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *selfTimestampLabel;

@property (weak, nonatomic) IBOutlet UILabel *containerUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *containerTimestampLabel;

@property (nonatomic, weak) id<UsernameTimestampCellDelegate> delegate;
@property (nonatomic, strong) Post *post;

@end


@protocol UsernameTimestampCellDelegate

-(void)usernameTimestampCell:(UsernameTimestampCell *) usernameTimestampCell didTap: (PFUser *)user;

@end

NS_ASSUME_NONNULL_END
