#import "KBViewController.h"

@interface KBViewController ()
@property (nonatomic) CGSize keyboardSize;
@end

@interface KBViewController (Private)
- (UIWindow *) _keyboardWindow;
@end

@implementation KBViewController
@synthesize textField;
@synthesize keyboardSize;

#pragma mark -

- (void) viewDidLoad {
	[super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanned:)];

	[self.view addGestureRecognizer:panGestureRecognizer];

	[panGestureRecognizer release];
}

#pragma mark -

- (void) keyboardWillShow:(NSNotification *) notification {
	CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	keyboardSize = keyboardRect.size;

	[UIView animateWithDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
		CGRect frame = textField.frame;
		frame.origin.y = keyboardRect.size.height;
		textField.frame = frame;
	}];
}

- (void) keyboardWillHide:(NSNotification *) notification {
	[UIView animateWithDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
		CGRect frame = textField.frame;
		frame.origin.y = self.view.frame.size.height - textField.frame.size.height;
		textField.frame = frame;
	}];
}

#pragma mark -

- (void) viewPanned:(UIPanGestureRecognizer *) gestureRecognizer {
	CGPoint locationInView = [gestureRecognizer locationInView:self.view];
	CGPoint currentVelocity = [gestureRecognizer velocityInView:self.view];

	if (![textField isFirstResponder]) {
		if (CGRectContainsPoint(textField.frame, locationInView)) {
			if (currentVelocity.y < 0) {
				[textField becomeFirstResponder];
			}
		}
		
		return;
	}

	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		if (currentVelocity.y > 0) {
			BOOL areAnimationsEnabled = [UIView areAnimationsEnabled];
			[UIView setAnimationsEnabled:NO];
			[textField resignFirstResponder];
			[UIView setAnimationsEnabled:areAnimationsEnabled];
			
			[self performSelector:@selector(_fixKeyboardBounds) withObject:nil afterDelay:.26];
			
			return;
		} else {
			[UIView animateWithDuration:.25 animations:^{
				CGRect frame = textField.frame;
				frame.origin.y -= abs([self _keyboardWindow].frame.origin.y);
				textField.frame = frame;
				
				[self _keyboardWindow].frame = [UIScreen mainScreen].bounds;
			}];
			
			return;
		}
	}

	if (keyboardSize.height > locationInView.y)
		return;

	if (((textField.frame.origin.y + textField.frame.size.height) > self.view.frame.size.height) && currentVelocity.y > 0.)
		return;

	CGFloat spaceAboveKeyboard = self.view.bounds.size.height - (keyboardSize.height + textField.frame.size.height);
	CGFloat distanceMoved = 0.;

	UIWindow *keyboardWindow = [self _keyboardWindow];

	CGRect frame = keyboardWindow.frame;
	frame.origin.y = fabs((spaceAboveKeyboard - locationInView.y));
	distanceMoved = frame.origin.y - keyboardWindow.frame.origin.y;
	keyboardWindow.frame = frame;

	frame = textField.frame;
	frame.origin.y += distanceMoved;
	textField.frame = frame;
}

#pragma mark -

- (UIWindow *) _keyboardWindow {
	NSMutableSet *windowsThatAreNotTheKeyboardWindow = [NSMutableSet set];
	id delegate = [UIApplication sharedApplication].delegate;

	if ([delegate conformsToProtocol:@protocol(KBWindowDataSource)])
		[windowsThatAreNotTheKeyboardWindow unionSet:[delegate windowsToIgnore]];

	[windowsThatAreNotTheKeyboardWindow addObject:[UIApplication sharedApplication].delegate.window];

	NSMutableSet *potentiallyTheKeyboardWindow = [NSMutableSet setWithArray:[UIApplication sharedApplication].windows];

	for (UIWindow *window in potentiallyTheKeyboardWindow) {
		if (window.windowLevel == UIWindowLevelNormal || window.windowLevel == UIWindowLevelStatusBar || window.windowLevel == UIWindowLevelAlert) // this won't actually match UIAlertView's window's windowLevel, but, doesn't hurt to check anyway
			[windowsThatAreNotTheKeyboardWindow addObject:window];
	}

	[potentiallyTheKeyboardWindow minusSet:windowsThatAreNotTheKeyboardWindow];

	return [potentiallyTheKeyboardWindow anyObject];
}

- (void) _fixKeyboardBounds {
	[self _keyboardWindow].frame = [UIScreen mainScreen].bounds;
}
@end
