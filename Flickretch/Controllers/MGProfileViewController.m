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

#import "MGFlickrService.h"
#import "MGFlickrUser.h"
#import "MGPhotoStore.h"

#import "MGConstants.h"

#import "FlickrPhoto+CoreDataProperties.h"

#import "MBProgressHUD.h"

@interface MGProfileViewController ()

@property (nonatomic) NSMutableArray *userFlickrPhotos;

@property (nonatomic) BOOL viewingDefaultAccount;

@property (nonatomic, copy) NSDictionary *sizeMapping;

@property (nonatomic) CGSize collectionViewItemSize;

@end

@implementation MGProfileViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _sizeMapping = @{
                         @320: @3,
                         @375: @4,
                         @414: @4,
                         @480: @5,
                         @568: @5,
                         @667: @6,
                         @736: @7,
                         @768: @6,
                         @1024: @8,
                         @1366: @10};
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.viewingDefaultAccount = NO;
    [self setUserFlickrPhotos:[NSMutableArray array]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews:) name:kMGToggledShowPhotoTitleNotification object:nil];
        
    if (self.user) {
        self.navigationItem.title = [NSString stringWithFormat:@"@%@", self.user.username];
        [self fetchUserPhotos];
    } else {
        self.viewingDefaultAccount = YES;
        [self fetchDefaultAccount];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [self calculateItemSize];
    
    if (self.viewingDefaultAccount) {
        
        NSString *defaultAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultAccount"];
        
        if (self.user && ![defaultAccount isEqualToString:self.user.username]) {
            
            [[self userFlickrPhotos] removeAllObjects];
            [self.photosCollectionView reloadData];
            
            [self fetchDefaultAccount];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self calculateItemSize];
    [self.photosCollectionView performBatchUpdates:nil completion:nil]; // same effect as reloadData, but animated
}

- (void)calculateItemSize {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
        
    NSNumber *mappedNumItems = [self.sizeMapping objectForKey:[NSNumber numberWithFloat:screenWidth]];
    CGFloat itemSide = (screenWidth - (mappedNumItems.integerValue - 1)) / mappedNumItems.floatValue;
        
    self.collectionViewItemSize = CGSizeMake(itemSide, itemSide);
}

- (void)fetchDefaultAccount {
    
    NSString *defaultAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultAccount"];
    
    [[MGFlickrService sharedService] fetchUserWithUsername:defaultAccount completionHandler:^(MGFlickrUser *user, NSError *error) {
        
        if (!error && user) {
            
            self.user = user;
            self.navigationItem.title = [NSString stringWithFormat:@"@%@", user.username];
            
            [self fetchUserPhotos];
            return;
        }
        
        [self showWarning:@"Error getting default user"];
    }];
}

- (void)fetchUserPhotos {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor lightGrayColor];
    
    [[MGPhotoStore sharedStore] getPhotoListForUserId:self.user.identifier completionHandler:^(NSArray *objects, NSError *error) {
        if (error) {
            [self showWarning:@"Error getting public photos list for user"];
        } else {
            
            [self.userFlickrPhotos addObjectsFromArray:objects];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.photosCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            });
        }
    }];
}

- (void)showWarning:(NSString *)warning {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ups..." message:warning preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)refreshViews:(NSNotification *)notification {
    [self.photosCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.userFlickrPhotos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MGPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    FlickrPhoto *photo = [self.userFlickrPhotos objectAtIndex:indexPath.row];
    cell.titleLabel.text = photo.title;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FlickrPhoto *cellPhoto = [self.userFlickrPhotos objectAtIndex:indexPath.row];
    
    [[MGPhotoStore sharedStore] getImageForPhoto:cellPhoto forThumbnail:YES completionHandler:^(id object, NSError *error) {
        
        if (error) {
            NSLog(@"[collectionView:willDisplayCell:forItemAtIndexPath:] - error fetching photo: %@", error);
        } else {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                // index of the photo might have changed while the ASYNC request was completed
                
                NSInteger photoIndex = [self.userFlickrPhotos indexOfObject:cellPhoto];
                NSIndexPath *photoIndexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
                
                MGPhotoCollectionViewCell *updatedPhotoViewCell = (MGPhotoCollectionViewCell *)[self.photosCollectionView cellForItemAtIndexPath:photoIndexPath];
                
                if ([object isKindOfClass:[UIImage class]]) {
                    [updatedPhotoViewCell.imageView setImage:object];
                } else {
                    [updatedPhotoViewCell setImageWithURL:cellPhoto.smallestSizeURL];
                }
            }];
        }
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionViewItemSize;
}


#pragma mark - Carrousel Protocol

- (FlickrPhoto *)itemNextTo:(FlickrPhoto *)photo {
    
    NSInteger photoIndex = [self.userFlickrPhotos indexOfObject:photo];
    
    if (photoIndex < ([self.userFlickrPhotos count] - 1)) {
        return [self.userFlickrPhotos objectAtIndex:photoIndex + 1];
    }
    
    return [self.userFlickrPhotos objectAtIndex:[self.userFlickrPhotos count] - 1];
}

- (FlickrPhoto *)itemBefore:(FlickrPhoto *)photo {
    
    NSInteger photoIndex = [self.userFlickrPhotos indexOfObject:photo];
    
    if (photoIndex > 0) {        
        return [self.userFlickrPhotos objectAtIndex:photoIndex - 1];
    }
    
    return [self.userFlickrPhotos objectAtIndex:0];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *selectedIndexPath = [[self.photosCollectionView indexPathsForSelectedItems] firstObject];
    FlickrPhoto *selectedPhoto = [self.userFlickrPhotos objectAtIndex:[selectedIndexPath indexAtPosition:1]];
    
    MGPhotoViewController *photoViewController = (MGPhotoViewController *)segue.destinationViewController;
    photoViewController.photo = selectedPhoto;
    
    photoViewController.delegate = self;
}

@end
