#import "../SharedDefs.h"

static Class sectionClassForSectionName(NSString *sectionID) {
    if ([sectionID isEqualToString:@"me.chewitt.seng.volume"]) {
        return [SengVolumeSectionView class];
    }
    else if ([sectionID isEqualToString:@"com.apple.controlcenter.brightness"]) {
        return [SengBrightnessSectionView class];
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.small-scroll"]) {
        return [SengSmallScrollSectionView class];
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.big-scroll"]) {
        return [SengBigScrollSectionView class];
    }
    else if ([sectionID isEqualToString:@"com.apple.controlcenter.quick-launch"]) {
        return [SengQuickLaunchSectionView class];
    }
    else if ([sectionID isEqualToString:@"com.apple.controlcenter.settings"]) {
        return [SengSettingsSectionView class];
    }
    else if ([sectionID isEqualToString:@"com.apple.controlcenter.media-controls"]) {
        return [SengMediaSectionView class];
    }
    else if ([sectionID isEqualToString:@"com.apple.controlcenter.air-stuff"]) {
        return [SengAirStuffSectionView class];
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.media-titles"]) {
        return [SengMediaTitlesSectionView class];
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.media-buttons"]) {
        return [SengMediaButtonsSectionView class];
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.media-scrubber"]) {
        return [SengMediaScrubberSectionView class];
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.people"]) {
        return [SengPeopleSectionView class];
    }
    else if ([sectionID isEqualToString:@"me.chewitt.seng.chevron"]) {
        return [SengChevronSectionView class];
    }
    else if (objc_getClass("CCSectionViewController") != nil) {
        return [SengCCLoaderSectionView class];
    }
    else {
        return nil;
    }
}
