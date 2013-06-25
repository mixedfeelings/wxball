//
//  wxballAppDelegate.m
//  wxballHelper
//
//  Created by George Wietor on 6/24/13.
//  Copyright (c) 2013 George Wietor. All rights reserved.
//

#import "wxballAppDelegate.h"

@implementation wxballAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Check if main app is already running; if yes, do nothing and terminate helper app
    BOOL alreadyRunning = NO;
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running) {
        if ([[app bundleIdentifier] isEqualToString:@"com.wietor.wxball"]) {
            alreadyRunning = YES;
        }
    }
    
    if (!alreadyRunning) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSArray *p = [path pathComponents];
        NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents addObject:@"MacOS"];
        [pathComponents addObject:@"wxball"];
        NSString *newPath = [NSString pathWithComponents:pathComponents];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:@"launchWxball"], NSWorkspaceLaunchConfigurationArguments, nil];
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[NSURL fileURLWithPath:newPath]
                                                      options:NSWorkspaceLaunchWithoutActivation
                                                configuration:dict
                                                        error:nil];
    }
    
    [NSApp terminate:nil];

}

@end
