//
//  AppDelegate.m
//  Break5
//
//  Created by Árni Jónsson on 17.1.2016.
//  Copyright © 2016 Árni Jónsson. All rights reserved.
//

#import "AppDelegate.h"
#import "STPrivilegedTask.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *lastBreak = [defaults valueForKey:@"lastBreak"];
    
    NSDate *now = [NSDate date];
    
    NSTimeInterval secondsBetween = [now timeIntervalSinceDate:lastBreak];

    int minumumSecondsSinceLastBreak = 60 * 35;
    
    if (lastBreak == nil || secondsBetween >= minumumSecondsSinceLastBreak) {
        NSDate *now = [NSDate date];
        
        [defaults setObject:now forKey:@"lastBreak"];
        
        [self goOnBreak];
        
        [NSApp terminate:self];
    }
    else {
        int secondsUntilNextBreak = minumumSecondsSinceLastBreak - secondsBetween;
        
        int minutesUntilNextBreak = secondsUntilNextBreak / 60;
        
        int secondsAfterMintuesUntilNextBreak = secondsUntilNextBreak - minutesUntilNextBreak * 60;
        
        [self showAlertWithMinutesUntilNextBreak:minutesUntilNextBreak
                           secondsUntilNextBreak:secondsAfterMintuesUntilNextBreak];
        
        [NSApp terminate:self];
    }
}

- (void)showAlertWithMinutesUntilNextBreak:(int)minutesUntilNextBreak
                     secondsUntilNextBreak:(int)secondsUntilNextBreak
{
    NSString *informativeText = [NSString stringWithFormat:@"Next break in %d:%02d minutes", minutesUntilNextBreak, secondsUntilNextBreak];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Too little time since your last break"];
    [alert setInformativeText:informativeText];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
}

- (void)goOnBreak
{
    NSString *rubyFilePath = [[NSBundle mainBundle] pathForResource:@"break5" ofType:@"rb"];
    
    [self runSTPrivilegedTask:@"/usr/bin/ruby"
                    arguments:@[rubyFilePath]];
}

- (void)runSTPrivilegedTask:(NSString *)path
                  arguments:(NSArray *)arguments
{
    //initalize task
    STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
    
    [privilegedTask setLaunchPath:path];
    [privilegedTask setArguments:arguments];
    
    //set it off
    OSStatus err = [privilegedTask launch];
    if (err != errAuthorizationSuccess) {
        if (err == errAuthorizationCanceled) {
            return;
        }  else {
            NSLog(@"Something went wrong");
        }
    }
    
    // Success!  Now, start monitoring output file handle for data
    NSFileHandle *readHandle = [privilegedTask outputFileHandle];
    NSData *outputData = [readHandle readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", outputString);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
