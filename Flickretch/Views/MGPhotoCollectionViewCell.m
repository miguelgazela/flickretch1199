//
//  MGPhotoCollectionViewCell.m
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGPhotoCollectionViewCell.h"

@implementation MGPhotoCollectionViewCell

- (void)awakeFromNib {
    [self setImage:nil];
}

- (void)prepareForReuse {
    [self setImage:nil];
}

- (void)setImage:(UIImage *)image {
    
    if (image) {
        [self.loadingSpinner stopAnimating];
        [self.imageView setImage:image];
    } else {
        [self.loadingSpinner startAnimating];
        [self.imageView setImage:nil];
    }
}

@end
