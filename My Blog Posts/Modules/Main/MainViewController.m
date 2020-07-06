//
//  MainViewController.m
//  My Blog Posts
//
//  Created by Viktor Gordienko on 7/3/20.
//  Copyright © 2020 Viktor Gordienko. All rights reserved.
//

#import "MainViewController.h"
#import "PageViewController.h"

@interface MainViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *array;

@property NSString *plainTextStringFromApiRequest;
@property NSUInteger numberOfTableViewRows;
@property NSData *jsonFromApiRequest;
@property NSArray *blogPostsInJson;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigation];
    [self setupTableView];
    
    [self getPagesFrom:@"https://viktorgordienko.com/api/pages"
             withToken:@"b0b4dad6c7ef0e6170c2d1a873a37f4f"
         numberOfPages:@"30"];
    
    self.numberOfTableViewRows = 0;
}

- (void)setupNavigation {
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"My blog posts";
}

// MARK: - URL Request & List logic

/// API request to get blog posts
/// @param website Website address (with the endpoint)
/// @param token Public API token
/// @param number Number of pages to get
- (void) getPagesFrom:(NSString *)website
            withToken:(NSString *)token
        numberOfPages:(NSString *)number {
    
    NSURLComponents *components = [NSURLComponents componentsWithString:website];
    NSURLQueryItem *apiToken = [NSURLQueryItem queryItemWithName:@"token" value:token];
    NSURLQueryItem *numberOfItems = [NSURLQueryItem queryItemWithName:@"numberOfItems" value:number];
    components.queryItems = @[apiToken, numberOfItems];
    NSURL *url = components.URL;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
        NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        self.plainTextStringFromApiRequest = myString;
        [self convertData];
    }] resume];
}

/// Convert string to JSON data & reload the tableView
- (void)convertData {
    self.jsonFromApiRequest = [self.plainTextStringFromApiRequest dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.jsonFromApiRequest
                                                         options:kNilOptions
                                                           error:&error];
    self.blogPostsInJson = [json objectForKey:@"data"];
    [self reloadData];
}

/// Reload data & tableView
- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.numberOfTableViewRows = self.blogPostsInJson.count;
        [self.tableView reloadData];
    });
}

/// Convert raw HTML text to plain text
/// @param html original string
-(NSString *)convertHTML:(NSString *)html {
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    while ([myScanner isAtEnd] == NO) {
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        [myScanner scanUpToString:@">" intoString:&text] ;
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return html;
}

// MARK: - UITableView logic

- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [[self.blogPostsInJson objectAtIndex:indexPath.row]valueForKey:@"title"];
    NSString *contents = [[self.blogPostsInJson objectAtIndex:indexPath.row]valueForKey:@"content"];
    contents = [self convertHTML:contents];
    cell.detailTextLabel.text = contents;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfTableViewRows;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Page" bundle:nil];
    PageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Page"];
    
    vc.pageTitle = [[self.blogPostsInJson objectAtIndex:indexPath.row]valueForKey:@"title"];
    NSString *contents = [[self.blogPostsInJson objectAtIndex:indexPath.row]valueForKey:@"content"];
    contents = [self convertHTML:contents];
    vc.pageContent = contents;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
