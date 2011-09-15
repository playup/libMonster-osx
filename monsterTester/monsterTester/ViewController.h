//
//  ViewController.h
//  monsterTester
//
//  Created by Sugendran Ganess on 30/08/11.
//  Copyright (c) 2011 Digital Five. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, assign) BOOL iPad;
@property (nonatomic, assign) IBOutlet UILabel *debugLabel;
@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;

-(IBAction) sceneChanged:(id)sender;
-(IBAction) inAppPurchase:(id)sender;

@end
