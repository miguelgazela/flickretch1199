//
//  MGSettingsViewController.h
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGSettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *showPhotoTitleSwitchButton;
@property (weak, nonatomic) IBOutlet UISwitch *useLocalPhotoCacheSwitchButton;

@end
