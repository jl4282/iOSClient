//
//  MapHUD.h
//  ARIS
//
//  Created by Phil Dougherty on 2/6/14.
//
//

#import <UIKit/UIKit.h>
@protocol MapHUDDelegate

@end
@interface MapHUD : UIViewController
- (id) initWithDelegate:(id<MapHUDDelegate>)d;
@end
