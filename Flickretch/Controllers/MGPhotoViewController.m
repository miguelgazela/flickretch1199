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
        
        self.navigationItem.title =self.photo.title;
        [self.photoImageView setImageWithURL:self.photo.thumbnailURL];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
