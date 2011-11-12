// optional, implemented by the app delegate
@protocol KBWindowDataSource <NSObject>
@required
- (NSSet *) windowsToIgnore;
@end

@interface KBViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, retain) IBOutlet UITextField *textField;
@end
