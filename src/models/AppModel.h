//
//  AppModel.h
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreData/CoreData.h>

@class Game;
@class Player;
@class Media;
@class Location;
@class Item;
@class Node;
@class Npc;
@class WebPage;
@class Panoramic;

@class MediaCache;
@class UploadMan;
@class Overlay;

@interface AppModel : NSObject
{
	NSURL *serverURL;
    BOOL showGamesInDevelopment;
    BOOL showPlayerOnMap;
    
    BOOL disableLeaveGame;
    int skipGameDetails;
    
	Game *currentGame;
    Player *player;

    int fallbackGameId;
    
    NSMutableArray *oneGameGameList;
	NSMutableArray *nearbyGameList;
	NSMutableArray *anywhereGameList;
    NSMutableArray *popularGameList;
    NSMutableArray *recentGamelist;
    NSMutableArray *searchGameList;
    
	NSMutableArray *nearbyLocationsList;

	NSMutableDictionary *gameMediaList;
	NSMutableDictionary *gameItemList;
	NSMutableDictionary *gameNodeList;
	NSMutableDictionary *gameNpcList;
    NSMutableDictionary *gameWebPageList;
    NSMutableDictionary *gamePanoramicList;
    NSMutableArray *gameTagList;
    NSMutableArray *overlayList;

    BOOL overlayIsVisible;
 
    BOOL hidePlayers;
    
    //CORE Data
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    UploadMan *uploadManager;
    MediaCache *mediaCache;
    
    CMMotionManager *motionManager;
}

@property (nonatomic, strong) NSURL *serverURL;
@property (readwrite) BOOL showGamesInDevelopment;
@property (readwrite) BOOL showPlayerOnMap;
@property (readwrite) BOOL disableLeaveGame;
@property (readwrite) int  skipGameDetails;

@property (readwrite) BOOL hidePlayers;

@property (readwrite) BOOL overlayIsVisible;

@property (readwrite) int fallbackGameId;//Used only to recover from crashes

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) Game *currentGame;

@property (nonatomic, strong) NSMutableArray *oneGameGameList;
@property (nonatomic, strong) NSMutableArray *nearbyGameList;
@property (nonatomic, strong) NSMutableArray *anywhereGameList;
@property (nonatomic, strong) NSMutableArray *searchGameList;
@property (nonatomic, strong) NSMutableArray *popularGameList;
@property (nonatomic, strong) NSMutableArray *recentGameList;	

@property (nonatomic, strong) NSMutableArray *nearbyLocationsList;	

@property (nonatomic, strong) NSMutableArray *gameTagList;
@property (nonatomic, strong) NSMutableArray *overlayList;
@property (nonatomic, strong) NSMutableDictionary *gameMediaList;
@property (nonatomic, strong) NSMutableDictionary *gameItemList;
@property (nonatomic, strong) NSMutableDictionary *gameNodeList;
@property (nonatomic, strong) NSMutableDictionary *gameNpcList;
@property (nonatomic, strong) NSMutableDictionary *gameWebPageList;
@property (nonatomic, strong) NSMutableDictionary *gamePanoramicList;

// CORE Data
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) UploadMan *uploadManager;
@property (nonatomic, strong) MediaCache *mediaCache;

@property (nonatomic, strong) CMMotionManager *motionManager;

+ (AppModel *) sharedAppModel;

- (void) resetAllGameLists;
- (void) resetAllPlayerLists;

- (void) commitPlayerLogin:(Player *)p;
- (void) setPlayerLocation:(CLLocation *)newLocation;

- (void) initUserDefaults;
- (void) saveUserDefaults;
- (void) loadUserDefaults;
- (void) saveCOREData;

- (Media *) mediaForMediaId:(int)mId ofType:(NSString *)type;
- (Item *) itemForItemId:(int)mId;
- (Node *) nodeForNodeId:(int)mId;
- (Npc *) npcForNpcId:(int)mId;
- (WebPage *) webPageForWebPageId:(int)mId;
- (Panoramic *) panoramicForPanoramicId:(int)mId;

@end
