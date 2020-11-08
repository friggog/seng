#import "SharedDefs.h"

%subclass sengSBAlertItemActionSheet : SBAlertItem

- (void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)require {
    NSString *title = localisedStringForKey(@"tw_ACTION_MENU");
    id alertView = [self alertSheet];
    [alertView setDelegate:self];
    [alertView setTitle:title];
    [alertView addButtonWithTitle:localisedStringForKey(@"tw_SHUT_DOWN")];
    [alertView addButtonWithTitle:localisedStringForKey(@"tw_REBOOT")];
    [alertView addButtonWithTitle:localisedStringForKey(@"tw_SAFE_MODE")];
    [alertView addButtonWithTitle:localisedStringForKey(@"tw_RESPRING")];
    [alertView addButtonWithTitle:localisedStringForKey(@"tw_QUIT_ALL")];
    [alertView addButtonWithTitle:localisedStringForKey(@"tw_LOCK")];
    [alertView addButtonWithTitle:localisedStringForKey(@"tw_CANCEL")];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [[%c(SBBacklightController) sharedInstance] animateBacklightToFactor:0 duration:0.1 source:1 completion:^(BOOL complete) {
                [(SpringBoard *)[UIApplication sharedApplication] powerDown];
            }];
        }
        break;

        case 1: {
            [[%c(SBBacklightController) sharedInstance] animateBacklightToFactor:0 duration:0.1 source:1 completion:^(BOOL complete) {
                [(SpringBoard *)[UIApplication sharedApplication] reboot];
            }];
        }
        break;

        case 2: {
            FILE *tmp = fopen("/var/mobile/Library/Preferences/com.saurik.mobilesubstrate.dat", "w");
            fclose(tmp);
            [[%c(SBBacklightController) sharedInstance] animateBacklightToFactor:0 duration:0.1 source:1 completion:^(BOOL complete) {
                [(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard];
            }];
        }
        break;

        case 3: {
            [[%c(SBBacklightController) sharedInstance] animateBacklightToFactor:0 duration:0.1 source:1 completion:^(BOOL complete) {
                [(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard];
            }];
        }
        break;

        case 4: {
            [versionCorrectSwitcherController() quitAllApps];
        }
        break;

        case 5: {
            [[%c(SBBacklightController) sharedInstance] animateBacklightToFactor:0 duration:0.2 source:1 completion:^(BOOL complete) {
                [[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];
            }];
        }
        break;

        default: {
            [versionCorrectSwitcherController() resetHomeScrollViewPositionAndForceStayOpen:YES];
        }
    }
    [self dismiss];
}

- (BOOL)shouldShowInLockScreen {
    return NO;
}

- (BOOL)dismissOnLock {
    return YES;
}

%end

%subclass sengSBAlertItemPiracy : SBAlertItem

- (void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)require {
    NSString *title = @"Ahoy there!";
    NSString *body = @"It seems that you have installed seng without purchasing.\nThe tweak will function as usual in order for you to test it out, but please consider purchasing to show your support.";
    id alertView = [self alertSheet];
    [alertView setDelegate:self];
    [alertView setTitle:title];
    [alertView setMessage:body];
    [alertView addButtonWithTitle:@"OK"];
}

- (BOOL)shouldShowInLockScreen {
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismiss];
}

%end

%subclass sengSBAlertItemIOS9 : SBAlertItem

- (void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)require {
    NSString *title = @"Seng on iOS 9";
    NSString *body = @"Apple has changed a RIDICULOUS amount of stuff regarding the SpringBoard and the app switcher.\nIt will take a RIDICULOUS amount of work to update seng - this probably isnt going to happen for a while if at all.";
    id alertView = [self alertSheet];
    [alertView setDelegate:self];
    [alertView setTitle:title];
    [alertView setMessage:body];
    [alertView addButtonWithTitle:@"OK"];
}

%end
