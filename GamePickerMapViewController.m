//
//  GamePickerMapViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "GamePickerMapViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "ARISAppDelegate.h"
#import <UIKit/UIActionSheet.h>
#import "GamesMapAnnotation.h"
#import <MapKit/MapKit.h>


static float INITIAL_SPAN = 100;

@implementation GamePickerMapViewController

@synthesize locations;
@synthesize mapView;
@synthesize tracking;
@synthesize mapTypeButton;
@synthesize playerTrackingButton;
@synthesize toolBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Map View";
        self.tabBarItem.image = [UIImage imageNamed:@"gps.png"];
        tracking = NO;
		playerTrackingButton.style = UIBarButtonItemStyleDone;
        
    }
    return self;
}

- (void)dealloc
{
    [mapView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
	NSLog(@"Begin Loading GPS View");
	mapView.showsUserLocation = NO;
	[mapView setDelegate:self];
	[self.view addSubview:mapView];
	NSLog(@"GPSViewController: Mapview inited and added to view");
	//Setup the buttons
	mapTypeButton.target = self; 
	mapTypeButton.action = @selector(changeMapType:);
	mapTypeButton.title = NSLocalizedString(@"MapTypeKey",@"");
	
	playerTrackingButton.target = self; 
	playerTrackingButton.action = @selector(refreshButtonAction:);
	playerTrackingButton.style = UIBarButtonItemStyleDone;
    
	
    //register for notifications
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedGameList" object:nil];
    [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewGameListReady" object:nil];
    [dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
    
    
    
	//Force an update of the locations
	[[AppServices sharedAppServices] fetchMiniGamesListLocations];
	
	[self refresh];	
	
	
    
	NSLog(@"GPSViewController: View Loaded");
}
- (void) refresh {
	if (mapView) {
        //Zoom and Center
		if (tracking) [self zoomAndCenterMap];
        
	} else {
		NSLog(@"GPSViewController: refresh requested but ignored, as mapview is nil");	
		
	}
}
- (void)refreshViewFromModel {
	NSLog(@"GPSViewController: Refreshing view from model");
	
	NSLog(@"GPSViewController: refreshViewFromModel: silenceNextServerUpdateCount = %d", silenceNextServerUpdateCount);
    
	
	self.locations = [AppModel sharedAppModel].gameList;
	
	if (mapView) {
		//Blow away the old markers except for the player marker
		NSEnumerator *existingAnnotationsEnumerator = [[[mapView annotations] copy] objectEnumerator];
		NSObject <MKAnnotation> *annotation;
		while ((annotation = [existingAnnotationsEnumerator nextObject])) {
			//if (annotation != mapView.userLocation)
            [mapView removeAnnotation:annotation];
		}
        
		//Add the freshly loaded locations from the notification
		for (Game* game in locations ) {
            GamesMapAnnotation *annotation = [[Annotation alloc]initWithCoordinate:game.location.coordinate];
            [mapView addAnnotation:annotation];
            /*
			NSLog(@"GPSViewController: Adding location annotation for:%@ id:%d", location.name, location.locationId);

			CLLocationCoordinate2D locationLatLong = location.location.coordinate;
			
			Annotation *annotation = [[Annotation alloc]initWithCoordinate:locationLatLong];
			annotation.location = location;
			
			
			annotation.title = location.name;
			            
			[mapView addAnnotation:annotation];
			if (!mapView) {
				NSLog(@"GPSViewController: Just added an annotation to a null mapview!");
			}
			
			[annotation release];
             */
		}
		
	}
	
	if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
    
}

-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator = 
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[barButton release];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator{
	[[self navigationItem] setRightBarButtonItem:nil];
	NSLog(@"GPSViewController: removeLoadingIndicator: silenceNextServerUpdateCount = %d", silenceNextServerUpdateCount);
}


- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"GPSViewController: Stopping Refresh Timer");
	if (refreshTimer) {
		[refreshTimer invalidate];
		refreshTimer = nil;
	}
}

-(void) zoomAndCenterMap {
	appSetNextRegionChange = YES;
	
	//Center the map on the player
	MKCoordinateRegion region = mapView.region;
	region.center = [AppModel sharedAppModel].playerLocation.coordinate;
	region.span = MKCoordinateSpanMake(INITIAL_SPAN, INITIAL_SPAN);
	[mapView setRegion:region animated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)changeMapType: (id) sender {
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];
	
	switch (mapView.mapType) {
		case MKMapTypeStandard:
			mapView.mapType=MKMapTypeSatellite;
			break;
		case MKMapTypeSatellite:
			mapView.mapType=MKMapTypeHybrid;
			break;
		case MKMapTypeHybrid:
			mapView.mapType=MKMapTypeStandard;
			break;
	}
}


#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	//User must have moved the map. Turn off Tracking
	NSLog(@"GPSVC: regionDidChange delegate metohd fired");
    
	if (!appSetNextRegionChange) {
		NSLog(@"GPSVC: regionDidChange without appSetNextRegionChange, it must have been the user");
		tracking = NO;
		playerTrackingButton.style = UIBarButtonItemStyleBordered;
	}
	
	appSetNextRegionChange = NO;
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)myMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	NSLog(@"GPSViewController: In viewForAnnotation");
    
    return nil;
}


- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view {
	Location *location = ((Annotation*)view.annotation).location;
	NSLog(@"GPSViewController: didSelectAnnotationView for location: %@",location.name);
	
}


#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSLog(@"GPSViewController: action sheet button %d was clicked",buttonIndex);
	
	Annotation *currentAnnotation = [mapView.selectedAnnotations lastObject];
	
	if (buttonIndex == actionSheet.cancelButtonIndex) [mapView deselectAnnotation:currentAnnotation animated:YES]; 
	else {
        [currentAnnotation.location display];
        [mapView deselectAnnotation:currentAnnotation animated:YES];
    }
}

@end
