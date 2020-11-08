#import <UIKit/_UIBackdropView.h>
#import <UIKit/_UIBackdropViewSettings.h>
#import "SengContainerView.h"
#import "SectionViews/sectionClassForSectionName.h"
#import <objc/runtime.h>

@implementation SengContainerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _UIBackdropViewSettings *ccBGSettings;
        id viewController = MSHookIvar<id>([objc_getClass("SBControlCenterController") sharedInstance], "_viewController");
        if (viewController) {
            SBControlCenterContainerView *containerView = MSHookIvar<SBControlCenterContainerView *>(viewController, "_containerView");
            if (containerView) {
                _UIBackdropView *ccBGView = [[containerView contentContainerView] backdropView];
                ccBGSettings = [ccBGView inputSettings];
            }
        }
        ccBGSettings = (ccBGSettings != nil) ? ccBGSettings :[_UIBackdropViewSettings settingsForStyle:2060];
        _backgroundView = [[_UIBackdropView alloc] initWithSettings:ccBGSettings];
        _backgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView];
        _activeSections = [NSMutableArray array];
        _allowChevron = YES;
    }
    return self;
}

- (void)setupForLayout:(SengContainerViewLayout)l {
    _layout = l;
    [self setBackgroundAlphaIfAllowed:0];
    NSString *key = _layout == SengContainerViewLayoutTop ? @"topViewEnabledSections" : @"bottomViewEnabledSections";
    NSArray *sections = (NSArray *)[SengShared manualPrefsDic][key];
    if (! sections) {
        if (_layout == SengContainerViewLayoutTop) {
            sections = [NSArray arrayWithObjects:@"com.apple.controlcenter.air-stuff", nil];
        }
        else if (_layout == SengContainerViewLayoutBottom) {
            sections = [NSArray arrayWithObjects:@"com.apple.controlcenter.settings", @"me.chewitt.seng.small-scroll", @"com.apple.controlcenter.quick-launch", nil];
        }
    }
    if (sections.count > 0) {
        if (_layout == SengContainerViewLayoutTop) {
            _backgroundView.frame = CGRectMake(0, -30, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)+30);
        }
        else if (_layout == SengContainerViewLayoutBottom) {
            _backgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)+30);
        }
    }
    [self setupForSections:sections];
}

- (void)setupForSections:(NSArray *)sections {
    for (SengSectionView *v in _activeSections) {
        [v removeFromSuperview];
    }
    _totalHeight = 0;
    _grabberView = nil;
    NSArray *oldSections = [NSArray arrayWithArray:_activeSections];
    NSArray *oldSectionIDS = [NSArray arrayWithArray:_sectionsIDS];
    [_activeSections removeAllObjects];
    _sectionsIDS = [NSMutableArray arrayWithArray:sections];
    if (([[SengShared prefsDic][@"alwaysShowGrabber"] boolValue] && _layout == SengContainerViewLayoutBottom) || (_allowChevron && isLandscape())) {
        if (_layout == SengContainerViewLayoutTop) {
            [_sectionsIDS addObject:@"me.chewitt.seng.chevron"];
        }
        else {
            [_sectionsIDS insertObject:@"me.chewitt.seng.chevron" atIndex:0];
        }
    }
    if(IS_IOS_(9,0)) {
        if([_sectionsIDS containsObject:@"me.chewitt.seng.people"]) {
            [_sectionsIDS removeObject:@"me.chewitt.seng.people"];
        }
    }
    NSMutableArray *toRemove = [NSMutableArray array];
    for (NSString *sectionID in _sectionsIDS) {
        if (! [self isSectionHidden:sectionID]) {
            Class sectionClass = sectionClassForSectionName(sectionID);
            if (sectionClass != nil) {
                SengSectionView *sectionView;
                if ([oldSectionIDS containsObject:sectionID] && ! [SengShared forceReload]) {
                    sectionView = oldSections[[oldSectionIDS indexOfObject:sectionID]];
                    [sectionView setFrame:CGRectMake(0, _totalHeight, CGRectGetWidth(self.frame), CGRectGetHeight(sectionView.frame))];
                    if ([sectionID rangeOfString:@"scroll"].location != NSNotFound) {
                        [(SengScrollSectionView *)sectionView updateForLayout:_layout];
                    }
                    else if ([sectionID isEqualToString:@"me.chewitt.seng.chevron"]) {
                        [(SengChevronSectionView *)sectionView setLayout:_layout];
                    }
                }
                else {
                    if ([sectionClass isEqual:[SengCCLoaderSectionView class]]) {
                        sectionView = [[SengCCLoaderSectionView alloc] initWithWidth:CGRectGetWidth(self.frame) andPosition:CGPointMake(0, _totalHeight) andCCLIdentifier:sectionID];
                    }
                    else {
                        sectionView = [[sectionClass alloc] initWithWidth:CGRectGetWidth(self.frame) andPosition:CGPointMake(0, _totalHeight)];
                        if ([sectionID rangeOfString:@"scroll"].location != NSNotFound) {
                            [(SengScrollSectionView *)sectionView updateForLayout:_layout];
                        }
                        else if ([sectionID isEqualToString:@"me.chewitt.seng.chevron"]) {
                            [(SengChevronSectionView *)sectionView setLayout:_layout];
                        }
                    }
                }
                if([sectionView isKindOfClass:[SengChevronSectionView class]]) {
                    _grabberView = (SengChevronSectionView*)sectionView;
                }
                if(sectionView != nil) {
                    [_activeSections addObject:sectionView];
                    [self addSubview:sectionView];
                    _totalHeight += sectionView.sectionHeight;
                }
            }
            else {
                [toRemove addObject:sectionID];
            }
        }
        else {
            [toRemove addObject:sectionID];
        }
    }
    for (id r in toRemove) {
        [_sectionsIDS removeObject:r];
    }
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), _totalHeight);
}

- (BOOL)isSectionHidden:(NSString *)sectionID {
    NSString *prefix;
    if (_layout == SengContainerViewLayoutTop) {
        prefix = @"top";
    }
    else if (_layout == SengContainerViewLayoutBottom) {
        prefix = @"bottom";
    }
    BOOL autohidesMediaTitles = ! [[SengShared prefsDic][[NSString stringWithFormat:@"%@_mediaTitlesHides", prefix]] boolValue];
    BOOL hideMediaTitlesWhenPlaying = [[SengShared prefsDic][[NSString stringWithFormat:@"%@_mediaTitlesHidesP", prefix]] boolValue];
    BOOL autohidesMediaButtons = [[SengShared prefsDic][[NSString stringWithFormat:@"%@_mediaButtonsHides", prefix]] boolValue];
    BOOL hideMediaButtonsWhenPlaying = [[SengShared prefsDic][[NSString stringWithFormat:@"%@_mediaButtonsHidesP", prefix]] boolValue];
    BOOL autohidesMediaScrubber = [[SengShared prefsDic][[NSString stringWithFormat:@"%@_mediaScrubberHides", prefix]] boolValue];
    BOOL hideMediaScrubberWhenPlaying = [[SengShared prefsDic][[NSString stringWithFormat:@"%@_mediaScrubberHidesP", prefix]] boolValue];
    BOOL autohidesMedia = [[SengShared prefsDic][[NSString stringWithFormat:@"%@_mediaHides", prefix]] boolValue];
    BOOL hideMediaWhenPlaying = [[SengShared prefsDic][[NSString stringWithFormat:@"%@_mediaHidesP", prefix]] boolValue];
    BOOL autohidesAirStuff = [[SengShared prefsDic][[NSString stringWithFormat:@"%@_airStuffHides", prefix]] boolValue];

    BOOL hideForMediaNotPlaying = (([sectionID isEqualToString:@"com.apple.controlcenter.media-controls"] && autohidesMedia) || ([sectionID isEqualToString:@"me.chewitt.seng.media-titles"] && autohidesMediaTitles) || ([sectionID isEqualToString:@"me.chewitt.seng.media-buttons"] && autohidesMediaButtons) || ([sectionID isEqualToString:@"me.chewitt.seng.media-scrubber"] && autohidesMediaScrubber)) && ! [SengShared isMediaPlaying];
    BOOL hideForMediaPlaying = (([sectionID isEqualToString:@"com.apple.controlcenter.media-controls"] && hideMediaWhenPlaying) || ([sectionID isEqualToString:@"me.chewitt.seng.media-titles"] && hideMediaTitlesWhenPlaying) || ([sectionID isEqualToString:@"me.chewitt.seng.media-buttons"] && hideMediaButtonsWhenPlaying) || ([sectionID isEqualToString:@"me.chewitt.seng.media-scrubber"] && hideMediaScrubberWhenPlaying)) && [SengShared isMediaPlaying];
    if (hideForMediaPlaying || hideForMediaNotPlaying) {
        return YES;
    }
    else if ([sectionID isEqualToString:@"com.apple.controlcenter.air-stuff"] && autohidesAirStuff) {
        if (! _isAirplayShowing) {
            return YES;
        }
    }
    return NO;
}

- (void)viewWillAppear {
    for (SengSectionView *v in _activeSections) {
        [v viewWillAppear];
    }
    BOOL airPLayAvailable = [self isAirplayAvailabe];
    if (_isAirplayShowing != airPLayAvailable) {
        _isAirplayShowing = airPLayAvailable;
        [versionCorrectSwitcherController() setupViews];
    }
}

- (void)viewDidDisappear {
    for (SengSectionView *v in _activeSections) {
        [v viewDidDisappear];
    }
}

- (BOOL)isAirplayAvailabe {
    [((SBCCAirStuffSectionController *)MSHookIvar < SBControlCenterContentView*> (MSHookIvar < UIViewController*> ([objc_getClass("SBControlCenterController") sharedInstance], "_viewController"), "_contentView").airplaySection) controlCenterWillPresent];
    // BAM
    MPAVRoutingController *routingController = MSHookIvar<MPAVRoutingController *>([objc_getClass("SBMediaController") sharedInstance], "_routingController");
    NSArray *availableRoutes = [routingController availableRoutes];
    for (MPAVRoute *route in availableRoutes) {
        NSDictionary *routeDescription = [route avRouteDescription];
        if ([routeDescription[@"AVAudioRouteName"] isEqualToString:@"AirTunes"]) {
            return YES;
        }
    }
    return NO;
}

- (CGFloat)contentHeight {
    _totalHeight = 0;
    for (SengSectionView *v in _activeSections) {
        _totalHeight += [v sectionHeight];
    }
    return _totalHeight;
}

- (void)setBackgroundAlphaIfAllowed:(CGFloat)a {
    _backgroundView.alpha = [[SengShared prefsDic][@"noBG"] boolValue] ? a : 1;
}

- (NSArray *)activeSections {
    return [NSArray arrayWithArray:_activeSections];
}

- (void)setChevronAllowed:(BOOL)a {
    if (a != _allowChevron) {
        _allowChevron = a;
        [self setupForLayout:_layout];
    }
}

- (void)handleStatusUpdate:(id)update {
    if(_grabberView)
        [_grabberView handleStatusUpdate:update];
}

- (void)setGrabberStateOut:(BOOL)o {
    if(_grabberView && !isLandscape())
        [_grabberView setChevronPointed:o];
}

- (BOOL)hasGrabberView {
    return _grabberView != nil;
}

@end
