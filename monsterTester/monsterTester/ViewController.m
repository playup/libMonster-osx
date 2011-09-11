//
//  ViewController.m
//  monsterTester
//
//  Created by Sugendran Ganess on 30/08/11.
//  Copyright (c) 2011 Digital Five. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize buttonItems;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) buttonPressed:(id)sender
{
    NSString *scene = [self.buttonItems objectAtIndex:[sender tag]];
    [MetricMonster addHeartBeatValue:scene forKey:kMetricMonsterMessageKeyCurrentScene];
}

- (void)loadView
{
    [super loadView];

    self.buttonItems = [NSArray arrayWithObjects:@"Home Menu", @"Level Select", @"Level 2", @"Level 10", @"Highscores", nil];
    
    int buttonHeight = 30;
    int buttonWidth = 150;
    int x = 5;
    int y = 5;
    
    for (int i=0; i < [self.buttonItems count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTag:i];
        [button setFrame:CGRectMake(x, y, buttonWidth, buttonHeight)];
        [button setTitle:[self.buttonItems objectAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        y += (buttonHeight + 5);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
