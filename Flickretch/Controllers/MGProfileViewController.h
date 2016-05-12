//
//  MyProfileViewController.h
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MGCarrouselProtocol.h"

@class MGFlickrUser;

@interface MGProfileViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, MGCarrousel, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;

@property (nonatomic, strong) MGFlickrUser *user;

@end
