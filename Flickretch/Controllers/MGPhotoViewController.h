//
//  MGPhotoViewController.h
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MGCarrouselProtocol.h"

@class MGFlickrPhoto;

@interface MGPhotoViewController : UIViewController

@property (nonatomic, weak) id <MGCarrousel> delegate;

@property (nonatomic, strong) MGFlickrPhoto *photo;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *photoLoadingIndicatorView;

@end
