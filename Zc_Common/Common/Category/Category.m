//

#import "Category.h"

@implementation UIViewController (ViewControllerEx)

#pragma mark alertcontroller methods
- (UIAlertController *)alertWithTitle:(NSString *)title {
    return [self alertWithTitle:title cancelTitle:@"确定" cancelHandler:nil];
}

- (UIAlertController *)alertWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle cancelHandler:(void (^)(UIAlertAction *action))cancelHandler {
    return [self alertWithTitle:title cancelTitle:cancelTitle cancelHandler:cancelHandler otherTitle:nil otherHandler:nil];
}

- (UIAlertController *)alertWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle cancelHandler:(void (^)(UIAlertAction *action))cancelHandler otherTitle:(NSString *)otherTitle otherHandler:(void (^)(UIAlertAction *action))otherHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelHandler]];
    if (otherTitle) {
        [alertController addAction:[UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleCancel handler:otherHandler]];
    }
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

#pragma mark navigationcontroller methods
- (UINavigationController *)presentNavigationController:(UIViewController *)controller animated:(BOOL)animated
{
    UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:controller];
    navigator.modalTransitionStyle = controller.modalTransitionStyle;
    navigator.modalPresentationStyle = controller.modalPresentationStyle;
    
    [self presentViewController:navigator animated:YES completion:nil];
    return navigator;
}

//
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(dismissModalViewController)];
    controller.navigationItem.leftBarButtonItem = doneButton;
    
    return [self presentNavigationController:controller animated:animated];
}

//
- (void)dismissModalViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
