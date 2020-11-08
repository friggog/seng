#import <Social/Social.h>
#import <sys/utsname.h>
#import "Controllers.h"

#define TWEAK_VERSION @"1.2.1"

static NSString *machineName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@implementation sengBasePrefsListController

- (id)readPreferenceValue:(PSSpecifier *)spec {
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH] ? :[NSDictionary dictionary];
    id val = nil;
    if (! dic[spec.properties[@"key"]]) {
        val = spec.properties[@"default"];
    }
    else {
        val = dic[spec.properties[@"key"]];
    }

    if ([spec.properties[@"negate"] boolValue]) {
        val = [NSNumber numberWithInt:(NSInteger) ! [val boolValue]];
    }
    return val;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {
    [super setPreferenceValue:value specifier:spec];
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary] ? :[NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
    if ([spec.properties[@"negate"] boolValue]) {
        [defaults setObject:[NSNumber numberWithInt:(NSInteger) ! [value boolValue]] forKey:spec.properties[@"key"]];
    }
    else {
        [defaults setObject:value forKey:spec.properties[@"key"]];
    }
    [defaults writeToFile:PREFS_PATH atomically:YES];
    CFStringRef toPost = (__bridge CFStringRef)spec.properties[@"PostNotification"];
    if (toPost) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
    }
}

- (void)viewWillAppear:(BOOL)a {
    [super viewWillAppear:a];
    self.navigationController.navigationBar.tintColor = TINT_COLOUR;
    self.view.tintColor = TINT_COLOUR;
    [UIApplication sharedApplication].keyWindow.tintColor = TINT_COLOUR;
}

- (void)setTitle:(id)arg1 {
    [super setTitle:localisedStringForKey(arg1)];
}

- (id)loadSpecifiersFromPlistName:(NSString *)plist target:(id)target {
    NSArray *specs = [super loadSpecifiersFromPlistName:plist target:target];
    for (PSSpecifier *s in specs) {
        if([s.name isEqualToString:@"hc_CLOSE_QUIT_APP_GROUP"])
            s.name = [NSString stringWithFormat:@"%@/%@",localisedStringForKey(@"hc_CLOSE_APP"),localisedStringForKey(@"hc_QUIT_APP")];
        s.name = localisedStringForKey(s.name);
        [s setProperty:localisedStringForKey([s propertyForKey:@"footerText"]) forKey:@"footerText"];
        NSMutableArray *titleArray = [NSMutableArray array];
        for (id v in s.values) {
            [titleArray addObject:localisedStringForKey(s.titleDictionary[v])];
        }
        [s setValues:s.values titles:titleArray shortTitles:titleArray];
        if ([s propertyForKey:@"ALSectionDescriptors"] != nil) {
            NSArray *sectionDescriptors =  [s propertyForKey:@"ALSectionDescriptors"];
            NSMutableArray *newSectionDescriptors = [NSMutableArray array];
            for (NSDictionary *descriptor in sectionDescriptors) {
                NSMutableDictionary *newDescriptor = [NSMutableDictionary dictionaryWithDictionary:descriptor];
                newDescriptor[@"title"] = localisedStringForKey(descriptor[@"title"]);
                [newSectionDescriptors addObject:newDescriptor];
            }
            [s setProperty:newSectionDescriptors forKey:@"ALSectionDescriptors"];
        }
    }
    return specs;
}

@end

@implementation sengBasePSListItemsController

- (id)readPreferenceValue:(PSSpecifier *)spec {
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH] ? :[NSDictionary dictionary];
    id val = nil;
    if (! dic[spec.properties[@"key"]]) {
        val = spec.properties[@"default"];
    }
    else {
        val = dic[spec.properties[@"key"]];
    }

    if ([spec.properties[@"negate"] boolValue]) {
        val = [NSNumber numberWithInt:(NSInteger) ! [val boolValue]];
    }
    return val;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {
    [super setPreferenceValue:value specifier:spec];
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary] ? :[NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
    if ([spec.properties[@"negate"] boolValue]) {
        [defaults setObject:[NSNumber numberWithInt:(NSInteger) ! [value boolValue]] forKey:spec.properties[@"key"]];
    }
    else {
        [defaults setObject:value forKey:spec.properties[@"key"]];
    }
    [defaults writeToFile:PREFS_PATH atomically:YES];
    CFStringRef toPost = (__bridge CFStringRef)spec.properties[@"PostNotification"];
    if (toPost) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
    }
}

- (void)viewWillAppear:(BOOL)a {
    [super viewWillAppear:a];
    self.navigationController.navigationBar.tintColor = TINT_COLOUR;
    self.view.tintColor = TINT_COLOUR;
    [UIApplication sharedApplication].keyWindow.tintColor = TINT_COLOUR;
}

- (void)setTitle:(id)arg1 {
    [super setTitle:localisedStringForKey(arg1)];
}

- (id)loadSpecifiersFromPlistName:(NSString *)plist target:(id)target {
    NSArray *specs = [super loadSpecifiersFromPlistName:plist target:target];
    for (PSSpecifier *s in specs) {
        s.name = localisedStringForKey(s.name);
        [s setProperty:localisedStringForKey([s propertyForKey:@"footerText"]) forKey:@"footerText"];
        NSMutableArray *titleArray = [NSMutableArray array];
        for (id v in s.values) {
            [titleArray addObject:localisedStringForKey(s.titleDictionary[v])];
        }
        [s setValues:s.values titles:titleArray shortTitles:titleArray];
    }
    return specs;
}

@end

@implementation sengMultiCentrePrefsListController

- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"sengMultiCentrePrefs" target:self] retain];
        BOOL gesture = [[self readPreferenceValue:[self specifierForID:@"gestureAnim"]] boolValue];
        NSMutableArray *a = [_specifiers mutableCopy];
        for (PSSpecifier *s in _specifiers) {
            if ([[s propertyForKey:@"id"] isEqualToString:@"openToCurrent"] && gesture) {
                [s setProperty:[NSNumber numberWithBool:NO] forKey:@"enabled"];
            }
        }
        _specifiers = a;
    }
    return _specifiers;
}

- (void)setGestureAnim:(id)value specifier:(PSSpecifier *)spec {
    [self setPreferenceValue:value specifier:spec];
    BOOL v = [value boolValue];
    PSSwitchTableCell *cell = (PSSwitchTableCell *)[self tableView:[self table] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5]];
    if (v) {
        [self setPreferenceValue:[NSNumber numberWithBool:YES] specifier:[self specifierForID:@"openToCurrent"]];
        [cell setCellEnabled:NO];
        [((UISwitch *)cell.control) setOn:YES animated:YES];
    }
    else {
        [cell setCellEnabled:YES];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSelector:@selector(reloadSpecifiers) withObject:nil afterDelay:0.5];
}

@end

@implementation sengHotCornersPrefsListController

- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"sengHotCornersPrefs" target:self] retain];
        BOOL cornerHome = [[self readPreferenceValue:[self specifierForID:@"leftAction"]] integerValue] == 0 || [[self readPreferenceValue:[self specifierForID:@"rightAction"]] integerValue] == 0 || [[self readPreferenceValue:[self specifierForID:@"leftAction"]] integerValue] == 3 || [[self readPreferenceValue:[self specifierForID:@"rightAction"]] integerValue] == 3;
        BOOL quickSwitcher = [[self readPreferenceValue:[self specifierForID:@"leftAction"]] integerValue] == 1 || [[self readPreferenceValue:[self specifierForID:@"rightAction"]] integerValue] == 1;
        NSMutableArray *a = [_specifiers mutableCopy];
        for (PSSpecifier *spec in _specifiers) {
            BOOL removeForCH = (([[spec propertyForKey:@"id"] isEqualToString:@"goHomeGroup"] || [[spec propertyForKey:@"id"] isEqualToString:@"cornerLock"] || [[spec propertyForKey:@"id"] isEqualToString:@"simpleCornerHome"]) && ! cornerHome) || ([[spec propertyForKey:@"id"] isEqualToString:@"simpleCornerHome"] && IS_IOS_(9,0));
            BOOL removeForQS = ([[spec propertyForKey:@"id"] isEqualToString:@"qsGroup"] || [[spec propertyForKey:@"id"] isEqualToString:@"altQS"]) && ! quickSwitcher;
            if (removeForCH || removeForQS) {
                [a removeObject:spec];
            }
        }
        _specifiers = a;
    }
    return _specifiers;
}

- (void)setCornerAction:(id)value specifier:(PSSpecifier *)spec {
    [self setPreferenceValue:value specifier:spec];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadSpecifiers];
}

@end

@implementation sengPrefsListController

- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"sengPrefs" target:self] retain];
        PSSpecifier *copyright = [self specifierForID:@"footer"];
        NSString *footer = [copyright propertyForKey:@"footerText"];
        footer = [footer stringByReplacingOccurrencesOfString:@"$" withString:[NSString stringWithFormat:@"%@", TWEAK_VERSION]];
        [copyright setProperty:footer forKey:@"footerText"];
        if ([[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.Accessibility.plist"][@"ReduceMotionEnabled"] boolValue]) {
            NSMutableArray *a = [_specifiers mutableCopy];
            PSSpecifier *s = [PSSpecifier groupSpecifierWithName:localisedStringForKey(@"rm_TITLE")];
            [s setProperty:localisedStringForKey(@"rm_FOOTER") forKey:@"footerText"];
            [a insertObject:s atIndex:7];
            _specifiers = a;
        }
    }
    return _specifiers;
}

- (void)loadView {
    [super loadView];
    UIImageView *barView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    barView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/sengPrefs.bundle/sengBar.png"];
    self.navigationItem.titleView = barView;
    [barView release];
    UIBarButtonItem *likeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/sengPrefs.bundle/heart.png"] style:UIBarButtonItemStylePlain target:self action:@selector(composeTweet)];
    ((UINavigationItem *)self.navigationItem).rightBarButtonItem = likeButton;
    [likeButton release];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.tintColor = nil;
    [UIApplication sharedApplication].keyWindow.tintColor = nil;
}

- (void)composeTweet {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:localisedStringForKey(@"TWITTER_MESSAGE")];
        UIViewController *rootViewController = (UIViewController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:tweetSheet animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localisedStringForKey(@"al_ERROR") message:localisedStringForKey(@"al_TWEET_ERROR") delegate:self cancelButtonTitle:localisedStringForKey(@"al_OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

@end

@implementation sengPrefsOtherController

- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"sengOtherPrefs" target:self];
        BOOL quitAll = [[self readPreferenceValue:[self specifierForID:@"hsDismissType"]] integerValue] <= 1;
        NSMutableArray *a = [_specifiers mutableCopy];
        for (PSSpecifier *s in _specifiers) {
            if ((([[s propertyForKey:@"id"] isEqualToString:@"swipeToSwitchGroup"] || [[s propertyForKey:@"id"] isEqualToString:@"swipeToSwitchApp"] || [[s propertyForKey:@"id"] isEqualToString:@"forceToSwitchApp"] || [[s propertyForKey:@"id"] isEqualToString:@"swipeToSwitchAppZone"]) && !IS_IOS_(9,0)) || (([[s propertyForKey:@"id"] isEqualToString:@"quitAllGroup"] || [[s propertyForKey:@"id"] isEqualToString:@"whitelist"] || [[s propertyForKey:@"id"] isEqualToString:@"closeNowPlaying"] || [[s propertyForKey:@"id"] isEqualToString:@"dismissAfterQuitAll"]) && ! quitAll)) {
                [a removeObject:s];
            }
        }
        _specifiers = a;
    }
    return _specifiers;
}

- (void)setHSSwipeUpAction:(id)value specifier:(PSSpecifier *)spec {
    [self setPreferenceValue:value specifier:spec];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadSpecifiers];
}

@end

@implementation sengPrefsSupportController

- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"sengSupportPrefs" target:self] retain];
    }
    return _specifiers;
}

- (void)composeMail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:[NSString stringWithFormat:@"Seng %@ - %@ : %@", TWEAK_VERSION, machineName(), [[UIDevice currentDevice] systemVersion]]];

        NSArray *toRecipients = [NSArray arrayWithObject:@"contact@chewitt.me"];
        [picker setToRecipients:toRecipients];

        UIViewController *rootViewController = (UIViewController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:picker animated:YES completion:NULL];
        [picker release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localisedStringForKey(@"al_ERROR")
                              message:localisedStringForKey(@"al_EMAIL_ERROR")
                              delegate:self
                              cancelButtonTitle:localisedStringForKey(@"al_OK")
                              otherButtonTitles:nil
                              , nil];
        [alert show];
        [alert release];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end

@implementation sengSectionLayoutSpecificDetailPrefsListController

- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:_plistName target:self] retain];
        for (PSSpecifier *s in _specifiers) {
            if ([[s propertyForKey:@"key"] rangeOfString:@"_"].location == NSNotFound && _keyPrefix != nil && [s propertyForKey:@"key"] != nil) {
                [s setProperty:[NSString stringWithFormat:@"%@_%@", _keyPrefix, [s propertyForKey:@"key"]] forKey:@"key"];
            }
        }
    }
    return _specifiers;
}

- (void)updateKeysForPrefix:(NSString *)k {
    _keyPrefix = k;
}

- (void)setHideMedia:(id)val specifier:(PSSpecifier *)spec {
    [self setPreferenceValue:val specifier:spec];
    [self setPreferenceValue:@NO specifier:[self specifierForID:@"hwp"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadSpecifier:[self specifierForID:@"hwp"]];
}

- (void)setHideMediaP:(id)val specifier:(PSSpecifier *)spec {
    [self setPreferenceValue:val specifier:spec];
    [self setPreferenceValue:@NO specifier:[self specifierForID:@"sowp"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadSpecifier:[self specifierForID:@"sowp"]];
}

@end

@implementation sengMediaTitlesPrefsListController
- (id)specifiers {
    _plistName = @"sengMediaTitlesPrefs";
    return [super specifiers];
}

@end

@implementation sengMediaButtonsPrefsListController
- (id)specifiers {
    _plistName = @"sengMediaButtonsPrefs";
    return [super specifiers];
}

@end

@implementation sengMediaScrubberPrefsListController
- (id)specifiers {
    _plistName = @"sengMediaScrubberPrefs";
    return [super specifiers];
}

@end

@implementation sengMediaPrefsListController
- (id)specifiers {
    _plistName = @"sengMediaPrefs";
    return [super specifiers];
}

@end

@implementation sengAirStuffPrefsListController
- (id)specifiers {
    _plistName = @"sengAirStuffPrefs";
    return [super specifiers];
}

@end

@implementation sengPeopleViewPrefsListController
- (id)specifiers {
    _plistName = @"sengPeopleViewPrefs";
    return [super specifiers];
}

@end

@implementation sengBannerCell

- (id)initWithStyle:(NSInteger)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:arg2 specifier:arg3];
    if (self) {
        CGRect frame = [self frame];
        frame.size.height = 130;

        self.backgroundColor = TINT_COLOUR;

        UIView *containerView = [[UIView alloc] initWithFrame:frame];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        containerView.clipsToBounds = YES;

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, frame.size.width, 65)];
        label.text = @"seng";
        label.numberOfLines = 1;
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:55]];

        UILabel *subLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, frame.size.width, 20)];
        subLabel.text = @"by charlie hewitt";
        subLabel.numberOfLines = 1;
        subLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        subLabel.backgroundColor = [UIColor clearColor];
        subLabel.textColor = [UIColor whiteColor];
        subLabel.textAlignment = NSTextAlignmentCenter;
        subLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [subLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];

        [containerView addSubview:label];
        [containerView addSubview:subLabel];
        [label release];
        [subLabel release];

        [self.contentView addSubview:containerView];

        [containerView release];
    }
    return self;
}

@end

@implementation sengSwitchCell

- (id)initWithStyle:(NSInteger)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    if (self) {
        [((UISwitch *)[self control]) setOnTintColor:TINT_COLOUR];
    }
    return self;
}

@end

@implementation sengIconCell

- (id)initWithStyle:(NSInteger)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    if (self) {
        self.iconImageView.tintColor = TINT_COLOUR;
    }
    return self;
}

- (void)setIcon:(id)icon {
    UIImage *o = icon;
    o = [o imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [super setIcon:o];
}

@end

@implementation sengTopSectionIconCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconImageView.frame = CGRectMake(self.iconImageView.frame.origin.x, 1, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
}

@end

@implementation sengButtonCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleTextLabel.textColor = TINT_COLOUR;
}

@end
