
// Thanks to shpakovski for his great works
// https://github.com/shpakovski/MASPreferences
// https://github.com/shpakovski/MASPreferencesDemo




#import "SendStreamAppDelegate.h"
#import "MASPreferencesWindowController.h"
#import "GeneralPreferencesViewController.h"
// #import "AdvancedPreferencesViewController.h"
#import <IOKit/pwr_mgt/IOPMLib.h>


@implementation SendStreamAppDelegate

@synthesize window = _window;

IOPMAssertionID _assertionID;


#pragma mark -

- (void)dealloc
{
    [_preferencesWindowController release];
    [super dealloc];
}

#pragma mark - NSApplicationDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}


- (void) applicationWillTerminate: (NSNotification *)aNotification
{
    if (_task) {
        [_task terminate];
    }
}


- (BOOL)application:(NSApplication *)app openFile:(NSString *)filename
{
    [_urlTextField setStringValue:filename];
    return TRUE;
}




#pragma mark - Public accessors

- (NSWindowController *)preferencesWindowController
{
    if (_preferencesWindowController == nil)
    {
        NSViewController *generalViewController = [[GeneralPreferencesViewController alloc] init];
        NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, nil];
        
        // NSViewController *advancedViewController = [[AdvancedPreferencesViewController alloc] init];
        // NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, advancedViewController, nil];
        
        // To add a flexible space between General and Advanced preference panes insert [NSNull null]:
        //     NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, [NSNull null], advancedViewController, nil];
        
        [generalViewController release];
        //[advancedViewController release];
        
        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
        [controllers release];
    }
    return _preferencesWindowController;
}



#pragma mark - Actions

- (IBAction)runCommand:(id)sender
{
    
    if (_task) {
        [_task terminate];
        [_resultTextField setStringValue:@"Ready"];
        return;
    }
    
    // Prevent sleep
    IOReturn success = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoIdleSleep,
                                                   kIOPMAssertionLevelOn, CFSTR("Streaming file"), &_assertionID);
    
    if (success != kIOReturnSuccess) {
        NSLog(@"Unable to prevent sleep");
    }
    
    
    // get .app path and append idok path
    NSString *commandPath = [NSString stringWithFormat:@"%@/Contents/Resources/SendStreamHelper",
                             [[NSBundle mainBundle] bundlePath]];
    
    _task = [[[NSTask alloc] init] autorelease];
    [_task setLaunchPath:commandPath];
    
    NSMutableArray *args = [NSMutableArray array];
    
    if ([[self settingsTargetIP] length] != 0) {
        [args addObject: [NSString stringWithFormat:@"-target=%@", [self settingsTargetIP]]];
    } else {
        [_resultTextField setStringValue:@"Error: missing Kodi IP address under preferences"];
        return;
    }
    
    if ([[self settingsTargetPort] length] != 0) {
        [args addObject: [NSString stringWithFormat:@"-targetport=%@", [self settingsTargetIP]]];
    }
    
    if ([[self settingsTargetPort] length] != 0) {
        [args addObject: [NSString stringWithFormat:@"-login=\"%@\"", [self settingsTargetIP]]];
    }
    
    if ([[self settingsTargetPort] length] != 0) {
        [args addObject: [NSString stringWithFormat:@"-password=\"%@\"", [self settingsTargetIP]]];
    }
    
    
    [args addObject: [_urlTextField stringValue]];
    
    [_task setArguments:args];
    
    _task.standardOutput = [NSPipe pipe];
    [[_task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        [self parsePipeOutput:[file availableData]];
    }];
    
    _task.standardError = [NSPipe pipe];
    [[_task.standardError fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        [self parsePipeOutput:[file availableData]];
    }];
    
    [_task setTerminationHandler:^(NSTask *task) {
        [task.standardOutput fileHandleForReading].readabilityHandler = nil;
        [task.standardError fileHandleForReading].readabilityHandler = nil;
        [[self sendButton] setTitle:@"Send and play"];
        _task = nil;
        // Restore sleep behaviour
        IOPMAssertionRelease(_assertionID);
        _assertionID = kIOPMNullAssertionID;
    }];
    
    [_resultTextField setStringValue:@""];
    [_task launch];
    [[self sendButton] setTitle:@"Cancel"];
}


- (void) parsePipeOutput:(NSData *)data
{
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // remove newlines
    output = [[output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    
    if ([output rangeOfString:@"timeout"].location != NSNotFound) {
        output = @"Error: Kodi not responding. Connection timeout";
    }
    
    [_resultTextField setStringValue:output];
}



- (IBAction)openPreferences:(id)sender
{
    [self.preferencesWindowController showWindow:nil];
}


- (IBAction)openDocument:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    openPanel.title = @"Choose a file to stream";
    openPanel.canChooseDirectories = NO;
    openPanel.canCreateDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    
    [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSURL *selection = openPanel.URLs[0];
            [_urlTextField setStringValue:[selection.path stringByResolvingSymlinksInPath]];
        }
    }];
}








#pragma mark - Settings


- (NSString *)settingsTargetIP
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"settingsTargetIP"];
}

- (NSString *)settingsTargetPort
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"settingsTargetPort"];
}

- (NSString *)settingsUsername
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"settingsUsername"];
}


- (NSString *)settingsPassword
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"settingsPassword"];
}





@end
