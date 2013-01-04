//
//  RootViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#define SCREEN_HEIGHT 480
//#define SCREEN_WIDTH 320
#define STATUS_BAR_HEIGHT 20
#define NOTIFICATION_HEIGHT 20
#define TRUE_ZERO_Y -20

#import <UIKit/UIKit.h>
#import "AppModel.h"

#import "LoginViewController.h"
#import "MyCLController.h"

#import "model/Game.h"

#import "NearbyObjectsViewController.h"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "Item.h"
#import "Location.h"
#import "ItemDetailsViewController.h"
#import "QuestsViewController.h"
#import "IconQuestsViewController.h"
#import "GPSViewController.h"
#import "InventoryListViewController.h"
#import "AttributesViewController.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "ARViewViewControler.h"
#import "QRScannerViewController.h"
#import "AccountSettingsViewController.h"
#import "PlayerSettingsViewController.h"
#import "DeveloperViewController.h"
#import "WaitingIndicatorViewController.h"
#import "WaitingIndicatorView.h"
#import "AudioToolbox/AudioToolbox.h"
#import "Reachability.h"
#import "TutorialViewController.h"
#import "NotebookViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "PTPusherDelegate.h"
#import "GamePickerNearbyViewController.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "LoadingViewController.h"
#import "PopOverViewController.h"

@interface RootViewController : UIViewController<UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate,PTPusherDelegate> {
    
    UITabBarController *tabBarController;
    UIViewController *defaultViewControllerForMainTabBar;
    
    UITabBarController *gameSelectionTabBarController;
    TutorialViewController *tutorialViewController;
	UINavigationController *nearbyObjectsNavigationController;
	LoginViewController *loginViewController;
	UINavigationController *loginViewNavigationController;
    PlayerSettingsViewController *playerSettingsViewController;
    UINavigationController *playerSettingsViewNavigationController;
	UINavigationController *nearbyObjectNavigationController;
	WaitingIndicatorViewController *waitingIndicator;
	WaitingIndicatorView *waitingIndicatorView;
    
	LoadingViewController *loadingVC;
	UIAlertView *networkAlert;
	UIAlertView *serverAlert;
	TutorialPopupView *tutorialPopupView;
    PopOverViewController *popOverViewController;
	
    BOOL modalPresent;
    //UILabel *titleLabel;
    UIWebView *titleLabel;
    UILabel *descLabel;
    CGRect squishedVCFrame;
    CGRect notSquishedVCFrame;
    NSMutableArray *notifArray;
    NSMutableArray *popOverArray;
    //int notificationBarHeight;
    PTPusher *client;
    PTPusherPrivateChannel *playerChannel;
    PTPusherPrivateChannel *groupChannel;
    PTPusherPrivateChannel *gameChannel;
    PTPusherPrivateChannel *webpageChannel;
    //   NSDictionary *imageInfo;
    
    int SCREEN_HEIGHT;
    int SCREEN_WIDTH;
    
}
//@property(readwrite,assign)int notificationBarHeight;
@property (nonatomic) IBOutlet UITabBarController *tabBarController;
@property (nonatomic) UIViewController *defaultViewControllerForMainTabBar;
@property (nonatomic) IBOutlet UITabBarController *gameSelectionTabBarController;
@property (nonatomic) IBOutlet TutorialViewController *tutorialViewController;
@property (nonatomic) IBOutlet LoginViewController *loginViewController;
@property (nonatomic) IBOutlet UINavigationController *loginViewNavigationController;
@property (nonatomic) IBOutlet PlayerSettingsViewController *playerSettingsViewController;
@property (nonatomic) IBOutlet UINavigationController *playerSettingsViewNavigationController;
@property (nonatomic) IBOutlet UINavigationController *nearbyObjectsNavigationController;
@property (nonatomic) IBOutlet UINavigationController *nearbyObjectNavigationController;
@property (nonatomic) WaitingIndicatorViewController *waitingIndicator;
@property (nonatomic) WaitingIndicatorView *waitingIndicatorView;
@property(nonatomic)LoadingViewController *loadingVC;
@property(nonatomic) NSMutableArray *notifArray;
@property (nonatomic) UIAlertView *networkAlert;
@property (nonatomic) UIAlertView *serverAlert;
@property(nonatomic, strong) PTPusher *client;
@property(nonatomic) PTPusherPrivateChannel *playerChannel;
@property(nonatomic) PTPusherPrivateChannel *groupChannel;
@property(nonatomic) PTPusherPrivateChannel *gameChannel;
@property(nonatomic) PTPusherPrivateChannel *webpageChannel;
//@property(nonatomic)NSDictionary *imageInfo;

@property (readwrite) BOOL modalPresent;

//@property(nonatomic) IBOutlet UILabel *titleLabel;
@property(nonatomic) IBOutlet UIWebView *titleLabel;
@property(nonatomic) IBOutlet UILabel *descLabel;
@property(nonatomic) CGRect notSquishedVCFrame;
@property(nonatomic) CGRect squishedVCFrame;

+ (RootViewController *)sharedRootViewController;

- (void)selectGame:(NSNotification *)notification;
- (void)createUserAndLoginWithGroup:(NSString *)groupName andGameId:(int)gameId inMuseumMode:(BOOL)museumMode;
- (void) attemptLoginWithUserName:(NSString *)userName andPassword:(NSString *)password andGameId:(int)gameId inMuseumMode:(BOOL)museumMode;
- (void) displayNearbyObjectView:(UIViewController *)nearbyObjectsNavigationController;
- (void) showWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)yesOrNo;
- (void) showNewWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)displayProgressBar;
- (void) showServerAlertWithEmail:(NSString *)title message:(NSString *)message details:(NSString*)detail;
- (void) removeWaitingIndicator;
- (void) removeNewWaitingIndicator;
- (void) showNetworkAlert;
- (void) removeNetworkAlert;
- (void) showNearbyTab: (BOOL) yesOrNo;
- (void) returnToHomeView;
- (void) showGameSelectionTabBarAndHideOthers;
- (void) checkForDisplayCompleteNode;
- (void) displayIntroNode;
- (void) changeTabBar;
- (void) enqueueNotificationWithFullString:(NSString *)fullString andBoldedString:(NSString *)boldedString;
- (void) enqueuePopOverWithTitle:(NSString *)title description:(NSString *)description webViewText:(NSString *)text andMediaId:(int) mediaId;
- (void) showNotifications;
- (void) showPopOver;
- (void) hideNotifications;
- (void) dismissNearbyObjectView:(UIViewController *)nearbyObjectViewController;
- (void) handleOpenURLGamesListReady;
- (void) showAlert:(NSString *)title message:(NSString *)message;
- (void) didReceiveGameChannelEventNotification:(NSNotification *)notification;
- (void) didReceiveGroupChannelEventNotification:(NSNotification *)notification;
- (void) didReceivePlayerChannelEventNotification:(NSNotification *)notification;
- (void) didReceiveWebpageChannelEventNotification:(NSNotification *)notification;
@end
