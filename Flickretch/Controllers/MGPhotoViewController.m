//
//  MGPhotoViewController.m
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGPhotoViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "MGFlickrPhoto.h"

@interface MGPhotoViewController ()

@end

@implementation MGPhotoViewController

- (void)dealloc {
    [self.photoImageView removeObserver:self forKeyPath:@"image"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.photoImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    
    [self configureViewForPhoto:self.photo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureViewForPhoto:(MGFlickrPhoto *)photo {
    
    if (photo == nil) {
        
        self.navigationItem.title = @"";
        [self.photoLoadingIndicatorView startAnimating];
        [self.photoImageView setImage:nil];
        
    } else {
        
        self.navigationItem.title =self.photo.title;
        
        if (self.photo.largeRemoteURL) {
            [self.photoImageView setImageWithURL:self.photo.largeRemoteURL];
        } else if (self.photo.mediumRemoteURL) {
            [self.photoImageView setImageWithURL:self.photo.mediumRemoteURL];
        } else {
            [self.photoImageView setImageWithURL:self.photo.thumbnailRemoteURL];
        }
    }
}


#pragma mark - UI Actions

- (IBAction)swipeRight:(id)sender {
    
    [self configureViewForPhoto:nil];
    
    MGFlickrPhoto *previousPhoto = (MGFlickrPhoto *)[self.delegate itemBefore:self.photo];
    
    if (previousPhoto) {
        [self configureViewForPhoto:previousPhoto];
        self.photo = previousPhoto;
    }
}

- (IBAction)swipeLeft:(id)sender {

    [self configureViewForPhoto:nil];
    
    MGFlickrPhoto *nextPhoto = (MGFlickrPhoto *)[self.delegate itemNextTo:self.photo];
    
    if (nextPhoto) {
        [self configureViewForPhoto:nextPhoto];
        self.photo = nextPhoto;
    }
}


#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([object isEqual:self.photoImageView]) {
        
        id newImage = [change objectForKey:NSKeyValueChangeNewKey];
        
        if ([newImage isEqual:[NSNull null]]) {
            [self.photoLoadingIndicatorView startAnimating];
        } else {
            [self.photoLoadingIndicatorView stopAnimating];
        }
    }
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
