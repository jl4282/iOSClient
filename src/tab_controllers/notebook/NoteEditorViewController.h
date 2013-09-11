//
//  NoteEditorViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 9/11/13.
//
//

#import <UIKit/UIKit.h>

@class Note;
@protocol NoteEditorViewControllerDelegate
- (void) noteEditorViewControllerDidFinish;
@end

@interface NoteEditorViewController : UIViewController
- (id) initWithNote:(Note *)n delegate:(id<NoteEditorViewControllerDelegate>)d;
@end
