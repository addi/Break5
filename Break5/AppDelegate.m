//
//  AppDelegate.m
//  Break5
//
//  Created by Árni Jónsson on 17.1.2016.
//  Copyright © 2016 Árni Jónsson. All rights reserved.
//

#import "AppDelegate.h"
#import "STPrivilegedTask.h"

#define MODE_BREAK 1
#define MODE_LOCK 2
#define MODE_UNLOCK 3

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSString *type = @"break";
    int length = 5;
    
#if B5TYPE == MODE_LOCK
    type = @"lock";
#elif B5TYPE == MODE_UNLOCK
    type = @"unlock";
#endif
    
#ifdef B5LENGTH
    length = B5LENGTH;
#endif
    
    if([type isEqualToString:@"break"])
        [self goOnBreak:type
                 length:[@(length) stringValue]];
    else
        [self runScript:type
                 length:[@(length) stringValue]];
        
    [NSApp terminate:self];
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

- (void)goOnBreak:(NSString *)type
           length:(NSString *)length
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *lastBreak = [defaults valueForKey:@"lastBreak"];
    
    NSDate *now = [NSDate date];
    
    NSTimeInterval secondsBetween = [now timeIntervalSinceDate:lastBreak];

    int minumumSecondsSinceLastBreak = 60 * 35;
    
    if (lastBreak == nil || secondsBetween >= minumumSecondsSinceLastBreak) {
        NSDate *now = [NSDate date];
        
        [defaults setObject:now forKey:@"lastBreak"];
        
        [self runScript:type
                 length:length];
    }
    else {
        int secondsUntilNextBreak = minumumSecondsSinceLastBreak - secondsBetween;
        
        int minutesUntilNextBreak = secondsUntilNextBreak / 60;
        
        int secondsAfterMintuesUntilNextBreak = secondsUntilNextBreak - minutesUntilNextBreak * 60;
        
        [self showAlertWithMinutesUntilNextBreak:minutesUntilNextBreak
                           secondsUntilNextBreak:secondsAfterMintuesUntilNextBreak];
    }
}

- (void)runScript:(NSString *)type
           length:(NSString *)length
{
    NSString *rubyFilePath = [[NSBundle mainBundle] pathForResource:@"break5" ofType:@"rb"];
        
    [self runSTPrivilegedTask:@"/usr/bin/ruby"
                    arguments:@[rubyFilePath, type, length]];
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
