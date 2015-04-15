
@interface SendStreamAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *_window;
    NSWindowController *_preferencesWindowController;
    
    NSTextField *_urlTextField;
    NSTextField *_resultTextField;
    NSButton *_sendButton;
    
    NSTask *_task;
}

@property (nonatomic, assign) IBOutlet NSWindow *window;
@property (nonatomic, readonly) NSWindowController *preferencesWindowController;

@property (nonatomic, assign) IBOutlet NSTask *task;

// UI
@property (nonatomic, assign) IBOutlet NSTextField *urlTextField;
@property (nonatomic, assign) IBOutlet NSTextField *resultTextField;
@property (nonatomic, assign) IBOutlet NSButton *sendButton;

// Preferences
@property (nonatomic, assign) NSString* settingsTargetIP;
@property (nonatomic, assign) NSString* settingsTargetPort;
@property (nonatomic, assign) NSString* settingsUsername;
@property (nonatomic, assign) NSString* settingsPassword;


// Actions
- (IBAction)openPreferences:(id)sender;
- (IBAction)runCommand:(id)sender;

@end
