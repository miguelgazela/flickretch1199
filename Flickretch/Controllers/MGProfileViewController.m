//
//  MyProfileViewController.m
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGProfileViewController.h"

#import "MGPhotoCollectionViewCell.h"

#import "MGFlickrService.h"
#import "MGFlickrUser.h"
#import "MGFlickrPhoto.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MGProfileViewController ()

@property (nonatomic) NSMutableArray *userPhotos;

@end

@implementation MGProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUserPhotos:[NSMutableArray array]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.user) {
                
        [[MGFlickrService sharedService] fetchInfoForUserId:self.user.identifier];
        [[MGFlickrService sharedService] fetchPublicPhotosForUserId:self.user.identifier completionHandler:^(NSArray *photos, NSError *error) {
            
            if (error) {
                
                NSLog(@"Error fetching photos");
                
            } else {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [[self userPhotos] addObjectsFromArray:photos];
                    [self.photosCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                }];
            }
        }];
    }    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.userPhotos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MGPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    MGFlickrPhoto *photo = [self.userPhotos objectAtIndex:indexPath.row];
    cell.titleLabel.text = photo.title;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MGFlickrPhoto *photo = [self.userPhotos objectAtIndex:indexPath.row];
    
    [[MGFlickrService sharedService] fetchPhotoThumbnailURLForPhotoId:photo.identifier completionHandler:^(NSURL *imageURL, NSError *error) {
        
        if (error) {
            NSLog(@"Error fetching thumbnail image");
        } else {
            MGPhotoCollectionViewCell *photoViewCell = (MGPhotoCollectionViewCell *)cell;
            
            NSLog(@"Photo URL: %@", imageURL);
            
            [[photoViewCell imageView] setImageWithURL:imageURL];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
