static Class cellTitleForSectionName(NSString *sectionID) {
    if ([sectionID isEqualToString:@"com.apple.controlcenter.air-stuff"]) {
        return localisedStringForKey(@"st_AIR_STUFF");
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.volume"]) {
        return localisedStringForKey(@"st_VOLUME");
    }
    else if ([sectionID isEqualToString:@"com.apple.controlcenter.brightness"]) {
        return localisedStringForKey(@"st_BRIGHTNESS");
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.small-scroll"]) {
        return localisedStringForKey(@"st_SMALL_SCROLL");
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.big-scroll"]) {
        return localisedStringForKey(@"st_BIG_SCROLL");
    }
    else if ([sectionID isEqualToString:@"com.apple.controlcenter.media-controls"]) {
        return localisedStringForKey(@"st_DEFAULT_MEDIA");
    }
    else if ([sectionID isEqualToString:@"com.apple.controlcenter.settings"]) {
        return localisedStringForKey(@"st_TOGGLES");
    }
    else if ([sectionID isEqualToString:@"com.apple.controlcenter.quick-launch"]) {
        return localisedStringForKey(@"st_QUICK_LAUNCH");
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.media-titles"]) {
        return localisedStringForKey(@"st_MEDIA_TITLES");
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.media-buttons"]) {
        return localisedStringForKey(@"st_MEDIA_BUTTONS");
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.media-scrubber"]) {
        return localisedStringForKey(@"st_MEDIA_SCRUBBER");
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.people"]) {
        return localisedStringForKey(@"st_PEOPLE");
    }
    return @"";
}
