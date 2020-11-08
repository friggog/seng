
%group SENG_IOS_8_AND_9

%hook SBAppSwitcherController

- (void)loadView {
    // create container views
    %orig;
    if(!IS_IOS_(9,0))
        lastSwitcherOrientationLandscape = isLandscape();

    BOOL needsSetup;

    if(!bottomContainerView) {
        bottomContainerView = [[SengContainerView alloc] initWithFrame:CGRectMake(0, screenHeight(), screenWidth(), 0)];
        needsSetup = YES;
    }

    if(!topContainerView) {
        topContainerView = [[SengContainerView alloc] initWithFrame:CGRectMake(0, 0, screenWidth(), 0)];
        needsSetup = YES;
    }

    if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue] && !IS_IOS_(9,0)) {
        MSHookIvar<UIView *>(self, "_peopleView").hidden = YES;
    }

    if(needsSetup) {
        [self setupViews];
        topContainerView.visibleContentHeight = [topContainerView contentHeight];
        bottomContainerView.visibleContentHeight = [bottomContainerView contentHeight];
    }

    UIView *contentView = nil;

    if(IS_IOS_(9,0))
        contentView = MSHookIvar<UIView*>([%c(SBMainSwitcherViewController) sharedInstance],"_contentView");
    else
        contentView = MSHookIvar<UIView *>(self, "_contentView");

    [contentView addSubview:bottomContainerView];
    [contentView addSubview:topContainerView];

    if(IS_IOS_(9,0))
        hsIconView = [[%c(SengSBIconView) alloc] initWithContentType:0];
    else
        hsIconView = [[%c(SengSBIconView) alloc] initWithDefaultSize];

    hsIconView.icon =  [[%c(SengSBIcon) alloc] init];
    hsIconView.location = isPortrait()?(IS_IOS_(8,4) ? 4:3):(IS_IOS_(8,4) ? 5:4);
    hsIconView.delegate = self.iconController;
    [hsIconView setLegibilitySettings:self.iconController.legibilitySettings];
    [MSHookIvar<UIView*>(self.iconController, "_iconContainer") addSubview:hsIconView];
    [hsIconView layoutSubviews];
    [hsIconView _updateLabel];
    areAppSwitcherIconLabelsHidden = MSHookIvar<UIView*>(hsIconView,"_labelView").hidden || CGRectGetHeight(MSHookIvar<UIView*>(hsIconView,"_labelView").frame) == 0 || CGRectGetWidth(MSHookIvar<UIView*>(hsIconView,"_labelView").frame) == 0;
}

+ (CGFloat)pageScale {
    if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher || weirdReduceMotionQuickSwitcherFix) {
        return 0.7;//quickSwitcherOrientationWasPortrait ? 0.7:0.6;//0.5:0.3;
    }
    else if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        CGFloat iconHeight = [%c(SBAppSwitcherIconView) defaultIconSize].height + (areAppSwitcherIconLabelsHidden?-10:5);
        CGFloat labelHeight =   areAppSwitcherIconLabelsHidden ? 5 : [%c(SBAppSwitcherIconView) _labelHeight];
        CGFloat iconViewOffset = prefsIconStlye == kSengIconStyleHidden ? 0 : prefsIconStlye == kSengIconStyleOverlapped ? labelHeight : iconHeight;
        CGFloat heightForSwitcher = (viewHeight() - topContainerView.visibleContentHeight - bottomContainerView.visibleContentHeight - iconViewOffset - 30); // 30 for padding
        CGFloat scale = heightForSwitcher/viewHeight();
        return scale;
    }
    else {
        return %orig;
    }
}

- (void)_bringIconViewToFront {
    %orig;
    // correct view heirachy for added views
    UIView *contentView = nil;
    if(IS_IOS_(9,0))
        contentView = MSHookIvar<UIView *>([%c(SBMainSwitcherViewController) sharedInstance], "_contentView");
    else
        contentView = MSHookIvar<UIView *>(self, "_contentView");
    [contentView bringSubviewToFront:topContainerView];
    [contentView bringSubviewToFront:bottomContainerView];
    if (hsIconView) {
        hsIconView.location = isPortrait()?(IS_IOS_(8,4) ? 4:3):(IS_IOS_(8,4) ? 5:4);
        [hsIconView layoutSubviews];
        [hsIconView _updateLabel];
        areAppSwitcherIconLabelsHidden = MSHookIvar<UIView*>(hsIconView,"_labelView").hidden || CGRectGetHeight(MSHookIvar<UIView*>(hsIconView,"_labelView").frame) == 0;
    }
}

- (void)switcherScroller:(UIViewController *)arg1 displayItemWantsToBeRemoved:(SBDisplayItem *)arg2 {
    if ([arg2.type isEqualToString:@"Homescreen"]) {
        NSInteger hsDismissType = [prefValueForKey(@"hsDismissType", NO) integerValue];
        switch (hsDismissType) {
            case 0: { // quit all
                [self quitAllApps];
            }
            break;

            case 1: { // action menu
                sengSBAlertItemActionSheet *alertItem = [[%c(sengSBAlertItemActionSheet) alloc] init];
                [[%c(SBAlertItemsController) sharedInstance] activateAlertItem:alertItem animated:YES];
            }
            break;

            case 2: {// respring
                [[%c(SBBacklightController) sharedInstance] animateBacklightToFactor:0 duration:0.1 source:1 completion:^(BOOL complete) {
                    [(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard];
                }];
            }
            break;

            case 3: {// lock
                [[%c(SBBacklightController) sharedInstance] animateBacklightToFactor:0 duration:0.1 source:1 completion:^(BOOL complete) {
                    [[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];
                }];
            }
            break;

            case 4: {// shut down
                [[%c(SBBacklightController) sharedInstance] animateBacklightToFactor:0 duration:0.1 source:1 completion:^(BOOL complete) {
                    [(SpringBoard *)[UIApplication sharedApplication] powerDown];
                }];
            }
            break;

            default: {
                // NONE
            }
            break;
        }
    }
    else {
        %orig;
    }
}

- (BOOL)switcherScroller:(id)arg1 isDisplayItemRemovable:(SBDisplayItem *)arg2 {
    // overwrite to make SpringBoard item removable
    if ([prefValueForKey(@"hsDismissType", NO) integerValue] != 5) {
        return YES;
    }
    else {
        return %orig;
    }
}

- (void)_updateForAnimationFrame:(CGFloat)progress withAnchor:(id)anchor {
    if(hackyFixForAppSwitcherOpenGesture && progress == 0) {
        hackyFixForAppSwitcherOpenGesture = NO;
        MSHookIvar<UIView *>(self, "_iconView").layer.opacity = 0;
        return;
    }

    if (overrideCCGestureType == SengOverrideCCGestureTypeNone && !wantsPanGestureOverrideForDismissGesture) {
        %orig;
    }
    else if(!reduceMotionEnabled){
        [self _updatePageViewScale:1 + (self._scaleForFullscreenPageView-1)*progress];
    }
    UIView *iconView = MSHookIvar<UIView *>(self, "_iconView");
    if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue] || overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        if (iconView) {
            iconView.layer.opacity = 1.0-progress;
            [iconView.layer removeAnimationForKey:@"position"];
            if(IS_IOS_(9,0)) {
                CGFloat scrollViewOrigin = self.iconController.view.frame.origin.y;
                CGFloat desiredScreenPosition = viewHeight()/2.0 + self._switcherThumbnailVerticalPositionOffset + viewHeight() * [objc_getClass("SBAppSwitcherController") pageScale]/2.0 - (prefsIconStlye == kSengIconStyleOverlapped?[objc_getClass("SBAppSwitcherIconView") defaultIconSize].height:20) + (areAppSwitcherIconLabelsHidden?35:28);
                if(overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
                    desiredScreenPosition = isPortrait() ? viewHeight()-190 : viewHeight()-110;
                }
                CGFloat iconViewInitialOrigin = viewHeight() - scrollViewOrigin;
                CGFloat iconViewFinalOrigin = desiredScreenPosition - scrollViewOrigin;
                for (int i = 0; i < self.pageController.displayItems.count; i++) {
                    if ([self.iconController _iconViewForIndex:i]) {
                        UIView *iconV = [self.iconController _iconViewForIndex:i];
                        iconV.frame = CGRectMake(CGRectGetMinX(iconV.frame), iconViewInitialOrigin + (1.0-progress)*(iconViewFinalOrigin-iconViewInitialOrigin),CGRectGetWidth(iconV.frame),CGRectGetHeight(iconV.frame));
                    }
                }
            }
            else {
                CGFloat iconViewInitialOrigin = screenHeight();
                CGFloat iconViewFinalOrigin = screenHeight()/2.0 + self._switcherThumbnailVerticalPositionOffset + screenHeight() * [%c(SBAppSwitcherController) pageScale]/2.0 + 5.5;
                iconView.frame = CGRectMake(0, iconViewInitialOrigin - (1.0-progress)*(iconViewInitialOrigin-iconViewFinalOrigin), screenWidth(), CGRectGetHeight(iconView.frame));
            }
        }
        SBAppSwitcherPageView *page = nil;
        if(IS_IOS_(9,0))
            page = [self.pageController pageViewForDisplayItem:[%c(SBDisplayItem) homeScreenDisplayItem]];
        else
            page = [self.pageController pageViewForDisplayLayout:[%c(SBDisplayLayout) homeScreenDisplayLayout]];

        if (page) {
            MSHookIvar<UIView *>(page.view, "_wallpaperView").alpha = 1.0-progress;
        }
    }
    if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        if (overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher) {
            bottomContainerView.hidden = NO;
            topContainerView.hidden = NO;
            bottomContainerView.frame = CGRectMake(0, viewHeight() - (bottomContainerView.visibleContentHeight * (1 - progress)), viewWidth(), CGRectGetHeight(bottomContainerView.frame));
            topContainerView.frame = CGRectMake(0, -((CGRectGetHeight(topContainerView.frame)-topContainerView.visibleContentHeight) * (1-progress) + (CGRectGetHeight(topContainerView.frame) * progress)), viewWidth(), CGRectGetHeight(topContainerView.frame));
            iconView.hidden = prefsIconStlye == kSengIconStyleHidden ? YES:NO;
        }
        else {
            bottomContainerView.hidden = YES;
            topContainerView.hidden = YES;
            iconView.hidden = NO;
        }
    }
    else {
        bottomContainerView.hidden = YES;
        topContainerView.hidden = YES;
    }
}

- (void)_updatePeopleOpacity:(id)arg1 {
    if (! [prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        %orig;
    }
}

%new - (void)setupViews {
    [bottomContainerView setChevronAllowed:YES];
    [topContainerView setChevronAllowed:YES];
    [topContainerView setupForLayout:SengContainerViewLayoutTop];
    [bottomContainerView setupForLayout:SengContainerViewLayoutBottom];
    topContainerView.frame = CGRectMake(0, -CGRectGetHeight(topContainerView.frame), CGRectGetWidth(topContainerView.frame), CGRectGetHeight(topContainerView.frame));
    needsFixForLandscape = YES;
}

%new -(void)updateMediaPlayingIndicator {
    BOOL mediaAppActive = (((SBMediaController *)[%c(SBMediaController) sharedInstance]).nowPlayingApplication != nil);
    if (isMediaPlaying != mediaAppActive) {
        isMediaPlaying = mediaAppActive;
        [self setupViews];
    }
}

%new -(void)moveBottomViewToYLocation:(CGFloat)yPos {
    CGFloat exactMinY = viewHeight() - CGRectGetHeight(bottomContainerView.frame);
    CGFloat minY = exactMinY - 20;
    CGFloat exactMaxY = viewHeight() - bottomContainerView.visibleContentHeight;
    CGFloat maxY = exactMaxY + 20;
    yPos = yPos<minY ? minY:yPos>maxY ? maxY:yPos;
    bottomContainerView.frame = CGRectMake(0, yPos, viewWidth(), CGRectGetHeight(bottomContainerView.frame));
    [bottomContainerView setBackgroundAlphaIfAllowed:1 - (yPos-exactMinY)/(exactMaxY-exactMinY)];
}

%new -(void)moveTopViewToYLocation:(CGFloat)yPos {
    CGFloat exactMinY = -(CGRectGetHeight(topContainerView.frame)-topContainerView.visibleContentHeight) + CGRectGetHeight(topContainerView.frame);
    CGFloat minY = exactMinY - 20;
    CGFloat exactMaxY = CGRectGetHeight(topContainerView.frame);
    CGFloat maxY = exactMaxY + 20;
    yPos = yPos<minY ? minY:yPos>maxY ? maxY:yPos;
    topContainerView.frame = CGRectMake(0, yPos-CGRectGetHeight(topContainerView.frame), viewWidth(), CGRectGetHeight(topContainerView.frame));
    [topContainerView setBackgroundAlphaIfAllowed:(yPos-exactMinY)/(exactMaxY-exactMinY)];
}

%new -(void)moveTopViewFinishedAtLocation:(CGPoint)location withVelocity:(CGPoint)velocity chevron:(SBChevronView *)chev {
    CGFloat drawerInY = -(CGRectGetHeight(topContainerView.frame)-topContainerView.visibleContentHeight) + CGRectGetHeight(topContainerView.frame);
    CGFloat drawerOutY = CGRectGetHeight(topContainerView.frame);
    drawerOutY = viewHeight()-CGRectGetHeight(topContainerView.frame) < 0 ? viewHeight():drawerOutY;
    [topContainerView.superview bringSubviewToFront:topContainerView];
    if (location.y <= drawerInY || (velocity.y < 0 && location.y < drawerOutY)) {
        [SengAnimator animateWithActions:^{
            topContainerView.frame = CGRectMake(0, drawerInY - CGRectGetHeight(topContainerView.frame), viewWidth(), CGRectGetHeight(topContainerView.frame));
            [topContainerView setBackgroundAlphaIfAllowed:0];
        }];
        [chev setState:0 animated:YES];
    }
    else if (location.y >= drawerOutY || (velocity.y > 0 && location.y > drawerInY)) {
        [SengAnimator animateWithActions:^{
            topContainerView.frame = CGRectMake(0, drawerOutY - CGRectGetHeight(topContainerView.frame), viewWidth(), CGRectGetHeight(topContainerView.frame));
            [topContainerView setBackgroundAlphaIfAllowed:1];
        }];
        [chev setState:1 animated:YES];
    }
}

%new -(void)moveBottomViewFinishedAtLocation:(CGPoint)location withVelocity:(CGPoint)velocity chevron:(SBChevronView *)chev {
    CGFloat drawerOutY = viewHeight() - CGRectGetHeight(bottomContainerView.frame);
    CGFloat drawerInY = viewHeight() - bottomContainerView.visibleContentHeight;
    drawerOutY = drawerOutY < 0 ? 0:drawerOutY;
    [bottomContainerView.superview bringSubviewToFront:bottomContainerView];
    if (location.y <= drawerOutY || (velocity.y < 0 && location.y < drawerInY)) { // drawer going out
        [SengAnimator animateWithActions:^{
            bottomContainerView.frame = CGRectMake(0, drawerOutY, viewWidth(), CGRectGetHeight(bottomContainerView.frame));
            [bottomContainerView setBackgroundAlphaIfAllowed:1];
        }];
        [chev setState:1 animated:YES];
    }
    else if (location.y >= drawerInY || (velocity.y > 0 && location.y > drawerOutY)) { // drawer going in
        [SengAnimator animateWithActions:^{
            bottomContainerView.frame = CGRectMake(0, drawerInY, viewWidth(), CGRectGetHeight(bottomContainerView.frame));
            [bottomContainerView setBackgroundAlphaIfAllowed:0];
        }];
        [chev setState:0 animated:YES];
    }
}

%new -(void)moveTopViewToNearestEnd:(SBChevronView *)chev {
    CGFloat pos = CGRectGetMinY(topContainerView.frame);
    if (pos > -20) {
        [self moveTopViewFinishedAtLocation:CGPointMake(0, 0) withVelocity:CGPointZero chevron:chev];
    }
    else {
        [self moveTopViewFinishedAtLocation:CGPointMake(0, viewHeight()) withVelocity:CGPointZero chevron:chev];
    }
}

%new -(void)moveBottomViewToNearestEnd:(SBChevronView *)chev {
    CGFloat drawerInY = viewHeight() - bottomContainerView.visibleContentHeight;
    CGFloat difToOrigin = fabs(CGRectGetMinY(bottomContainerView.frame)-drawerInY);
    if (difToOrigin < 20) { // move drawer out
        [self moveBottomViewFinishedAtLocation:CGPointMake(0, 0) withVelocity:CGPointMake(0, -1) chevron:chev];
    }
    else { // move drawer in
        [self moveBottomViewFinishedAtLocation:CGPointMake(0, viewHeight()) withVelocity:CGPointMake(0, 1) chevron:chev];
    }
}

%new -(void)switcherScroller:(id)scroller itemTapped:(id)item animated:(BOOL)a {
    if (! a) {
        overrideDismissSwitcherAnimation = YES;
    }
    [self switcherScroller:scroller itemTapped:item];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        overrideDismissSwitcherAnimation = NO;
    });
}

%end

%hook SBAppSwitcherPageViewController

- (BOOL)_isItemVisible:(id)item withSidePadding:(CGFloat)padding {
    if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        NSInteger index = IS_IOS_(9,0)?[self.displayItems indexOfObjectIdenticalTo:item]:[self.displayLayouts indexOfObjectIdenticalTo:item];
        SengQuickSwitcherIconsController *ic = (SengQuickSwitcherIconsController *)versionCorrectSwitcherController().iconController;
        if ([ic respondsToSelector:@selector(getCurrentIndex)]) {
            return index >= [ic getCurrentIndex] - floor(switcherIconsPerPage/2) && index <= [ic getCurrentIndex] + floor(switcherIconsPerPage/2);
        }
        else {
            return %orig;
        }
    }
    else {
        return %orig;
    }
}

- (void)setOffsetToIndex:(NSInteger)index animated:(BOOL)a {
    if (! isAppSwitcherActive && overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher && ([prefValueForKey(@"gestureAnim", YES) boolValue] || [prefValueForKey(@"openToCurrent", YES) boolValue])) {
        if ((index == 1 && (frontMostApplication != nil || switcherJustOpenedFromApp)) || index == 2) {
            %orig(1, a);
        }
        else {
            %orig(0, a);
        }
    }
    else {
        %orig;
    }
}

- (void)scrollViewWillEndDragging:(SBAppSwitcherItemScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(CGPoint *)arg3 {
    %orig;
    if (velocity.y < 0 && scrollView.contentOffset.y < 0 && [prefValueForKey(@"multiCentreEnabled", YES) boolValue] && ! [prefValueForKey(@"gestureAnim", YES) boolValue]) {
        SBAppSwitcherController *sController = versionCorrectSwitcherController();
        id thisDisplayThing = nil;
        if(IS_IOS_(9,0))
            thisDisplayThing = [self displayItemForScrollView:scrollView];
        else
            thisDisplayThing = [self displayLayoutForScrollView:scrollView];
        if (reduceMotionEnabled) {
            scrollView.contentOffset = CGPointMake(0, 0);
            scrollView.item.frame = CGRectMake(CGRectGetMinX(scrollView.item.frame), 0, CGRectGetWidth(scrollView.item.frame), CGRectGetHeight(scrollView.item.frame));
        }
        else {
            [SengAnimator animateWithActions:^{
                scrollView.contentOffset = CGPointMake(0, 0);
                scrollView.item.frame = CGRectMake(CGRectGetMinX(scrollView.item.frame), 0, CGRectGetWidth(scrollView.item.frame), CGRectGetHeight(scrollView.item.frame));
            }];
        }
        [sController switcherScroller:self itemTapped:thisDisplayThing animated:YES];
    }
}

%end

%hook SBAppSwitcherScrollView

-(void)setContentOffset:(CGPoint)offset animated:(BOOL)a {
    //TODO THIS MAY NEED TO BE FIXED ON IOS9
    if(a && (wantsPanGestureOverrideForDismissGesture || overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher)) {
        [SengAnimator animateWithActions:^{
            %orig(offset,NO);
        }];
    }
    else {
        %orig;
    }
}

%end

%hook SBAppSwitcherIconController

- (void)setOffsetToIndex:(NSInteger)index animated:(BOOL)a {
    if (! isAppSwitcherActive && overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher && ([prefValueForKey(@"gestureAnim", YES) boolValue] || [prefValueForKey(@"openToCurrent", YES) boolValue])) {
        if ((index == 1 && (frontMostApplication != nil || switcherJustOpenedFromApp)) || index == 2) {
            %orig(1, a);
        }
        else {
            %orig(0, a);
        }
    }
    else {
        %orig;
    }
}

+ (CGFloat)nominalDistanceBetween3IconCentersForSize:(CGSize)size {
    if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        if([prefValueForKey(@"altQS",NO) boolValue]) {
            return viewWidth()/5;
        }
        else {
            switcherIconsPerPage = switcherIconsPerPage == 0 ? 1:switcherIconsPerPage; // stops divide by 0
            return viewWidth()/switcherIconsPerPage;
        }
    }
    else if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue] /*&& prefsIconStlye == kSengIconStyleOverlapped*/) {
        return [%c(SBAppSwitcherController) pageScale] * viewWidth();
    }
    else {
        return %orig;
    }
}

+ (CGFloat)nominalDistanceBetween5IconCentersForSize:(CGSize)size {
    if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        if([prefValueForKey(@"altQS",NO) boolValue]) {
            return viewWidth()/5;
        }
        else {
            switcherIconsPerPage = switcherIconsPerPage == 0 ? 1:switcherIconsPerPage; // stops divide by 0
            return viewWidth()/switcherIconsPerPage;
        }
    }
    else if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue]/* && prefsIconStlye == kSengIconStyleOverlapped*/) {
        return [%c(SBAppSwitcherController) pageScale] * viewWidth();
    }
    else {
        return %orig;
    }
}

- (void)iconTapped:(SBIconView *)iconView {
    %orig;
    if ([iconView isEqual:hsIconView]) {
        SBAppSwitcherController *sController = versionCorrectSwitcherController();
        [sController switcherScroller:sController.pageController itemTapped:[%c(SBDisplayLayout) homeScreenDisplayLayout] animated:YES];
    }
}

- (void)setLegibilitySettings:(_UILegibilitySettings *)settings {
    %orig;
    if (hsIconView && !IS_IOS_(9,0)) {
        [hsIconView setLegibilitySettings:settings];
    }
}

%end

%hook SBAppSwitcherIconView

- (CGRect)_frameForAccessoryView {
    if(IS_IOS_(9,0) && overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher && [prefValueForKey(@"multiCentreEnabled", YES) boolValue]){
        CGRect f = %orig;
        f.origin.x += CGRectGetWidth([%c(SBAppSwitcherIconView) defaultIconImageFrame])/2;
        return f;
    }
    return %orig;
}

- (void)layoutSubviews {
    %orig;
    [self updateShadow];
    if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        UIView *label = MSHookIvar<UIView *>(self, "_labelView");
        label.frame = CGRectMake(CGRectGetMinX(label.frame), -25, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
    }
    if(IS_IOS_(9,0) && overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        CGRect f = [%c(SBAppSwitcherIconView) defaultIconImageFrame];
        if(self.tag != kSengQuickSwitcherDodgyIconFixFix)
            f.origin.x -= f.size.width/2;
        self._iconImageView.frame = f;
        /*if (overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher) {
            UIView *label = MSHookIvar<UIView *>(self, "_labelView");
            label.frame = CGRectMake(CGRectGetMinX(label.frame) - f.size.width/2, CGRectGetMinY(label.frame), CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
        }*/
    }
}

%new - (void)updateShadow {
    if (([prefValueForKey(@"multiCentreEnabled", YES) boolValue] && prefsIconStlye == 1) && overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher) { // overlapped
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 15;
        self.layer.shadowOpacity = 0.5;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    else {
        self.layer.shadowOpacity = 0;
    }
}

%end

%hook SBWorkspace

- (id)init {
    self = %orig;
    workspace = self;
    return self;
}

%end

%hook SBCCBrightnessSectionController

- (void)viewDidLayoutSubviews {
    %orig;
    if ([prefValueForKey(@"hideDarkSectionBGS", NO) boolValue] || self.view.tag == kSengSectionInScrollViewTag) {
        MSHookIvar<UIView *>(self, "_vibrantDarkenLayer").hidden = YES;
        MSHookIvar<UIView *>(self, "_tintingDarkenLayer").hidden = YES;
    }
    else {
        MSHookIvar<UIView *>(self, "_vibrantDarkenLayer").hidden = NO;
        MSHookIvar<UIView *>(self, "_tintingDarkenLayer").hidden = NO;
    }
}

%end

%hook SBCCButtonLikeSectionView

- (void)layoutSubviews {
    %orig;
    [self _updateEffects];
}

- (void)_updateEffects {
    %orig;
    if ([prefValueForKey(@"hideDarkSectionBGS", NO) boolValue] || self.tag == kSengSectionInScrollViewTag) {
        if ((int)self.state == 1) {
            MSHookIvar<UIView *>(self, "_vibrantDarkenLayer").hidden = NO;
            MSHookIvar<UIView *>(self, "_tintingDarkenLayer").hidden = NO;
        }
        else {
            MSHookIvar<UIView *>(self, "_vibrantDarkenLayer").hidden = YES;
            MSHookIvar<UIView *>(self, "_tintingDarkenLayer").hidden = YES;
        }
    }
}

- (void)_updateBackgroundForStateChange {
    %orig;
    if ([prefValueForKey(@"hideDarkSectionBGS", NO) boolValue] || self.tag == kSengSectionInScrollViewTag) {
        if ((int)self.state == 1) {
            MSHookIvar<UIView *>(self, "_vibrantDarkenLayer").hidden = NO;
            MSHookIvar<UIView *>(self, "_tintingDarkenLayer").hidden = NO;
        }
        else {
            MSHookIvar<UIView *>(self, "_vibrantDarkenLayer").hidden = YES;
            MSHookIvar<UIView *>(self, "_tintingDarkenLayer").hidden = YES;
        }
    }
}

%end

%hook SBControlCenterGrabberView

-(void)presentStatusUpdate:(id)update {
    if(bottomContainerView && self.tag != kSengGrabberViewTag) {
        if(isLandscape()) {
            if([[SengShared bottomContainerView] hasGrabberView]) {
                [[SengShared bottomContainerView] handleStatusUpdate:update];
            }
            else {
                [[SengShared topContainerView] handleStatusUpdate:update];
            }
        }
        else {
            [[SengShared bottomContainerView] handleStatusUpdate:update];
        }
    }
    %orig;
}

%end

%hook SBControlCenterController

%new - (void)startDismissWithGrabber {
    overrideCCGestureType = SengOverrideCCGestureTypeAppSwitcher;
}

%end

%end
