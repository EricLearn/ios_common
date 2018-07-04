//
//  Category.h

#import <UIKit/UIKit.h>

@interface UIViewController (ViewControllerEx)

// Alert
- (UIAlertController *)alertWithTitle:(NSString *)title;
- (UIAlertController *)alertWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle cancelHandler:(void (^)(UIAlertAction *action))cancelHandler;
- (UIAlertController *)alertWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle cancelHandler:(void (^)(UIAlertAction *action))cancelHandler otherTitle:(NSString *)otherTitle otherHandler:(void (^)(UIAlertAction *action))otherHandler;

// navigation
- (void)dismissModalViewController;
- (UINavigationController *)presentNavigationController:(UIViewController *)controller animated:(BOOL)animated;
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated;

@end
