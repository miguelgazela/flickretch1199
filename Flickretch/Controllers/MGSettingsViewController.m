//
//  MGSettingsViewController.m
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGConstants.h"

#import "MGSettingsViewController.h"

@interface MGSettingsViewController ()

@end

@implementation MGSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setting up correct insets for the table view
    
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    UIEdgeInsets insets = UIEdgeInsetsMake(statusBarHeight, 0, 0, 0);
    
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    // load user preferences
    
    NSDictionary *preferences = @{
                                  kMGSettingsPreferenceShowPhotoTitleInGrid: @"showPhotoTitleSwitchButton",
                                  kMGSettingsPreferenceLocalPhotosCache: @"useLocalPhotoCacheSwitchButton"
                                  };
    
    for (NSString *preferenceKey in preferences.allKeys) {
        
        NSNumber *currentPreference = [[NSUserDefaults standardUserDefaults] objectForKey:preferenceKey];
        
        if (currentPreference) {
            
            UISwitch *switchButton = [self valueForKey:[preferences objectForKey:preferenceKey]];
            [switchButton setOn:currentPreference.boolValue];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath indexAtPosition:1] == 0) {
        return YES;
    }
    
    return NO;
}


#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


#pragma mark - UI Actions

- (IBAction)deleteLocalData:(id)sender {
    
    NSArray *directories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories firstObject];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directory includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
    
    for (NSURL *fileURL in files) {
        
        if ([fileURL.path hasSuffix:@"-small"] || [fileURL.path hasSuffix:@"-big"]) {
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        }
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Files successfully deleted" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)toggleShowPhotoTitleInGrid:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.showPhotoTitleSwitchButton.isOn]
                                              forKey:kMGSettingsPreferenceShowPhotoTitleInGrid];
}

- (IBAction)toggleLocalPhotosCache:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.useLocalPhotoCacheSwitchButton.isOn]
                                              forKey:kMGSettingsPreferenceLocalPhotosCache];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
