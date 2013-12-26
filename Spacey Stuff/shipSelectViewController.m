//
//  shipSelectViewController.m
//  Spacey Stuff
//
//  Created by Ryan Batchelder on 12/26/13.
//  Copyright (c) 2013 Ryan Batchelder. All rights reserved.
//

#import "shipSelectViewController.h"

@interface shipSelectViewController ()
@end

@implementation shipSelectViewController


int shipValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(IBAction)ship1 {
    shipValue = 1;
}

-(IBAction)ship2 {
    shipValue = 2;
}

-(int)getShipValue {
    return shipValue;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
