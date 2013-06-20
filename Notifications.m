
#import "Notifications.h"

@implementation Notifications

-(IBAction)delivernotification:(id)sender {
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(notify) userInfo:nil repeats:NO];
    
}

-(void)notify {
    
    NSUserNotificationCenter *nc = [NSUserNotificationCenter defaultUserNotificationCenter];
    NSUserNotification *notification = [[NSUserNotification alloc]init];
    nc.delegate = self;
    notification.title = @"Hello Youtube";
    notification.informativeText = @"How are you doing";
    notification.subtitle = @"Notifications :)";
    notification.actionButtonTitle = @"click here";
    notification.hasActionButton = YES;
    [nc deliverNotification:notification];
    
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    
    if (notification.activationType = NSUserNotificationActivationTypeActionButtonClicked) {
        NSLog(@"ch");
    }
    
}

@end
