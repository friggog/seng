#import "CCBundleLoader.h"
#import "Controllers.h"
#import "cellTitleForSectionName.h"

@implementation sengPrefsOrganisationController

-(void) dealloc {
    [enabledIdentifiers release];
    [disabledIdentifiers release];
    [enabledKey release];
    [disabledKey release];
    [ccLoaderBundles release];
    [super dealloc];
}

-(void) loadView {
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 50;
    tableView.allowsSelectionDuringEditing = YES;
    [tableView setEditing:YES animated:NO];
    self.view = tableView;
    [tableView release];
}

-(void) viewWillAppear:(BOOL)a {
    [super viewWillAppear:a];
    self.navigationController.navigationBar.tintColor = TINT_COLOUR;
    self.view.tintColor = TINT_COLOUR;
    [UIApplication sharedApplication].keyWindow.tintColor = TINT_COLOUR;
}

-(void) setSpecifier:(PSSpecifier*)specifier {
    [super setSpecifier:specifier];
    self.navigationItem.title = [specifier name];
    [enabledKey release];
    enabledKey = [[specifier propertyForKey:@"sengEnabledKey"] copy];
    [disabledKey release];
    disabledKey = [[specifier propertyForKey:@"sengDisabledKey"] copy];
    NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH_MANUAL];

    NSArray* originalEnabled = [settings objectForKey:enabledKey] ? :[specifier propertyForKey:@"sengDefaultEnabled"] ? :[NSArray array];
    [enabledIdentifiers release];
    enabledIdentifiers = [originalEnabled mutableCopy];
    NSArray* originalDisabled = [settings objectForKey:disabledKey] ? :[specifier propertyForKey:@"sengDefaultDisabled"] ? :[NSArray array];
    [disabledIdentifiers release];
    disabledIdentifiers = [originalDisabled mutableCopy];
    allIdentifiers = IS_IOS_(9,0) ?
        [NSMutableArray arrayWithObjects:@"com.apple.controlcenter.air-stuff", @"me.chewitt.seng.volume", @"com.apple.controlcenter.brightness", @"me.chewitt.seng.small-scroll", @"me.chewitt.seng.big-scroll", @"com.apple.controlcenter.media-controls", @"com.apple.controlcenter.settings", @"com.apple.controlcenter.quick-launch", @"me.chewitt.seng.media-titles", @"me.chewitt.seng.media-scrubber", @"me.chewitt.seng.media-buttons", nil] :
        [NSMutableArray arrayWithObjects:@"me.chewitt.seng.people", @"com.apple.controlcenter.air-stuff", @"me.chewitt.seng.volume", @"com.apple.controlcenter.brightness", @"me.chewitt.seng.small-scroll", @"me.chewitt.seng.big-scroll", @"com.apple.controlcenter.media-controls", @"com.apple.controlcenter.settings", @"com.apple.controlcenter.quick-launch", @"me.chewitt.seng.media-titles", @"me.chewitt.seng.media-scrubber", @"me.chewitt.seng.media-buttons", nil];
    [ccLoaderBundles release];
    ccLoaderBundles = [[NSMutableDictionary alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/de.j-gessner.ccloader.list"]) {
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/CCLoader/Bundles" error:nil];
        for (NSString* file in contents) {
            if ([file.pathExtension isEqualToString:@"bundle"]) {
                NSString* path = [@"/Library/CCLoader/Bundles" stringByAppendingPathComponent:file];
                NSBundle* bundle = [NSBundle bundleWithPath:path];
                NSString* ID = bundle.bundleIdentifier;
                NSString* displayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                [ccLoaderBundles setValue:displayName forKey:ID];
                [allIdentifiers addObject:ID];
                [bundle unload];
            }
        }
    }

    for (NSString* identifier in originalEnabled) {
        if ([allIdentifiers containsObject:identifier]) {
            [allIdentifiers removeObject:identifier];
            [disabledIdentifiers removeObject:identifier];
        }
        else {
            [enabledIdentifiers removeObject:identifier];
        }
    }
    for (NSString* identifier in originalDisabled) {
        if ([allIdentifiers containsObject:identifier]) {
            [allIdentifiers removeObject:identifier];
        }
        else {
            [disabledIdentifiers removeObject:identifier];
        }
    }

    NSMutableArray* arrayToAddNewIdentifiers = disabledIdentifiers;
    for (NSString* identifier in allIdentifiers) {
        [arrayToAddNewIdentifiers addObject:identifier];
    }

    if ([self isViewLoaded]) {
        [(UITableView*)self.view setRowHeight:50];
        [(UITableView*)self.view setEditing:YES animated:NO];
        [(UITableView*)self.view reloadData];
    }
}

-(void) _flushSettings {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PATH_MANUAL] ? :[NSMutableDictionary dictionary];
    if (enabledKey) {
        [dict setObject:enabledIdentifiers forKey:enabledKey];
    }
    if (disabledKey) {
        [dict setObject:disabledIdentifiers forKey:disabledKey];
    }
    [dict writeToFile:PREFS_PATH_MANUAL atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"me.chewitt.seng.prefsChanged", NULL, NULL, YES);
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)table {
    return 2;
}

-(NSString*) tableView:(UITableView*)table titleForHeaderInSection:(NSInteger)section {
    return section ? localisedStringForKey(@"mc_EXCLUDED_SECTIONS"):localisedStringForKey(@"mc_INCLUDED_SECTIONS");
}

-(NSString*) tableView:(UITableView*)table titleForFooterInSection:(NSInteger)section {
    return @" ";
}

-(NSArray*) arrayForSection:(NSInteger)section {
    return section ? disabledIdentifiers:enabledIdentifiers;
}

-(NSInteger) tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)section {
    return [[self arrayForSection:section] count];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"] ? :[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    NSString* identifier = [[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text =   [ccLoaderBundles valueForKey:identifier] != nil ? [ccLoaderBundles valueForKey:identifier] : cellTitleForSectionName(identifier);
    cell.imageView.image = [self settinsCellIconForSectionIdentifier:identifier];
    Class _class = [self settingsViewControllerClassForSectionIdentifier:identifier];
    cell.editingAccessoryType = _class ? UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    cell.selectionStyle = _class ? UITableViewCellSelectionStyleBlue:UITableViewCellSelectionStyleNone;
    return cell;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* identifier = [[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];
    PSListController* controller = [[[self settingsViewControllerClassForSectionIdentifier:identifier] alloc] init];
    if (controller) {
        [self.navigationController pushViewController:controller animated:YES];
        BOOL bigScroll = [controller isKindOfClass:[sengPrefsBigScrollViewController class]];
        BOOL smallScroll = [controller isKindOfClass:[sengPrefsSmallScrollViewController class]];
        if ([controller isKindOfClass:[sengSectionLayoutSpecificDetailPrefsListController class]] || bigScroll || smallScroll) {
            [(sengSectionLayoutSpecificDetailPrefsListController*)controller updateKeysForPrefix:[self.specifier propertyForKey:@"key"]];
        }
        if (bigScroll) {
            PSSpecifier* spec = [PSSpecifier groupSpecifierWithName:@"Big Scroll View"];
            [controller setSpecifier:spec];
        }
        else if (smallScroll) {
            PSSpecifier* spec = [PSSpecifier groupSpecifierWithName:@"Small Scroll View"];
            [controller setSpecifier:spec];
        }
        [controller release];
    }
}

-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    return UITableViewCellEditingStyleNone;
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath {
    return NO;
}

-(void) tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath {
    NSMutableArray* fromArray = fromIndexPath.section ? disabledIdentifiers:enabledIdentifiers;
    NSMutableArray* toArray = toIndexPath.section ? disabledIdentifiers:enabledIdentifiers;
    NSString* identifier = [[fromArray objectAtIndex:fromIndexPath.row] retain];
    [fromArray removeObjectAtIndex:fromIndexPath.row];
    [toArray insertObject:identifier atIndex:toIndexPath.row];
    [identifier release];
    [self _flushSettings];
}

-(id) table {
    return nil;
}

-(UIImage*) settinsCellIconForSectionIdentifier:(NSString*)identifier {
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/sengPrefs.bundle/SectionIcons/%@.png", identifier]];
}

-(Class) settingsViewControllerClassForSectionIdentifier:(NSString*)identifier {
    if ([identifier isEqualToString:@"me.chewitt.seng.small-scroll"]) {
        return [sengPrefsSmallScrollViewController class];
    }
    else if ([identifier isEqualToString:@"me.chewitt.seng.big-scroll"]) {
        return [sengPrefsBigScrollViewController class];
    }
    else if ([identifier isEqualToString:@"me.chewitt.seng.media-titles"]) {
        return [sengMediaTitlesPrefsListController class];
    }
    else if ([identifier isEqualToString:@"me.chewitt.seng.media-buttons"]) {
        return [sengMediaButtonsPrefsListController class];
    }
    else if ([identifier isEqualToString:@"me.chewitt.seng.media-scrubber"]) {
        return [sengMediaScrubberPrefsListController class];
    }
    else if ([identifier isEqualToString:@"com.apple.controlcenter.media-controls"]) {
        return [sengMediaPrefsListController class];
    }
    else if ([identifier isEqualToString:@"com.apple.controlcenter.air-stuff"]) {
        return [sengAirStuffPrefsListController class];
    }
    else if ([identifier isEqualToString:@"me.chewitt.seng.people"]) {
        return [sengPeopleViewPrefsListController class];
    }
    return nil;
}

@end
