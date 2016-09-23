//
//  ShowWebVC.m
//  youSay
//
//  Created by Baban on 18/01/2016.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import "ShowWebVC.h"

@interface ShowWebVC ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ShowWebVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *showThisURL = [NSURL URLWithString:_url];
   [_webView loadRequest:[NSURLRequest requestWithURL:showThisURL]];
}

- (IBAction)btnDoneClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
