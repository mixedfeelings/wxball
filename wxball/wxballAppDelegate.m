//
//  wxballAppDelegate.m
//  wxball
//
//  Created by George Wietor on 6/10/13.
//  Copyright (c) 2013 George Wietor. All rights reserved.
//

#import "wxballAppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>
// local HIDAPI library
#include "hidapi.h"
#include "blink1-lib.h"


@implementation wxballAppDelegate

- (void)awakeFromNib {
   
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSBundle *bundle = [NSBundle mainBundle];

    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"grey" ofType:@"png"]];
    
    [statusItem setImage:statusImage];
    [statusItem setHighlightMode:YES];
    [statusItem setEnabled:YES];
    [statusItem setMenu:statusMenu];
    [preferences setLevel:NSFloatingWindowLevel];
    [NSApp activateIgnoringOtherApps:YES];


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
    

    checkLoadStart.target = self;

    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_7) {
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        checkNotifications.enabled = NO;
        
    }
    [preferences setLevel:NSFloatingWindowLevel];
    [NSApp activateIgnoringOtherApps:YES];

    
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *loadSelect = [defaults objectForKey:@"locationSelect"];
    
    //NSLog(@"response: %@", loadSelect);
    
    if ([loadSelect intValue] == 0) {
       
        [self getWXBall:nil];
    
    } else if ([loadSelect intValue] == 1) {
    
        [self loadLatLong:nil];
        zipCode.enabled = YES;

    
    }


}

-(IBAction)locationSelect:(NSMatrix *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * tag = [NSNumber numberWithInteger:[[sender selectedCell] tag]];
    
    switch ([[sender selectedCell] tag]) {
        case 0:
            zipCode.enabled = NO;
            [self loadStatus:nil];
            break;
        case 1:
            zipCode.enabled = YES;
            [zipCode becomeFirstResponder];
            [self loadStatus:nil];
            break;
        default:
            break;
    
    }

    [defaults setObject:tag forKey:@"locationSelect"];
    [defaults synchronize];

    //NSLog(@"Selected cell is %@", tag);
}

-(IBAction)saveZipCode:(id)sender {
    
    NSString *saveString = zipCode.stringValue;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:saveString forKey:@"zipCode"];
    [defaults synchronize];
    
    [self loadLatLong:nil];

}

-(IBAction)loadLatLong:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *zipCoder = [defaults objectForKey:@"zipCode"];
    NSString *str = [zipCoder stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", str];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLResponse *resp = nil;
    NSError *err = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
    
    //NSString * theString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    //NSLog(@"response: %@", theString);
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: response options: NSJSONReadingMutableContainers error: &err];
    
    if (!jsonArray) {
        
        NSLog(@"Error parsing JSON: %@", err);
        
    } else {
        
        NSArray *results = [jsonArray valueForKey:@"results"];
        NSArray *result = [(NSDictionary*)jsonArray objectForKey:@"results"];

        for(int i=0;i<[result count];i++)
        {
            NSDictionary *values = (NSDictionary*)[result objectAtIndex:i];
            NSArray *component = [(NSDictionary*)values objectForKey:@"address_components"];
            
            for(int j=0;j<[component count];j++)
            {
                NSDictionary *parts = (NSDictionary*)[component objectAtIndex:j];
                if([[parts objectForKey:@"types"] containsObject:@"locality"])
                {
                    NSString *city = [parts objectForKey:@"long_name"];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:city forKey:@"city"];
                    [defaults synchronize];
                }
                if([[parts objectForKey:@"types"] containsObject:@"administrative_area_level_1"])
                {
                    NSString *state = [parts objectForKey:@"short_name"];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:state forKey:@"state"];
                    [defaults synchronize];
                }
            }
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *city = [defaults objectForKey:@"city"];
        NSString *state = [defaults objectForKey:@"state"];
        NSString *comma = @", ";
        
        NSString *cityComma = [city stringByAppendingString: comma];
        NSString *cityState = [cityComma stringByAppendingString: state];
        [defaults setObject:cityState forKey:@"cityState"];
        [defaults synchronize];

        NSDictionary *geometry = [results valueForKey:@"geometry"];
        NSDictionary *location = [geometry valueForKey:@"location"];
    
        for(NSDictionary *item in location) {
            
            NSString *lat = [item objectForKey:@"lat"];
            NSString *lng = [item objectForKey:@"lng"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:lat forKey:@"lat"];
            [defaults setObject:lng forKey:@"lng"];
            [defaults synchronize];

            self->zipCode.stringValue = cityState;
        }

    }
    [self getForecast:nil];
}


-(IBAction)getForecast:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lat = [defaults objectForKey:@"lat"];
    NSString *lng = [defaults objectForKey:@"lng"];
    
    lat = [(NSNumber*)lat stringValue];
    lng = [(NSNumber*)lng stringValue];
    NSString *comma = @",";
    
    NSString *latComma = [lat stringByAppendingString: comma];
    NSString *latLng = [latComma stringByAppendingString: lng];

    
    NSString *url = [NSString stringWithFormat:@"https://api.forecast.io/forecast/1c253a9e98b39287a54cf317702bb20a/%@?exclude=minutely", latLng];
    
    //NSLog(@"latLng: %@", latLng);
    
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLResponse *resp = nil;
    NSError *err = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
    
    //NSString * theString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    //NSLog(@"response: %@", theString);
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: response options: NSJSONReadingMutableContainers error: &err];
    
    if (!jsonArray) {
   
        NSLog(@"Error parsing JSON: %@", err);
        
    } else {
        
        NSDictionary *currently = [jsonArray valueForKey:@"currently"];
        //NSArray *currentTemp = [currently valueForKey:@"temperature"];
        NSString *currentTemp = [currently valueForKey:@"temperature"];
        
        NSDictionary *hourly = [jsonArray valueForKey:@"hourly"];
        NSDictionary *futureData = [hourly valueForKey:@"data"];
        NSArray *futureTemp = [futureData valueForKey:@"temperature"];
        NSString *futureFuture = futureTemp[7];
        
        //NSDictionary *icon = [hourly valueForKey:@"data"];
        NSArray *futureIcon = [futureData valueForKey:@"icon"];
        NSString *futIcon = futureIcon[7];
        
        
        //NSLog(@"future temp: %@", futureTemp[4]);
        //NSLog(@"current temp: %@", currentTemp);
        //NSLog(@"future temp: %@", futureFuture);
        //NSLog(@"type: %@", futIcon);
        
        float futTemp;
        float curTemp;
        
        futTemp = [futureFuture floatValue];
        curTemp = [currentTemp floatValue];
        
        int dif = abs(futTemp - curTemp);
        //NSLog(@"dif: %d", dif);
                
        if ([futIcon isEqualToString:@"rain"] || [futIcon isEqualToString:@"snow"] || [futIcon isEqualToString:@"sleet"] || [futIcon isEqualToString:@"hail"] || [futIcon isEqualToString:@"thunderstorm"]) {
            if ((dif > 5)&&(futTemp > curTemp)) {
               
                [self setRedBlink:nil];
                
            } else if ((dif > 5)&&(futTemp < curTemp)) {
                
                [self setBlueBlink:nil];
                
            } else {
               
                [self setGreenBlink:nil];
                
            }
        } else {
            if ((dif > 5)&&(futTemp > curTemp)) {
                
                [self setRed:nil];
                
            } else if ((dif > 5)&&(futTemp < curTemp)) {
                
                [self setBlue:nil];
            
            } else {
                
                [self setGreen:nil];
            
            }
        }
                
    }
}

-(IBAction)getWXBall:(id)sender {
    
    NSBundle *bundle = [NSBundle mainBundle];

    NSString *url=@"http://george.wietor.com/labs/wxball/status/json";
    
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
                        
            if ([blink isEqualToString:@"0"]) {
                
                if ([color isEqualToString:@"1"]) {
                   
                    [self setRed:nil];
                    
                } if ([color isEqualToString:@"2"]) {
                
                    [self setGreen:nil];
                
                } if ([color isEqualToString:@"3"]) {
                
                    [self setBlue:nil];
                    
                }
            
            } else {
            
                if ([color isEqualToString:@"1"]) {
                
                    [self setRedBlink:nil];
                
                } if ([color isEqualToString:@"2"]) {

                    [self setGreenBlink:nil];
                
                } if ([color isEqualToString:@"3"]) {

                    [self setBlueBlink:nil];
                
                }
            
            } // blink
            
        
        } // /for
    
    } //json
    
}

-(IBAction)setRed:(id)sender {
   
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"red" ofType:@"png"]];
    [statusItem setImage:statusImage];
    [statusItem setToolTip:@"Weather ball red, warmer weather ahead"];
    
    //Notification
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *status = @"10";
    NSString *lastStatus = [defaults objectForKey:@"lastStatus"];
    NSString *Notify = [defaults objectForKey:@"Notify"];
    
    if ([Notify isEqualToString:@"yes"]) {

        if (![lastStatus isEqualToString:status]) {

            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"WXBall";
            notification.informativeText = [NSString stringWithFormat:@"Weather ball red, warmer weather ahead"];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
        
    }
    
    [defaults setObject:status forKey:@"lastStatus"];
    [defaults synchronize];
}

-(IBAction)setGreen:(id)sender {
    
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"green" ofType:@"png"]];
    [statusItem setImage:statusImage];
    [statusItem setToolTip:@"Weather ball green, no change forseen"];
   
    //Notification
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *status = @"20";
    NSString *lastStatus = [defaults objectForKey:@"lastStatus"];
    NSString *Notify = [defaults objectForKey:@"Notify"];
    
    
    if ([Notify isEqualToString:@"yes"]) {
        
        if (![lastStatus isEqualToString:status]) {
        
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"WXBall";
            notification.informativeText = [NSString stringWithFormat:@"Weather ball green, no change forseen"];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        }
        
    }
   
    [defaults setObject:status forKey:@"lastStatus"];
    [defaults synchronize];
}

-(IBAction)setBlue:(id)sender {
    
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"blue" ofType:@"png"]];
    [statusItem setImage:statusImage];
    [statusItem setToolTip:@"Weather ball blue, colder weather in view"];
    
    //Notification
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *status = @"30";
    NSString *lastStatus = [defaults objectForKey:@"lastStatus"];
    NSString *Notify = [defaults objectForKey:@"Notify"];
    
    if ([Notify isEqualToString:@"yes"]) {

        if (![lastStatus isEqualToString:status]) {
       
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"WXBall";
            notification.informativeText = [NSString stringWithFormat:@"Weather ball blue, colder weather in view"];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        }
    
    }
   
    [defaults setObject:status forKey:@"lastStatus"];
    [defaults synchronize];
    
}

-(IBAction)setRedBlink:(id)sender {
    
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"red_blink" ofType:@"png"]];
    [statusItem setImage:statusImage];
    [statusItem setToolTip:@"Weather ball red, warmer weather ahead / Colors blinking bright, rain or snow in sight"];

    //Notification
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *status = @"11";
    NSString *lastStatus = [defaults objectForKey:@"lastStatus"];
    NSString *Notify = [defaults objectForKey:@"Notify"];
    
    if ([Notify isEqualToString:@"yes"]) {

        if (![lastStatus isEqualToString:status]) {

            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"WXBall";
            notification.informativeText = [NSString stringWithFormat:@"Weather ball red, warmer weather ahead / Colors blinking bright, rain or snow in sight"];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
        }
   
    }
    
    [defaults setObject:status forKey:@"lastStatus"];
    [defaults synchronize];
    
}

-(IBAction)setGreenBlink:(id)sender {
    
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"green_blink" ofType:@"png"]];
    [statusItem setImage:statusImage];
    [statusItem setToolTip:@"Weather ball green, no change forseen / Colors blinking bright, rain or snow in sight"];
    
    //Notification
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *status = @"21";
    NSString *lastStatus = [defaults objectForKey:@"lastStatus"];
    NSString *Notify = [defaults objectForKey:@"Notify"];
    
    if ([Notify isEqualToString:@"yes"]) {
        
        if (![lastStatus isEqualToString:status]) {
        
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"WXBall";
            notification.informativeText = [NSString stringWithFormat:@"Weather ball green, no change forseen / Colors blinking bright, rain or snow in sight"];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            
        }
        
    }
    
    [defaults setObject:status forKey:@"lastStatus"];
    [defaults synchronize];
}

-(IBAction)setBlueBlink:(id)sender {
    
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource:@"blue_blink" ofType:@"png"]];
    [statusItem setImage:statusImage];
    [statusItem setToolTip:@"Weather ball blue, colder weather in view / Colors blinking bright, rain or snow in sight"];
    
    //Notification
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *status = @"31";
    NSString *lastStatus = [defaults objectForKey:@"lastStatus"];
    NSString *Notify = [defaults objectForKey:@"Notify"];
    
    if ([Notify isEqualToString:@"yes"]) {
        
        if (![lastStatus isEqualToString:status]) {
       
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"WXBall";
            notification.informativeText = [NSString stringWithFormat:@"Weather ball Blue, colder weather in view / Colors blinking bright, rain or snow in sight"];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
        
    }
    
    [defaults setObject:status forKey:@"lastStatus"];
    [defaults synchronize];

}


@end
