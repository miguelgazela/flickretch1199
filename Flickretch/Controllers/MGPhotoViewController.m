//
//  MGPhotoViewController.m
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGPhotoViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "MGPhotoStore.h"
#import "FlickrPhoto+CoreDataProperties.h"


@interface MGPhotoViewController ()

@end

@implementation MGPhotoViewController

- (void)dealloc {
    [self.photoImageView removeObserver:self forKeyPath:@"image"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.photoImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    [self configureViewForPhoto:self.photo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureViewForPhoto:(FlickrPhoto *)photo {
        
    if (photo == nil) {
        
        self.navigationItem.title = @"";
        [self.photoLoadingIndicatorView startAnimating];
        [self.photoImageView setImage:nil];
        
    } else {
        
        self.navigationItem.title =self.photo.title;
        
        if (photo.bigImage) {
            [self.photoImageView setImage:photo.bigImage];
        } else {
            
            [[MGPhotoStore sharedStore] getPhoto:photo forThumbnail:NO completionHandler:^(FlickrPhoto *fetchedPhoto, NSError *error) {

                if (error) {

                    NSLog(@"Error fetching image!");
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ups..." message:@"Couldn't get the photo" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:okAction];
                    [self presentViewController:alert animated:YES completion:nil];

                } else {
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        if (photo.bigImage) {
                            [self.photoImageView setImage:photo.bigImage];
                        } else {
                            [self.photoImageView setImageWithURL:photo.biggestSizeURL];
                        }
                        
                        [self setPhoto:photo];
                    }];
                }
            }];
        }
    }
}


#pragma mark - UI Actions

- (IBAction)swipeRight:(id)sender {
    
    [self configureViewForPhoto:nil];
    
    FlickrPhoto *previousPhoto = (FlickrPhoto *)[self.delegate itemBefore:self.photo];
    
    if (previousPhoto) {
        [self configureViewForPhoto:previousPhoto];
        self.photo = previousPhoto;
    }
}

- (IBAction)swipeLeft:(id)sender {

    [self configureViewForPhoto:nil];
    
    FlickrPhoto *nextPhoto = (FlickrPhoto *)[self.delegate itemNextTo:self.photo];
    
    if (nextPhoto) {
        [self configureViewForPhoto:nextPhoto];
        self.photo = nextPhoto;
    }
}

- (IBAction)savePhoto:(id)sender {
//    [[MGPhotoStore sharedStore] saveImageForPhotoWithId:self.photo.identifier forUser:self.photo.ownerId completionHandler:^(NSArray *objects, NSError *error) {
//        
//    }];
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
