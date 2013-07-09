//
//  wxballAppDelegate.h
//  wxball
//
//  Created by George Wietor on 6/10/13.
//  Copyright (c) 2013 George Wietor. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "Blink1.h"



@interface wxballAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, NSTextFieldDelegate, NSSharingServiceDelegate> {
    
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSButton *checkNotifications;
    IBOutlet NSButton *checkLoadStart;
    IBOutlet NSTextField *zipCode;
    IBOutlet NSMatrix *locationSelect;
    Blink1 *_blink;

    
    NSImage *statusImage;
    NSStatusItem *statusItem;
    NSWindow *preferences;
    LSSharedFileListRef loginItemsListRef;
}

//@property (assign) IBOutlet NSWindow *window;

-(IBAction)loadStatus:(id)sender;
-(IBAction)locationSelect:(id)sender;
-(IBAction)saveZipCode:(id)sender;
-(IBAction)loadLatLong:(id)sender;
-(IBAction)checkBoxNotificationsState:(id)sender;
-(IBAction)checkBoxLoadStartState:(id)sender;
-(IBAction)setRed:(id)sender;
-(IBAction)setGreen:(id)sender;
-(IBAction)setBlue:(id)sender;
-(IBAction)setRedBlink:(id)sender;
-(IBAction)setGreenBlink:(id)sender;
-(IBAction)setBlueBlink:(id)sender;


@end


