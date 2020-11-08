#import <MessageUI/MessageUI.h>
#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>

#define TINT_COLOUR [UIColor colorWithRed:52.0/255.0 green:73.0/255.0 blue:94.0/255 alpha:1]
#define PREFS_PATH @"/User/Library/Preferences/me.chewitt.seng.plist"
#define PREFS_PATH_MANUAL @"/User/Library/Preferences/me.chewitt.seng.manual.plist"

static inline NSString *localisedStringForKey(NSString *key) {
    return [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/sengPrefs.bundle"] localizedStringForKey:key value:key table:nil];
}

@interface sengPrefsOrganisationController:PSViewController <UITableViewDataSource, UITableViewDelegate> {
    NSString *enabledKey;
    NSMutableArray *enabledIdentifiers;
    NSString *disabledKey;
    NSMutableArray *disabledIdentifiers;
    NSMutableDictionary *ccLoaderBundles;
    NSMutableArray *allIdentifiers;
}
- (UIImage *)settinsCellIconForSectionIdentifier:(NSString *)identifier;
- (Class)settingsViewControllerClassForSectionIdentifier:(NSString *)identifier;
@end

@interface sengPrefsScrollViewController:PSViewController <UITableViewDataSource, UITableViewDelegate> {
    NSString *enabledKey;
    NSMutableArray *enabledIdentifiers;
    NSString *disabledKey;
    NSMutableArray *disabledIdentifiers;
    NSMutableArray *allIdentifiers;
    NSMutableDictionary *ccLoaderBundles;
    NSString *keyPrefix;
    NSString *sizeKey;
    NSArray *defEnabled;
    NSArray *defDisabled;
}
- (UIImage *)settinsCellIconForSectionIdentifier:(NSString *)identifier;
@end

@interface sengPrefsBigScrollViewController:sengPrefsScrollViewController
@end

@interface sengPrefsSmallScrollViewController:sengPrefsScrollViewController
@end

@interface sengBasePrefsListController:PSListController
@end

@interface sengPrefsListController:sengBasePrefsListController
@end

@interface sengPrefsSupportController:sengBasePrefsListController <MFMailComposeViewControllerDelegate>
@end

@interface sengMultiCentrePrefsListController:sengBasePrefsListController
@end

@interface sengHotCornersPrefsListController:sengBasePrefsListController
@end

@interface sengPrefsOtherController:sengBasePrefsListController {}
@end
@interface sengSectionLayoutSpecificDetailPrefsListController:sengBasePrefsListController {
    NSString *_keyPrefix;
    NSString *_plistName;
}
- (void)updateKeysForPrefix:(NSString *)k;
@end

@interface sengMediaTitlesPrefsListController:sengSectionLayoutSpecificDetailPrefsListController
@end

@interface sengMediaButtonsPrefsListController:sengSectionLayoutSpecificDetailPrefsListController
@end

@interface sengMediaScrubberPrefsListController:sengSectionLayoutSpecificDetailPrefsListController
@end

@interface sengMediaPrefsListController:sengSectionLayoutSpecificDetailPrefsListController
@end

@interface sengAirStuffPrefsListController:sengSectionLayoutSpecificDetailPrefsListController
@end

@interface sengPeopleViewPrefsListController:sengSectionLayoutSpecificDetailPrefsListController
@end

@interface sengBannerCell:PSTableCell
@end

@interface sengSwitchCell:PSSwitchTableCell
@end

@interface sengIconCell:PSTableCell
@end

@interface sengTopSectionIconCell:sengIconCell
@end

@interface sengBasePSListItemsController:PSListItemsController
@end

@interface sengButtonCell:PSTableCell
@end
