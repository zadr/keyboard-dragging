#import "KBAppDelegate.h"

#import "KBViewController.h"

@implementation KBAppDelegate
@synthesize window;

- (void)dealloc {
	[window release];

    [super dealloc];
}

- (BOOL) application:(UIApplication *) application didFinishLaunchingWithOptions:(NSDictionary *) launchOptions {
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

	window.rootViewController = [[[KBViewController alloc] initWithNibName:@"KBViewController" bundle:nil] autorelease];

    [window makeKeyAndVisible];

	return YES;
}
@end
