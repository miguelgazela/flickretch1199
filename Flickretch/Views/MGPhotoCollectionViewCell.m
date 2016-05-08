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

- (void)dealloc {
    [self.imageView removeObserver:self forKeyPath:@"image"];
}

- (void)awakeFromNib {
    
    [self.imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    
    [self setImageWithURL:nil];
}

- (void)prepareForReuse {
    [self setImageWithURL:nil];
}

- (void)setImageWithURL:(NSURL *)url {
    
    if (url) {
        [self.imageView setImageWithURL:url];
    } else {
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


#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([object isEqual:self.imageView]) {
        
        id currentImage = [change objectForKey:NSKeyValueChangeNewKey];
        
        if ([currentImage isEqual:[NSNull null]]) {
            [self.loadingSpinner startAnimating];
        } else {
            [self.loadingSpinner stopAnimating];
        }
    }
}

@end
