//
//  ViewController.m
//  monsterTester
//
//  Created by Sugendran Ganess on 30/08/11.
//  Copyright (c) 2011 Digital Five. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize iPad, debugLabel, scrollView;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        iPad = NO;
    }
    return self;
}

#pragma mark - View lifecycle

-(void) sceneChanged:(id)sender
{
    NSArray *scenes = [NSArray arrayWithObjects:@"Level One", @"Level Two", @"Level Three", nil];
    NSString *scene = [scenes objectAtIndex:[(UISegmentedControl*)sender selectedSegmentIndex]];
    [MetricMonster addHeartBeatValue:scene forKey:kMetricMonsterMessageKeyCurrentScene];
}

-(IBAction) inAppPurchase:(id)sender
{
    [MetricMonster addEventData:[NSNumber numberWithFloat:0.99] forKey:kMetricMonsterMessageKeyInAppPurchase];
}

- (void) mmRequestDebug:(NSNotification*) notification
{
    NSString *debug = [notification object];

    CGSize debugSize = [debug sizeWithFont:[debugLabel font] constrainedToSize:CGSizeMake(debugLabel.frame.size.width, 99990) lineBreakMode:UILineBreakModeWordWrap];
    debugLabel.frame = CGRectMake(debugLabel.frame.origin.x, debugLabel.frame.origin.y, debugLabel.frame.size.width, debugSize.height);
    if(self.iPad){
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, debugSize.height + 20)];
    }else{
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, debugLabel.frame.origin.y + debugSize.height + 20)];
    }
    [debugLabel setText:debug];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mmRequestDebug:) name:@"MM_REQUEST_DEBUG" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(self.iPad){
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }else{
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
}

@end
