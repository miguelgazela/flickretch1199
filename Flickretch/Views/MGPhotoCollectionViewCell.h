//
//  MGPhotoCollectionViewCell.h
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGPhotoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (weak, nonatomic) IBOutlet UIView *footerBgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setImageWithURL:(NSURL *)url;

- (void)updateFooter;

@end
