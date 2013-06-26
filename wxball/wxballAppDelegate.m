//
//  wxballAppDelegate.m
//  wxball
//
//  Created by George Wietor on 6/10/13.
//  Copyright (c) 2013 George Wietor. All rights reserved.
//

#import "wxballAppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>
#import "LLManager.h"


@implementation wxballAppDelegate

- (void)awakeFromNib {
   
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSBundle *bundle = [NSBundle mainBundle];

    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"grey" ofType:@"png"]];
    
    [statusItem setImage:statusImage];
    [statusItem setHighlightMode:YES];
    [statusItem setEnabled:YES];
    [statusItem setMenu:statusMenu];
    
    BOOL startedAtLogin = NO;
    for (NSString *arg in [[NSProcessInfo processInfo] arguments]) {
        if ([arg isEqualToString:@"launchWxball"]) startedAtLogin = YES;
    }

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    //Refresh data every 30 minutes.
    [NSTimer scheduledTimerWithTimeInterval:1800.0
                                     target:self
                                   selector:@selector(loadStatus:)
                                   userInfo:nil
                                    repeats:YES];
    
    //Do the first prediction loading.
    [self loadStatus:nil];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];


}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

-(IBAction)checkBoxNotificationsState:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([checkNotifications state] == NSOffState) {
        
        NSString *notify=@"no";
        [defaults setObject:notify forKey:@"Notify"];
        [defaults synchronize];
    
    } else {
    
        NSString *notify=@"yes";
        [defaults setObject:notify forKey:@"Notify"];
        [defaults synchronize];
    }

}


-(IBAction)checkBoxLoadStartState:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
    if ([checkLoadStart state] == NSOffState) {
        
        NSString *notify=@"no";
        [defaults setObject:notify forKey:@"loadStart"];
        [defaults synchronize];
        
        
    } else {
        
        NSString *notify=@"yes";
        [defaults setObject:notify forKey:@"loadStart"];
        [defaults synchronize];

    }
    
}


-(IBAction)loadStatus:(id)sender {
    
    NSBundle *bundle = [NSBundle mainBundle];

    NSString *url=@"http://george.wietor.com/labs/wxball/status/json/test";
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLResponse *resp = nil;
    NSError *err = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
    //NSLog(@"response: %@", response);

    //NSString * theString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    //NSLog(@"response: %@", theString);
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: response options: NSJSONReadingMutableContainers error: &err];
    
    if (!jsonArray) {
        
        NSLog(@"Error parsing JSON: %@", err);
        statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"black" ofType:@"png"]];
        [statusItem setImage:statusImage];
        [statusItem setToolTip:@"Weather ball black, something's out of wack"];
    
    } else {
        for(NSDictionary *item in jsonArray) {
            
            NSString *color = [item objectForKey:@"color"];
            NSString *blink = [item objectForKey:@"blink"];
            //NSLog(@" %@", blink);
            
            NSString *status = [color stringByAppendingString: blink];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *lastStatus = [defaults objectForKey:@"lastStatus"];
            NSString *Notify = [defaults objectForKey:@"Notify"];
            
            //NSLog(@" %@", Notify);
            //NSLog(@" %@", status);
            
            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_7) {
                if ([Notify isEqualToString:@"yes"]) {
                    if (![lastStatus isEqualToString:status]) {
                        if ([blink isEqualToString:@"0"]) {
                            
                            if ([color isEqualToString:@"1"]) {
                                
                                NSUserNotification *notification = [[NSUserNotification alloc] init];
                                notification.title = @"wxball";
                                notification.informativeText = [NSString stringWithFormat:@"Weather ball red, warmer weather ahead"];
                                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                                
                                
                            } if ([color isEqualToString:@"2"]) {
                                
                                NSUserNotification *notification = [[NSUserNotification alloc] init];
                                notification.title = @"wxball";
                                notification.informativeText = [NSString stringWithFormat:@"Weather ball green, no change forseen"];
                                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                                
                            } if ([color isEqualToString:@"3"]) {
                                
                                NSUserNotification *notification = [[NSUserNotification alloc] init];
                                notification.title = @"wxball";
                                notification.informativeText = [NSString stringWithFormat:@"Weather ball blue, colder weather in view"];
                                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                                
                            }
                            
                        } else {
                            
                            if ([color isEqualToString:@"1"]) {
                                
                                NSUserNotification *notification = [[NSUserNotification alloc] init];
                                notification.title = @"wxball";
                                notification.informativeText = [NSString stringWithFormat:@"Weather ball red, warmer weather ahead / Colors blinking bright, rain or snow in sight"];
                                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                                
                            } if ([color isEqualToString:@"2"]) {
                                
                                NSUserNotification *notification = [[NSUserNotification alloc] init];
                                notification.title = @"wxball";
                                notification.informativeText = [NSString stringWithFormat:@"Weather ball green, no change forseen / Colors blinking bright, rain or snow in sight"];
                                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                                
                                
                            } if ([color isEqualToString:@"3"]) {
                                
                                NSUserNotification *notification = [[NSUserNotification alloc] init];
                                notification.title = @"wxball";
                                notification.informativeText = [NSString stringWithFormat:@"Weather ball blue, colder weather in view / Colors blinking bright, rain or snow in sight"];
                                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                                
                            }
                            
                        }
                    
                    }

                }
            }
            
            
            if ([blink isEqualToString:@"0"]) {
                
                if ([color isEqualToString:@"1"]) {
                
                    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"red" ofType:@"png"]];
                    [statusItem setImage:statusImage];
                    [statusItem setToolTip:@"Weather ball red, warmer weather ahead"];
                    
                } if ([color isEqualToString:@"2"]) {
                
                    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"green" ofType:@"png"]];
                    [statusItem setImage:statusImage];
                    [statusItem setToolTip:@"Weather ball green, no change forseen"];
                
                } if ([color isEqualToString:@"3"]) {
                
                    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"blue" ofType:@"png"]];
                    [statusItem setImage:statusImage];
                    [statusItem setToolTip:@"Weather ball blue, colder weather in view"];
                    
                }
            
            } else {
            
                if ([color isEqualToString:@"1"]) {
                
                    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"red_blink" ofType:@"png"]];
                    [statusItem setImage:statusImage];
                    [statusItem setToolTip:@"Weather ball red, warmer weather ahead / Colors blinking bright, rain or snow in sight"];
                
                } if ([color isEqualToString:@"2"]) {
                
                    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"green_blink" ofType:@"png"]];
                    [statusItem setImage:statusImage];
                    [statusItem setToolTip:@"Weather ball green, no change forseen / Colors blinking bright, rain or snow in sight"];
                
                } if ([color isEqualToString:@"3"]) {
                
                    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"blue_blink" ofType:@"png"]];
                    [statusItem setImage:statusImage];
                    [statusItem setToolTip:@"Weather ball blue, colder weather in view / Colors blinking bright, rain or snow in sight"];
                
                }
            
            }
            
            NSString *saveStatus = [color stringByAppendingString: blink];
            [defaults setObject:saveStatus forKey:@"lastStatus"];
            [defaults synchronize];
        
        }
    
    }
    
}
@end
