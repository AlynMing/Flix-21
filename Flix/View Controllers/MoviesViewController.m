//
//  MoviesViewController.m
//  Flix
//
//  Created by Sergio Santoyo on 6/24/20.
//  Copyright © 2020 ssantoyo. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
//In the () it is used to specific how the getter and setter methods should be layed out

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchMovies];//right when the view loads it fetchs the movies
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}


-(void)fetchMovies {
    
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               
               //Alert Notification - Starts
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                      message:@"Internet connection appears to be offline."
               preferredStyle:(UIAlertControllerStyleAlert)];
               
               // create a cancel action
               UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                 // handle cancel response here. Doing nothing will dismiss the view.
                                                                 }];
               // add the cancel action to the alertController
               [alert addAction:cancelAction];

               // create an OK action
               UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // handle response here.
                   
               }];
               // add the OK action to the alert controller
               [alert addAction:okAction];
               
               [self presentViewController:alert animated:YES completion:^{
                   // optional code for what happens after the alert controller has finished presenting
               }];
               
               [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                 animated:YES
completion:^{
                       // optional code for what happens after the alert controller has finished presenting
               }];
           }
        //Alert Notification - Finish
        
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

               NSLog(@"%@", dataDictionary);
               
               // TODO: Get the array of movies
               self.movies = dataDictionary[@"results"];
               for (NSDictionary *movie in self.movies){
                   NSLog(@"%@",movie[@"title"]);
                   
                   
               }
               // TODO: Reload your table view data
               [self.tableView reloadData];//call the underlinded data again just in case self.movies has changed
               

           }
        [self.refreshControl endRefreshing];
        
       }];
    [task resume];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];

    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString: fullPosterURLString];
    cell.posterView.image = nil;
   [cell.posterView setImageWithURL: posterURL];
   

    //NSLog(@"%@", [NSString stringWithFormat: @"row: %d, section %d", indexPath.row,indexPath.section]);
    //cell.textLabel.text = movie[@"title"];
    //cell.textLabel.text = [NSString stringWithFormat: @"row: %d, section %d", indexPath.row,indexPath.section];
    
    return cell;
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailsViewController *detailsViewsController = [segue destinationViewController];
    detailsViewsController.movie = movie;
    
    //NSLog (@"Tapping on a movie!");
}


@end
