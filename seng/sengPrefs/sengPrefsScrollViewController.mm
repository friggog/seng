#import "Controllers.h"
#import "cellTitleForSectionName.h"

@implementation sengPrefsScrollViewController

-(void) dealloc {
    [enabledIdentifiers release];
    [disabledIdentifiers release];
    [enabledKey release];
    [disabledKey release];
    [keyPrefix release];
    [super dealloc];
}

-(void) loadView {
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 44;
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
    enabledKey = [[NSString stringWithFormat:@"%@_%@ScrollEnabledSections", keyPrefix, sizeKey] copy];
    disabledKey =  [[NSString stringWithFormat:@"%@_%@ScrollDisabledSections", keyPrefix, sizeKey] copy];
    NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH_MANUAL];

    NSArray* originalEnabled = [settings objectForKey:enabledKey] ? :defEnabled ? :[NSArray array];
    [enabledIdentifiers release];
    enabledIdentifiers = [originalEnabled mutableCopy];
    NSArray* originalDisabled = [settings objectForKey:disabledKey] ? :defDisabled ? :[NSArray array];
    [disabledIdentifiers release];
    disabledIdentifiers = [originalDisabled mutableCopy];

    //allIdentifiers = [NSMutableArray arrayWithObjects:@"com.apple.controlcenter.settings", @"com.apple.controlcenter.quick-launch", @"com.apple.controlcenter.air-stuff", nil];

    [ccLoaderBundles release];
    ccLoaderBundles = [[NSMutableDictionary alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/de.j-gessner.ccloader.list"] && [self isKindOfClass:[sengPrefsBigScrollViewController class]]) {
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
        [(UITableView*)self.view setRowHeight:44];
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
    return 3;
}

-(NSString*) tableView:(UITableView*)table titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return localisedStringForKey(@"sv_SCROLLING_STYLE");
            break;

        case 1:
            return localisedStringForKey(@"sv_INCLUDED_SECTIONS");
            break;

        default:
            return localisedStringForKey(@"sv_EXCLUDED_SECTIONS");
            break;
    }
}

-(NSString*) tableView:(UITableView*)table titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return localisedStringForKey(@"sv_RESET_TO_FIRST_FOOTER");
    }
    else {
        return @" ";
    }
}

-(NSArray*) arrayForSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            break;

        case 1:
            return enabledIdentifiers;
            break;

        default:
            return disabledIdentifiers;
            break;
    }
}

-(NSInteger) tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return [[self arrayForSection:section] count];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            PSSegmentTableCell* cell = [[PSSegmentTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PSSegmentTableCell" specifier:nil];
            UISegmentedControl* segC = (UISegmentedControl*)cell.control;
            [segC removeAllSegments];
            [segC insertSegmentWithTitle:localisedStringForKey(@"sv_HORIZONTAL") atIndex:0 animated:NO];
            [segC insertSegmentWithTitle:localisedStringForKey(@"sv_VERTICAL") atIndex:1 animated:NO];
            [segC addTarget:self action:@selector(setScrollStyle:) forControlEvents:UIControlEventValueChanged];
            segC.selectedSegmentIndex = [[self getPreferenceValueForKey:@"ScrollDirection"] integerValue];
            return (UITableViewCell*)cell;
        }
        else {
            PSSwitchTableCell* cell = [[PSSwitchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PSSegmentTableCell" specifier:nil];
            [cell setTitle:localisedStringForKey(@"sv_RESETS_TO_FIRST")];
            UISwitch* swiC = (UISwitch*)cell.control;
            [swiC addTarget:self action:@selector(setResetsToFirst:) forControlEvents:UIControlEventValueChanged];
            swiC.on = [[self getPreferenceValueForKey:@"ScrollResetsToFirst"] boolValue];
            return (UITableViewCell*)cell;
        }
    }
    else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"] ? :[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        NSString* identifier = [[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];
        cell.textLabel.text =   [ccLoaderBundles valueForKey:identifier] != nil ? [ccLoaderBundles valueForKey:identifier] : cellTitleForSectionName(identifier);
        cell.imageView.image = [self settinsCellIconForSectionIdentifier:identifier];
        return cell;
    }
}

-(id) getPreferenceValueForKey:(NSString*)key {
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH_MANUAL];
    return [dic valueForKey:[NSString stringWithFormat:@"%@_%@%@", keyPrefix, sizeKey, key]];
}

-(void) setResetsToFirst:(UISwitch*)c {
    [self setPreferenceValue:[NSNumber numberWithBool:c.on] forKey:@"ScrollResetsToFirst"];
}

-(void) setScrollStyle:(UISegmentedControl*)c {
    [self setPreferenceValue:[NSNumber numberWithInt:c.selectedSegmentIndex] forKey:@"ScrollDirection"];
}

-(void) setPreferenceValue:(id)v forKey:(NSString*)key {
    NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH_MANUAL]];
    [defaults setObject:v forKey:[NSString stringWithFormat:@"%@_%@%@", keyPrefix, sizeKey, key]];
    [defaults writeToFile:PREFS_PATH_MANUAL atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"me.chewitt.seng.prefsChanged", NULL, NULL, YES);
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*if(indexPath.section > 0){
        NSString* identifier = [[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];
        PSListController* controller = [[[self settingsViewControllerClassForSectionIdentifier:identifier] alloc] init];
        if (controller) {
            [self.navigationController pushViewController:controller animated:YES];
            if ([controller isKindOfClass:[sengSectionLayoutSpecificDetailPrefsListController class]]) {
                [(sengSectionLayoutSpecificDetailPrefsListController*)controller updateKeysForPrefix:[self.specifier propertyForKey:@"key"]];
            }
            [controller release];
        }
       }*/
}

-(UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    return UITableViewCellEditingStyleNone;
}

-(BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath {
    return NO;
}

-(void) tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath {
    NSMutableArray* fromArray = fromIndexPath.section == 2 ? disabledIdentifiers:enabledIdentifiers;
    NSMutableArray* toArray = toIndexPath.section == 2 ? disabledIdentifiers:enabledIdentifiers;
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

-(BOOL) tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

-(NSIndexPath*) tableView:(UITableView*)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*)sourceIndexPath toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section == 0) {
        return [NSIndexPath indexPathForRow:0 inSection:1];
    }
    return proposedDestinationIndexPath;
}

-(void) updateKeysForPrefix:(NSString*)k {
    keyPrefix = [k copy];
}

@end
