//
//  AppDelegate.m
//  4G Battery Meter
//
//  Created by carlos on 14/11/2016.
//  Copyright © 2016 Carl. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) BOOL darkModeOn;
@property (assign, nonatomic) NSString *percent;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"not_connected.png"];
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu; 
    
    // Run once to update non-connected state
    [self getBatteryPercentAndSetImage];
    
    
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(getBatteryPercentAndSetImage) userInfo:nil repeats:YES];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)getBatteryPercentAndSetImage{
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    NSString *url = [NSString stringWithFormat: @"http://192.168.0.1/goform/goform_get_cmd_process?cmd=battery_vol_percent"];
    [request setURL:[NSURL URLWithString:url]];
    [request setValue:@"http://192.168.0.1/" forHTTPHeaderField:@"referer"];
    [request setTimeoutInterval:5];
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        _statusItem.image = [NSImage imageNamed:@"not_connected.png"];
        return;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:oResponseData options:kNilOptions error:&error];
    _percent = json[@"battery_vol_percent"];
    NSLog(@"Percent: %@", _percent);
    
    if(_percent > 75){
        _statusItem.image = [NSImage imageNamed:@"four.png"];
    } else if(_percent > 50 && _percent <= 75){
        _statusItem.image = [NSImage imageNamed:@"three.png"];
    } else if(_percent > 25 && _percent <= 50){
        _statusItem.image = [NSImage imageNamed:@"two.png"];
    } else if(_percent >= 0 && _percent <=25){
        _statusItem.image = [NSImage imageNamed:@"one.png"];
    }
}

@end
