//
//  MyProfileViewController.m
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Accounts/Accounts.h>

#import "MGProfileViewController.h"
#import "MGPhotoViewController.h"

#import "MGPhotoCollectionViewCell.h"

#import "MGConstants.h"

#import "MGFlickrService.h"
#import "MGFlickrUser.h"
#import "MGFlickrPhoto.h"

#import "MGPhotoCache.h"

@interface MGProfileViewController ()

@property (nonatomic) NSMutableArray *userFlickrPhotos;

@end

@implementation MGProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUserFlickrPhotos:[NSMutableArray array]];
    
    if (self.user) {
        
        self.navigationItem.title = [NSString stringWithFormat:@"@%@", self.user.username];
        [self fetchUserPhotos];
        
    } else {
        
        [[MGFlickrService sharedService] fetchUserWithEmail:@"miguel.gazela@gmail.com" completionHandler:^(MGFlickrUser *user, NSError *error) {
            
            if (error) {
                NSLog(@"Error fetching user %@", error);
            } else {
                
                if (user) {
                    
                    self.user = user;
                    self.navigationItem.title = [NSString stringWithFormat:@"@%@", user.username];
                    
                    [self fetchUserPhotos];
                }
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.photosCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchUserPhotos {
    
    [[MGFlickrService sharedService] fetchPublicPhotosForUserId:self.user.identifier completionHandler:^(NSArray *photos, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error fetching photos");
            
        } else {
            
            [self.userFlickrPhotos addObjectsFromArray:photos];
            
            [self.userFlickrPhotos sortUsingComparator:^(id obj1, id obj2) {
                
                NSString *titleA = [obj1 valueForKeyPath:@"title"];
                NSString *titleB = [obj2 valueForKeyPath:@"title"];
                
                return (NSComparisonResult)[titleA compare:titleB];
            }];

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.photosCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            }];
        }
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.userFlickrPhotos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MGPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    MGFlickrPhoto *photo = [self.userFlickrPhotos objectAtIndex:indexPath.row];
    cell.titleLabel.text = photo.title;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MGFlickrPhoto *photo = [self.userFlickrPhotos objectAtIndex:indexPath.row];
    MGPhotoCollectionViewCell *photoViewCell = (MGPhotoCollectionViewCell *)cell;
    
    NSURL *url;
    NSNumber *localPhotosCachePreference = [[NSUserDefaults standardUserDefaults] objectForKey:kMGSettingsPreferenceLocalPhotosCache];
    
    // check if photo url was already cached
    
    if (localPhotosCachePreference && localPhotosCachePreference.boolValue && (url = [[MGPhotoCache sharedCache] cachedURLForPhotoId:photo.identifier])) {
        
        [photoViewCell setImageWithURL:url];
        
    } else {
        
        [[MGFlickrService sharedService] fetchPhotoWithPhotoId:photo.identifier completionHandler:^(MGFlickrPhoto *fetchedPhoto, NSError *error) {
            
            if (error) {
                NSLog(@"Error fetching thumbnail image");
            } else {
                
                [photo setThumbnailRemoteURL:fetchedPhoto.thumbnailRemoteURL];
                [photo setMediumRemoteURL:fetchedPhoto.mediumRemoteURL];
                [photo setLargeRemoteURL:fetchedPhoto.largeRemoteURL];
                [photo setOriginalRemoteURL:fetchedPhoto.originalRemoteURL];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    // index of the photo might have changed while the ASYNC request was completed
                    
                    NSInteger photoIndex = [self.userFlickrPhotos indexOfObject:photo];
                    NSIndexPath *photoIndexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
                    
                    MGPhotoCollectionViewCell *photoViewCell = (MGPhotoCollectionViewCell *)[self.photosCollectionView cellForItemAtIndexPath:photoIndexPath];
                    [photoViewCell setImageWithURL:photo.thumbnailRemoteURL];
                }];
                
                [[MGPhotoCache sharedCache] cacheURL:photo.thumbnailRemoteURL forPhotoId:photo.identifier];
            }
        }];
    }
}


#pragma mark - Carrousel Protocol

- (MGFlickrPhoto *)itemNextTo:(MGFlickrPhoto *)photo {
    
    NSInteger photoIndex = [self.userFlickrPhotos indexOfObject:photo];
    
    if (photoIndex < ([self.userFlickrPhotos count] - 1)) {
        return [self.userFlickrPhotos objectAtIndex:photoIndex + 1];
    }
    
    return nil;
}

- (MGFlickrPhoto *)itemBefore:(MGFlickrPhoto *)photo {
    
    NSInteger photoIndex = [self.userFlickrPhotos indexOfObject:photo];
    
    if (photoIndex > 0) {
        return [self.userFlickrPhotos objectAtIndex:photoIndex - 1];
    }
    
    return nil;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *selectedIndexPath = [[self.photosCollectionView indexPathsForSelectedItems] firstObject];
    MGFlickrPhoto *selectedPhoto = [self.userFlickrPhotos objectAtIndex:[selectedIndexPath indexAtPosition:1]];
    
    MGPhotoViewController *photoViewController = (MGPhotoViewController *)segue.destinationViewController;
    photoViewController.photo = selectedPhoto;
    
    photoViewController.delegate = self;
}

@end
