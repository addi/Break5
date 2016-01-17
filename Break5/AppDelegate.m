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
    [self goOnBreak];
}

- (void)goOnBreak
{
    [self runSTPrivilegedTask:@"/usr/bin/ruby"
                    arguments:@[@"/Users/addi/bin/break5.rb"]];
    
    [NSApp terminate:self];
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
    
//    [self.outputTextField setString:outputString];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
