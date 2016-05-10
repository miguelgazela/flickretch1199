//
//  MGContactTableViewCell.h
//  Flickretch
//
//  Created by Miguel Oliveira on 10/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGContactTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end
