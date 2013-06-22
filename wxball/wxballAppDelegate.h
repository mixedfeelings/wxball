//
//  wxballAppDelegate.h
//  wxball
//
//  Created by George Wietor on 6/10/13.
//  Copyright (c) 2013 George Wietor. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PreferencePanes/NSPreferencePane.h>

@interface wxballAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSButton *checkNotifications;
    IBOutlet NSButton *checkLoadStart;
    NSImage *statusImage;
    NSStatusItem *statusItem;
    NSWindow *preferences;
}

@property (assign) IBOutlet NSWindow *preferences;

-(IBAction)loadStatus:(id)sender;
-(IBAction)checkBoxNotificationsState:(id)sender;
-(IBAction)checkBoxLoadStartState:(id)sender;

@end


