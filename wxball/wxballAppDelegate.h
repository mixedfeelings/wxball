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
    NSImage *statusImage;
    NSStatusItem *statusItem;
    
}

//@property (assign) IBOutlet NSWindow *window;

-(IBAction)loadStatus:(id)sender;

@end


