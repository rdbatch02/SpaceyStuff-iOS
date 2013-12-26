//
//  spaceyStuffViewController.h
//  Spacey Stuff
//

//  Copyright (c) 2013 Ryan Batchelder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface spaceyStuffViewController : UIViewController
@property BOOL paused;

-(void)resetGame;
-(IBAction)pauseButton;

@end
