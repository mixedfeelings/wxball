//
//  wxballAppDelegate.h
//  wxball
//
//  Created by George Wietor on 6/10/13.
//  Copyright (c) 2013 George Wietor. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface wxballAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSButton *checkNotifications;
    IBOutlet NSButton *checkLoadStart;
    NSImage *statusImage;
    NSStatusItem *statusItem;
    NSWindow *preferences;
    LSSharedFileListRef loginItemsListRef;
}

//@property (assign) IBOutlet NSWindow *window;

-(IBAction)loadStatus:(id)sender;
-(IBAction)checkBoxNotificationsState:(id)sender;
-(IBAction)checkBoxLoadStartState:(id)sender;
-(IBAction)toggleLaunchAtLogin:(id)sender;

@end


