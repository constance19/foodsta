//
//  MapLocationCell.h
//  foodsta
//
//  Created by constanceh on 7/24/21.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@protocol MapLocationCellDelegate;

@interface MapLocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *locationView;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, weak) id<MapLocationCellDelegate> delegate;

@end


@protocol MapLocationCellDelegate

-(void)mapLocationCell:(MapLocationCell *) mapLocationCell didTap: (PFUser *)user;

@end

NS_ASSUME_NONNULL_END
