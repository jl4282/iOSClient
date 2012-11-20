//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "QRScannerViewController.h"
#import "Decoder.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "AppServices.h"
#import <QRCodeReader.h>
#import "ZBarReaderViewController.h"
#import "QCARutils.h"
#import "EAGLView.h"


@implementation QRScannerViewController 

@synthesize imageMatchingImagePickerController;
@synthesize qrScanButton,imageScanButton,barcodeButton;
@synthesize manualCode,resultText,cancelButton;
@synthesize arParentViewController;

namespace {
    BOOL firstTime = YES;
    
    NSArray *videoArray;
}

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"QRScannerTitleKey", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"qrscanner.png"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(finishLoadingResult:)
													 name:@"QRCodeObjectReady"
												   object:nil];
    }
    
    
    videoArray = [NSArray arrayWithObjects:@"Plaid-Square video.mp4", @"LongEarrings-Square video.mp4",@"Glasses-Square video.mp4", @"Guilt-Square video.mp4",nil];//,@"Delicious-Square video.mp4",@"Glasses-Square video.mp4",@"Guilt-Square video.mp4",@"LongEarrings-Square video.mp4",@"PayForThat-Square video.mp4",@"Plaid-Square video.mp4",@"PurpleShirt-Square video.mp4",@"TalkingAbout-Square video.mp4",@"Tumeric-Square video.mp4",@"WaterFountain.png-Square video.mp4",@"YouFoundMe-Square video.mp4", nil];

       
    //IMG_0032(2).mp4
    //[self showARCamera];
    return self;
    
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		
	//[self.qrScanButton setTitle:NSLocalizedString(@"ScanUsingCameraKey",@"") forState:UIControlStateNormal];
	manualCode.placeholder = NSLocalizedString(@"EnterCodeKey",@"");
	    
	imageMatchingImagePickerController = [[UIImagePickerController alloc] init];
	self.imageMatchingImagePickerController.delegate = self;
	
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CancelKey",@"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTouch)];      
    //if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
	//	self.qrScanButton.enabled = YES;
	//	self.qrScanButton.alpha = 1.0;
    //    self.imageScanButton.enabled = YES;
	//	self.imageScanButton.alpha = 1.0;
	//}
	//else {
		self.qrScanButton.hidden = YES;
        self.imageScanButton.hidden = YES;
        self.barcodeButton.hidden = YES;
        self.manualCode.hidden = YES;
   //     [self.manualCode becomeFirstResponder];

	//}
	NSLog(@"QRScannerViewController: Loaded");
    
    //[self showARCamera];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
	
    [self showARCamera];
    
}

-(void)cancelButtonTouch{
    [self.manualCode resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;	
}

- (IBAction) scanButtonTapped {
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present the controller
    [self presentViewController:reader animated:YES completion:nil];
}

- (IBAction)qrScanButtonTouchAction: (id) sender{
	NSLog(@"QRScannerViewController: QR Scan Button Pressed");
	
    /*ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
    widController.readers = readers;*/
    /*
    NSBundle *mainBundle = [NSBundle mainBundle];
    widController.soundToPlay =
    [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
     */
    //[self presentViewController:widController animated:YES completion:nil];
    
    //[self showARCamera];
}

- (IBAction)imageScanButtonTouchAction: (id) sender{
    //[self showARCamera];
}


- (void) showARCamera {
    
    NSLog(@"QRScannerViewController: Image Scan Button Pressed");
	
	/*self.imageMatchingImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
     [self presentViewController:self.imageMatchingImagePickerController animated:YES completion:nil];*/
    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    //window = [[UIWindow alloc] initWithFrame: screenBounds];
    
    
    //[QCARutils getInstance].targetType = TYPE_FRAMEMARKERS;
    
    QCARutils *qUtils = [QCARutils getInstance];
    
    // Provide a list of targets we're expecting - the first in the list is the default
    [qUtils addTargetName:@"Stones & Chips" atPath:@"StonesAndChips.xml"];
    [qUtils addTargetName:@"Tarmac" atPath:@"Tarmac.xml"];
    [qUtils addTargetName:@"Test" atPath:@"Test.xml"];
    
    
    // Add the EAGLView and the overlay view to the window
    arParentViewController = [[VPParentViewController alloc] init];
    arParentViewController.arViewRect = screenBounds;
    
    [self presentModalViewController:arParentViewController animated:NO];
    
    // Load the video for use with the EAGLView
    EAGLView* arView = [arParentViewController getARView];
    
#ifdef EXAMPLE_CODE_REMOTE_FILE
    // Load a remote file for playback
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        VideoPlayerHelper* player = [arView getVideoPlayerHelper:i];
        [player load:@"http://<SOME_URL>" playImmediately:NO fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
    }
#else
    // For each video-augmented target
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        // Load a local file for playback and resume playback if video was
        // playing when the app went into the background
        VideoPlayerHelper* player = [arView getVideoPlayerHelper:i];
        NSString* filename;
        
        filename = videoArray[i];
        if (NO == [player load:filename playImmediately:NO fromPosition:videoPlaybackTime[i]]) {
            NSLog(@"Failed to load media");
        }

    }
#endif
    
    firstTime = NO;
    
}


#pragma mark Delegate for text entry

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
	NSLog(@"QRScannerViewController: Code Entered");
	
	[textField resignFirstResponder]; 
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the keyboard go away before loading the object
	
	[self loadResult:manualCode.text];
    self.navigationItem.rightBarButtonItem = nil;	
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{    
    self.navigationItem.rightBarButtonItem = self.cancelButton;	
    return YES;
}


#pragma mark UIImagePickerControllerDelegate Protocol Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary  *)info{
    [picker dismissViewControllerAnimated:NO completion:nil];
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];                 
    
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    resultText = symbol.data;
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    // [picker dismissModalViewControllerAnimated: YES];
    
    
    if (picker == self.imageMatchingImagePickerController) {
        NSLog(@"QRScannerVC: image matching imagePickerController didFinishPickingImage" );
        
        NSData *imageData = UIImageJPEGRepresentation(image, .4);
        NSString *mediaFilename = @"imageToMatch.jpg";
        NSString *newFilePath =[NSTemporaryDirectory() stringByAppendingString: mediaFilename];
        NSURL *imageURL = [[NSURL alloc] initFileURLWithPath: newFilePath];
        
        NSLog(@"Tempory File will be: %@", newFilePath);
        [imageData writeToURL:imageURL atomically:YES];
        [[AppServices sharedAppServices] uploadImageForMatching:imageURL];
       
    }	
    else{
        NSLog(@"QRSCannerVC: barcode data = %@",resultText);
        [self loadResult:resultText];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark -
#pragma mark ZXingDelegateMethods
- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)resultString {
    [controller dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"QRScannerViewController: Scan result: %@",resultString);
    [self loadResult:resultString];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [controller dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark QRCScan delegate methods
/*
- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)twoDResult {
	//Stop Waiting Indicator
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	[[RootViewController sharedRootViewController] removeNewWaitingIndicator];
	
	//get the result
	NSString *encodedText = twoDResult.text;

	//we are done with the scanner, so release it
	[decoder release];
	NSLog(@"QRScannerViewController: Decode Complete. QR Code ID = %@", encodedText);
	
	[self loadResult:encodedText];
}
 
 - (void)decoder:(Decoder *)decoder decodingImage:(UIImage *)image usingSubset:(UIImage *)subset progress:(NSString *)message {
 NSLog(@"Decoding image");
 }
 
 - (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason {
 NSLog(@"Failed to decode image");
 [decoder release];
 
 //Stop Waiting Indicator
 ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
 [[RootViewController sharedRootViewController] removeNewWaitingIndicator];
 [appDelegate playAudioAlert:@"error" shouldVibrate:YES];
 
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QRScannerDecodingErrorTitleKey", @"")
 message:NSLocalizedString(@"QRScannerDecodingErrorMessageKey", @"")
 delegate:self 
 cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
 otherButtonTitles:nil];
 [alert show];	
 [alert release];
 }
 
 - (void) qrParserDidFinish:(id<QRCodeProtocol>)qrcode {
 NSLog(@"Not implemented.");
 assert(false);
 }
 
 - (void)decoder:(Decoder *)decoder willDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset {
 NSLog(@"QR: Will decode image");
 
 //Start Waiting Indicator
 ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
 [[[RootViewController sharedRootViewController] showNewWaitingIndicator:NSLocalizedString(@"QRScannerDecodingKey",@"") displayProgressBar:NO];
 
 }
 

*/



-(void) loadResult:(NSString *)code {
	//Fetch the coresponding object from the server
	[[RootViewController sharedRootViewController] showNewWaitingIndicator:NSLocalizedString(@"LoadingKey",@"") displayProgressBar:NO];
	[[AppServices sharedAppServices] fetchQRCode:code];
}

-(void) finishLoadingResult:(NSNotification*) notification{
	
	NSObject<QRCodeProtocol> *qrCodeObject = notification.object;
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[RootViewController sharedRootViewController] removeNewWaitingIndicator];
    
	if (qrCodeObject == nil) {
		[appDelegate playAudioAlert:@"error" shouldVibrate:NO];
		
		//Display an alert
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"")
														message:NSLocalizedString(@"QRScannerErrorMessageKey", @"")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
											  otherButtonTitles:nil];
		[alert show];	
		
	}
	else if ([qrCodeObject isKindOfClass:[NSString class]]) {
        [appDelegate playAudioAlert:@"error" shouldVibrate:NO];
        
        //Display an alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"")
                                                        message:(NSString *)qrCodeObject
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
                                              otherButtonTitles:nil];
        [alert show];	
        
    }
    else{
		[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];		
		//Display the content
		[qrCodeObject display];
	}
}


#pragma mark UINavigationControllerDelegate Protocol Methods
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	//nada
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	//nada
}


#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Remove the native movie player view (if it is displayed).  This gives us
    // a clean restart on iOS 4 and 5
    [arParentViewController removeMoviePlayerView];
    
    EAGLView* arView = [arParentViewController getARView];
    
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        VideoPlayerHelper* player = [arView getVideoPlayerHelper:i];
        
        // If the video is playing, pause it and store the index of the player
        // so playback can be resumed
        if (PLAYING == [player getStatus]) {
            [player pause];
        }
        
        // Store the current video playback time for use when resuming (even if
        // the player is currently paused)
        videoPlaybackTime[i] = [player getCurrentPosition];
        
        // Unload the video
        if (NO == [player unload]) {
            NSLog(@"Failed to unload media");
        }
    }
    
    // do the same as when the view has dissappeared
    [arParentViewController viewDidDisappear:NO];
    
}



@end
