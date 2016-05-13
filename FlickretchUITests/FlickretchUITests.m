//
//  FlickretchUITests.m
//  FlickretchUITests
//
//  Created by Miguel Oliveira on 05/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface FlickretchUITests : XCTestCase

@end

@implementation FlickretchUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTabBarNavigation {
    
    XCUIElementQuery *tabBarsQuery = [[XCUIApplication alloc] init].tabBars;
    [tabBarsQuery.buttons[@"Users"] tap];
    [tabBarsQuery.buttons[@"Settings"] tap];
    [tabBarsQuery.buttons[@"My Account"] tap];
}

- (void)testSettingsView {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tabBars.buttons[@"Settings"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery.switches[@"Show photo title in grid"] tap];
    [tablesQuery.switches[@"Use local cache for photos"] tap];
    [tablesQuery.buttons[@"Delete"] tap];
    
    XCUIElement *okButton = app.alerts[@"Success"].collectionViews.buttons[@"Ok"];
    [okButton tap];
}

- (void)testPhotoDetailView {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [[[[[app.collectionViews childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:13].otherElements containingType:XCUIElementTypeActivityIndicator identifier:@"Progress halted"] childrenMatchingType:XCUIElementTypeImage].element tap];
    
    XCUIElement *image = [[[[[[[[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeImage].element;
    [image tap];
    [image tap];
    [image tap];
}

- (void)testContactsView {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tabBars.buttons[@"Users"] tap];
    [app.tables.staticTexts[@"memetic"] tap];
}

@end
