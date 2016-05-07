//
//  MGPhotoCollectionViewCell.m
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "MGConstants.h"

#import "MGPhotoCollectionViewCell.h"

@implementation MGPhotoCollectionViewCell

- (void)awakeFromNib {
    [self setImageWithURL:nil];
}

- (void)prepareForReuse {
    [self setImageWithURL:nil];
}

- (void)setImageWithURL:(NSURL *)url {
    
    if (url) {
        [self.loadingSpinner stopAnimating];
        [self.imageView setImageWithURL:url];
    } else {
        [self.loadingSpinner startAnimating];
        [self.imageView setImage:nil];
    }
    
    [self updateFooter];
}

- (void)updateFooter {
    
    NSNumber *showPhotoTitlePreference = [[NSUserDefaults standardUserDefaults] objectForKey:kMGSettingsPreferenceShowPhotoTitleInGrid];
    
    if (showPhotoTitlePreference && !showPhotoTitlePreference.boolValue) {
        
        self.footerBgView.hidden = YES;
        self.titleLabel.hidden = YES;
        
    } else {
        
        // default case, show title
        
        self.footerBgView.hidden = NO;
        self.titleLabel.hidden = NO;
    }
}

@end
