//
//  PageViewController.m
//  My Blog Posts
//
//  Created by Viktor Gordienko on 7/6/20.
//  Copyright © 2020 Viktor Gordienko. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()

@property (weak, nonatomic) IBOutlet UITextView *pageContentsTextView;

@end

@implementation PageViewController
@synthesize pageTitle;
@synthesize pageContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigation];
    [self setupContentView];
}

- (void)setupNavigation {
    if (!self.pageTitle)
        self.title = @"Page contents";
    else
        self.title = self.pageTitle;
}

- (void)setupContentView {
    if (!self.pageContent)
        self.pageContentsTextView.text = @"Page contents";
    else
        self.pageContentsTextView.text = self.pageContent;
    self.pageContentsTextView.contentInset = UIEdgeInsetsMake(20, 10, 20, 10);
}

@end
