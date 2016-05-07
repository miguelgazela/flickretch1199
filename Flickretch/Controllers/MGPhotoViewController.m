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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.photo) {
        [self updateView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)swipeRight:(id)sender {
    
    MGFlickrPhoto *previousPhoto = (MGFlickrPhoto *)[self.delegate itemBefore:self.photo];
    
    if (previousPhoto) {
        self.photo = previousPhoto;
        [self updateView];
    }
}

- (IBAction)swipeLeft:(id)sender {

    MGFlickrPhoto *nextPhoto = (MGFlickrPhoto *)[self.delegate itemNextTo:self.photo];
    
    if (nextPhoto) {
        self.photo = nextPhoto;
        [self updateView];
    }
}

- (void)updateView {
    
    self.navigationItem.title =self.photo.title;
    [self.photoImageView setImageWithURL:self.photo.thumbnailURL];
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
