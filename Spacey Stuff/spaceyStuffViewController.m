//
//  spaceyStuffViewController.m
//  Spacey Stuff
//
//  Created by Ryan Batchelder on 10/31/13.
//  Copyright (c) 2013 Ryan Batchelder. All rights reserved.
//

#import "spaceyStuffViewController.h"
#import "spaceyStuffMyScene.h"

@implementation spaceyStuffViewController
SKView *skView;

- (void)viewWillLayoutSubviews
{
    [super viewDidLayoutSubviews];
    skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        
        SKScene * scene = [spaceyStuffMyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        
        [skView presentScene:scene];
    }
//    [super viewDidLoad];
//
//    // Configure the view.
//    SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
//    
//    // Create and configure the scene.
//    SKScene * scene = [spaceyStuffMyScene sceneWithSize:skView.bounds.size];
//    scene.scaleMode = SKSceneScaleModeAspectFill;
//    
//    // Present the scene.
//    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(IBAction)pauseButton {
    if (!skView.paused) {
        skView.paused = YES;
    }
    else {
        skView.paused = NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
