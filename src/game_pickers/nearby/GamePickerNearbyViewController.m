//
//  GamePickerNearbyViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "GamePickerNearbyViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Game.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"

@implementation GamePickerNearbyViewController

@synthesize distanceControl;
@synthesize locationalControl;

- (id)initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"GamePickerNearbyViewController" bundle:nil delegate:d])
    {
        locational = YES;
        distanceFilter = 1000;
        
        self.title = NSLocalizedString(@"NearbyObjectsTabKey", @"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"locationArrowTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"locationArrowTabBarSelected"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewNearbyGameListReady" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat: @"%@", NSLocalizedString(@"GamePickerNearbyGamesKey", @"")];
    
    self.distanceControl.enabled = YES;
    self.distanceControl.alpha   = 1;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
    } else {
        // Load resources for iOS 7 or later
        //self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars = NO;
    }
    
}

- (void)requestNewGameList
{
    [super requestNewGameList];
    
    if([AppModel sharedAppModel].player.location && [[AppModel sharedAppModel] player])
    {
        [[AppServices sharedAppServices] fetchGameListWithDistanceFilter:distanceFilter locational:locational];
        [self showLoadingIndicator];
    }
}

- (void)refreshViewFromModel
{
	self.gameList = [[AppModel sharedAppModel].nearbyGameList sortedArrayUsingSelector:@selector(compareCalculatedScore:)];
    [self.gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (IBAction)controlChanged:(id)sender
{    
    if (self.locationalControl.selectedSegmentIndex == 0)
    {
        locational = YES;
        self.distanceControl.enabled = YES;
        self.distanceControl.alpha = 1;
    }
    else
    {
        locational = NO;
        self.distanceControl.alpha = .2;
        self.distanceControl.enabled = NO;
    }
	
    switch (self.distanceControl.selectedSegmentIndex)
    {
        case 0: distanceFilter = 100;   break;
        case 1: distanceFilter = 1000;  break;
        case 2: distanceFilter = 50000; break;
    }
    
    [self requestNewGameList];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
