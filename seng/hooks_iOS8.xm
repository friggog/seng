
%group SENG_IOS_8

%hook SBAppSwitcherController

- (void)switcherWasDismissed:(BOOL)animated {
    %orig;
    isAppSwitcherActive = NO;
    topContainerView.hidden = YES;
    [topContainerView removeFromSuperview];
    bottomContainerView.hidden = YES;
    [bottomContainerView removeFromSuperview];
}

- (void)animateDismissalToDisplayLayout:(SBDisplayLayout *)layout withCompletion:(void (^)(BOOL))completion {
    if (overrideDismissSwitcherAnimation) {
        %orig(layout, NULL);
        UIView *pageView = MSHookIvar<UIView *>(self, "_pageView");
        [pageView.layer removeAnimationForKey:@"transform"];
        UIView *iconView = MSHookIvar<UIView *>(self, "_iconView");
        [iconView.layer removeAnimationForKey:@"position"];
        [iconView.layer removeAnimationForKey:@"position-2"];
        [iconView.layer removeAnimationForKey:@"opacity"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            completion(YES);
        });
    }
    else {
        [bottomContainerView setGrabberStateOut:NO];
        %orig;
        [self _bringIconViewToFront];
    }
    [topContainerView viewDidDisappear];
    [bottomContainerView viewDidDisappear];
}

- (void)animatePresentationFromDisplayLayout:(id)layout withViews:(id)views withCompletion:(void (^)(BOOL))completion {
    BOOL mcEnabled = [prefValueForKey(@"multiCentreEnabled", YES) boolValue];
    MSHookIvar<UIView *>(self, "_peopleView").hidden = mcEnabled || overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher;
    if (mcEnabled && overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher) {
        [self updateMediaPlayingIndicator];
        UIView * contentView = MSHookIvar<UIView*>(self,"_contentView");
        [contentView addSubview:topContainerView];
        [topContainerView viewWillAppear];
        [contentView addSubview:bottomContainerView];
        [bottomContainerView viewWillAppear];
        if (lastSwitcherOrientationLandscape != isLandscape()) {
            lastSwitcherOrientationLandscape = isLandscape();
            [self setupViews];
        }
        if (isLandscape() &&  overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher && needsFixForLandscape) {
            CGFloat sizeForSwitcher = screenHeight();
            CGFloat minSizeForSwitcher = prefsIconStlye == kSengIconStyleOverlapped ? viewHeight()/3 : prefsIconStlye == kSengIconStyleHidden ? viewHeight()/4 : viewHeight()/2.5;
            CGFloat topHeight = 0;
            CGFloat bottomHeight = 0;
            NSInteger bottomIndex = 0;
            NSInteger topIndex = topContainerView.activeSections.count - 1;
            BOOL finishedBot = NO;
            BOOL finishedTop = NO;
            while (! finishedTop || ! finishedBot) {
                if (bottomIndex < bottomContainerView.activeSections.count) {
                    SengSectionView *s = (SengSectionView *)bottomContainerView.activeSections[bottomIndex];
                    if (sizeForSwitcher-s.sectionHeight > minSizeForSwitcher) {
                        bottomHeight += s.sectionHeight;
                        sizeForSwitcher -= s.sectionHeight;
                        bottomIndex++;
                    }
                    else {
                        finishedBot = YES;
                    }
                }
                else {
                    finishedBot = YES;
                }

                if (topIndex >= 0) {
                    SengSectionView *s = (SengSectionView *)topContainerView.activeSections[topIndex];
                    if (sizeForSwitcher-s.sectionHeight > minSizeForSwitcher) {
                        topHeight += s.sectionHeight;
                        sizeForSwitcher -= s.sectionHeight;
                        topIndex--;
                    }
                    else {
                        finishedTop = YES;
                    }
                }
                else {
                    finishedTop = YES;
                }
            }
            if (bottomIndex == bottomContainerView.activeSections.count) {
                [bottomContainerView setChevronAllowed:NO];
                if(!prefValueForKey(@"alwaysShowGrabber", NO)) {
                    bottomHeight -= 30;
                }
            }
            else {
                [bottomContainerView setChevronAllowed:YES];
            }
            if (topIndex == -1) {
                [topContainerView setChevronAllowed:NO];
                topHeight -= 30;
            }
            else {
                [topContainerView setChevronAllowed:YES];
            }
            topContainerView.visibleContentHeight = topHeight;
            bottomContainerView.visibleContentHeight = bottomHeight;
            needsFixForLandscape = NO;
        }
        else if (! isLandscape()) {
            topContainerView.visibleContentHeight = [topContainerView contentHeight];
            bottomContainerView.visibleContentHeight = [bottomContainerView contentHeight];
        }
        topContainerView.hidden = NO;
        bottomContainerView.hidden = NO;
        MSHookIvar<UIView *>(self, "_iconView").hidden = (prefsIconStlye == kSengIconStyleHidden);
    }
    if ((mcEnabled && overrideCCGestureType == SengOverrideCCGestureTypeAppSwitcher) || overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        %orig(layout, views, NULL);
        UIView *pageView = MSHookIvar<UIView *>(self, "_pageView");
        CABasicAnimation *anim = (CABasicAnimation *)[pageView.layer animationForKey:@"transform"];
        [pageView.layer removeAnimationForKey:@"transform"];
        UIView *iconView = MSHookIvar<UIView *>(self, "_iconView");
        [iconView.layer removeAnimationForKey:@"position"];
        [iconView.layer removeAnimationForKey:@"opacity"];
        CGPoint initial = CGPointApplyAffineTransform(CGPointZero, CATransform3DGetAffineTransform([anim.fromValue CATransform3DValue]));
        CGPoint final = CGPointApplyAffineTransform(CGPointZero, CATransform3DGetAffineTransform([anim.toValue CATransform3DValue]));
        CGFloat scale = self._scaleForFullscreenPageView;
        pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scale, scale), 0, initial.y/scale);
        [SengAnimator animateWithActions:^{
            pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, 1), 0, final.y);
        } completion:^(BOOL c){
            completion(c);
        }];
    }
    else {
        [bottomContainerView setGrabberStateOut:YES];
        %orig;
    }
    isAppSwitcherActive = YES;
    [self _bringIconViewToFront];
    for(SBDisplayLayout *disp in displayLayoutsToBeQuitOnSwitcherOpen) {
        [self switcherScroller:self.pageController displayItemWantsToBeRemoved:disp.displayItems[0]];
    }
    [displayLayoutsToBeQuitOnSwitcherOpen removeAllObjects];
}

- (CGFloat)_switcherThumbnailVerticalPositionOffset {
    if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        return -quickSwitcherOrientationWasPortrait ? -80:-50;//-130.0:-100.0;
    }
    else if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        CGFloat middleOfScreen = viewHeight()/2;
        CGFloat iconHeight = [%c(SBAppSwitcherIconView) defaultIconSize].height + (areAppSwitcherIconLabelsHidden?-5:10);
        CGFloat labelHeight =  (areAppSwitcherIconLabelsHidden ? 3 : [%c(SBAppSwitcherIconView) _labelHeight]) + 4;
        CGFloat iconViewOffset = prefsIconStlye == kSengIconStyleHidden ? 0 : prefsIconStlye == kSengIconStyleOverlapped ? labelHeight : iconHeight;
        CGFloat newMiddle = (topContainerView.visibleContentHeight + (viewHeight()-bottomContainerView.visibleContentHeight) - iconViewOffset) /2 - 2;
        return newMiddle-middleOfScreen;
    }
    else {
        return %orig;
    }
}

%new -(void)quitAllApps {
    NSMutableArray *displayLayoutsToKill = [NSMutableArray array];
    SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
    BOOL isPlaying = [mediaController isPlaying];
    SBApplication *nowPlayingApp = [mediaController nowPlayingApplication];
    NSString *playingID = [nowPlayingApp bundleIdentifier];
    for (SBDisplayLayout *display in self.pageController.displayLayouts) {
        SBDisplayItem *dispItem = display.displayItems[0];
        if (! [dispItem.type isEqualToString:@"Homescreen"] && [self.pageController.displayLayouts indexOfObjectIdenticalTo:display] > 0) {
            if ((! [dispItem.displayIdentifier isEqualToString:playingID] || [prefValueForKey(@"closeNowPlaying", NO) boolValue] || ! isPlaying) && ! [whitelistedQuitAllApps containsObject:dispItem.displayIdentifier]) {
                [displayLayoutsToKill addObject:display];
            }
        }
    }
    NSInteger hsIndex = [self.pageController.displayLayouts indexOfObject:[%c(SBDisplayLayout) homeScreenDisplayLayout]];
    [self.iconController setOffsetToIndex:hsIndex animated:YES];
    [self.pageController setOffsetToIndex:hsIndex animated:YES];
    for (SBDisplayLayout *toKill in displayLayoutsToKill) {
        [SengAnimator animateWithActions:^{
            UIView *pView = [self pageForDisplayLayout:toKill];
            if (pView != nil) {
                pView.alpha = 0;
            }
            NSInteger pIndex = [self.pageController.displayLayouts indexOfObjectIdenticalTo:toKill];
            if (pIndex <= MSHookIvar<NSArray *>(self.iconController, "_iconViews").count) {
                UIView *iv = [self.iconController _iconViewForIndex:pIndex];
                if (iv != nil) {
                    iv.alpha = 0;
                }
            }
        }
 completion: ^(BOOL completed) {
            if ([[%c(SBUIController) sharedInstance] isAppSwitcherShowing]) {
                [self switcherScroller:self.pageController displayItemWantsToBeRemoved:toKill.displayItems[0]];
                //[self _quitAppWithDisplayItem:toKill.displayItems[0]];
            }
        }];
    }
    [self resetHomeScrollViewPositionAndForceStayOpen:NO];
}

%new -(void)resetHomeScrollViewPositionAndForceStayOpen:(BOOL)o {
    needsAnimationOverrideForHomeScreenCardReset = YES;
    SBDisplayLayout *hsDisplayLayout = [%c(SBDisplayLayout) homeScreenDisplayLayout];
    UIScrollView *homeScrollView = (UIScrollView *)[self pageForDisplayLayout:hsDisplayLayout].superview;
    homeScrollView.contentOffset = CGPointMake(0, -screenHeight());
    [SengAnimator animateWithActions:^{
        if (homeScrollView) {
            homeScrollView.contentOffset = CGPointMake(0, 0);
        }
    }
    completion: ^(BOOL completed) {
        needsAnimationOverrideForHomeScreenCardReset = NO;
        if ([prefValueForKey(@"dismissAfterQuitAll", YES) boolValue] && ! o) {
            [self switcherScroller:self.pageController itemTapped:hsDisplayLayout animated:YES];
        }
    }];
}

%end

%hook SBAppSwitcherIconController

- (id)_iconViewForIndex:(NSInteger)index {
    if (index == [versionCorrectSwitcherController().pageController.displayLayouts indexOfObject:[%c(SBDisplayLayout) homeScreenDisplayLayout]]) {
        if (hsIconView != nil) {
            hsIconView.hidden = NO;
            if (! [hsIconView isDescendantOfView:MSHookIvar<UIView*>(self, "_iconContainer")]) {
                [MSHookIvar<UIView*>(self, "_iconContainer") addSubview:hsIconView];
            }
            if (overrideCCGestureType == SengOverrideCCGestureTypeAppSwitcher) {
                [hsIconView.layer removeAllAnimations];
                hsIconView.alpha = 1;
            }
        }
        return hsIconView;
    }
    else {
        return %orig;
    }
}

%end

%hook SBAppSwitcherPageViewController

%new -(SBDisplayLayout *)displayLayoutForScrollView:(SBAppSwitcherItemScrollView *)s {
    for (SBDisplayLayout *l in self.displayLayouts) {
        if ([s.item isEqual:[self pageViewForDisplayLayout:l]]) {
            return l;
        }
    }
    return nil;
}

%end

%hook SBControlCenterController

- (void)beginTransitionWithTouchLocation:(CGPoint)location {
    if (isLockScreenActive || overrideCCGestureType == SengOverrideCCGestureTypeDefCC || ((SBControlCenterController *)[%c(SBControlCenterController) sharedInstance]).isPresented || (![prefValueForKey(@"overrideCCGesture",YES) boolValue] && overrideCCGestureType == SengOverrideCCGestureTypeNone)) {
        %orig;
    }
    else if (overrideCCGestureType == SengOverrideCCGestureTypeNone) { // for some reason the keybaord spams this so ensure no gesture is currently happening before proceeding
        if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
            if ([prefValueForKey(@"gestureAnim", YES) boolValue] && ! reduceMotionEnabled) {
                overrideCCGestureType = SengOverrideCCGestureTypeAppSwitcher;
            }
            [[%c(SBUIController) sharedInstance] _activateAppSwitcher];
        }
        else {
            %orig;
        }
    }
}

- (void)updateTransitionWithTouchLocation:(CGPoint)location velocity:(CGPoint)velocity {
    if (isLockScreenActive || overrideCCGestureType == SengOverrideCCGestureTypeDefCC) {
        %orig;
    }
    else if(!currentGestureItemIsDismissing){
        CGFloat sHeight = screenHeight();
        if (overrideCCGestureType == SengOverrideCCGestureTypeCornerLock &&  [prefValueForKey(@"cornerLock", YES) boolValue]) {
            CGFloat heightForProg = isPortrait() ? sHeight/2.5:sHeight/2;
            CGFloat prog = 1 - ((sHeight - location.y) / heightForProg);
            darkeningOverlayForLockOnHS.alpha = 1-prog;
        }
        else if (overrideCCGestureType == SengOverrideCCGestureTypeAppSwitcher && [prefValueForKey(@"gestureAnim", YES) boolValue]) {
            CGFloat heightForProg = sHeight/3;
            CGFloat prog = 1 - ((sHeight - location.y) / (bottomContainerView.visibleContentHeight > heightForProg ? bottomContainerView.visibleContentHeight:heightForProg));
            prog = (prog > 1) ? 1:((prog < -0.1) ? -0.1:prog);
            [[[%c(SBUIController) sharedInstance] switcherController] _updateForAnimationFrame:prog withAnchor:nil];
        }
        else if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
            CGFloat prog = 1 - ((sHeight - location.y) / (screenHeight()/9));
            prog = (prog > 1) ? 1:((prog < 0) ? 0:prog);
            prog = reduceMotionEnabled ? 0:prog;
            SBAppSwitcherController *sController = [[%c(SBUIController) sharedInstance] switcherController];
            [sController _updateForAnimationFrame:prog withAnchor:nil];
            if (! [object_getClass(sController.iconController) isEqual:%c(SengQuickSwitcherIconsController)]) {
                object_setClass(sController.iconController, %c(SengQuickSwitcherIconsController));
            }
            [(SengQuickSwitcherIconsController *)sController.iconController updateTouchLocation:location velocity:velocity];
        }
        else {
            %orig;
        }
    }
}

- (void)endTransitionWithVelocity:(CGPoint)velocity completion:(void (^)(BOOL))comp {
    SBAppSwitcherController *sController = [[%c(SBUIController) sharedInstance] switcherController];
    if (isLockScreenActive || overrideCCGestureType == SengOverrideCCGestureTypeDefCC) {
        %orig;
        overrideCCGestureType = SengOverrideCCGestureTypeNone;
    }
    else if (overrideCCGestureType == SengOverrideCCGestureTypeAppSwitcher) {
        if (velocity.y < 0) {
            [bottomContainerView setGrabberStateOut:YES];
            currentGestureItemIsDismissing = YES;
            [SengAnimator animateWithActions:^{
                [sController _updateForAnimationFrame:0 withAnchor:nil];
            } completion: ^(BOOL c){
                if(comp) {
                    comp(c);
                }
                overrideCCGestureType = SengOverrideCCGestureTypeNone;
                currentGestureItemIsDismissing = NO;
            }];
        }
        else {
            FBWorkspaceEvent *event = [%c(FBWorkspaceEvent) eventWithName:@"seng-AS" handler :^{
                SBAppToAppWorkspaceTransaction *transaction;
                if (! frontMostApplication) {
                    transaction = [[%c(SBAppToAppWorkspaceTransaction) alloc] initWithAlertManager:workspace.alertManager activationRequest:[%c(SBWorkspaceAppsActivationRequest) homeScreenActivationRequest] withResult:nil];
                }
                else {
                    [frontMostApplication notifyResumeActiveForReason:5];
                    [frontMostApplication setObject:@YES forDeactivationSetting:20];
                    [frontMostApplication setObject:@NO forDeactivationSetting:2];
                    transaction = [[%c(SBAppToAppWorkspaceTransaction) alloc] initWithAlertManager:workspace.alertManager activationRequest:[%c(SBWorkspaceAppsActivationRequest) fullScreenActivationRequestForApp:frontMostApplication] withResult:nil];
                }
                [workspace setCurrentTransaction:transaction];
            }];
            currentGestureItemIsDismissing = YES;
            [SengAnimator animateWithActions:^{
                [sController _updateForAnimationFrame:1 withAnchor:nil];
            } completion :^(BOOL c) {
                [(FBWorkspaceEventQueue *)[%c(FBWorkspaceEventQueue) sharedInstance] executeOrAppendEvent:event];
                overrideCCGestureType = SengOverrideCCGestureTypeNone;
                isAppSwitcherActive = NO;
                if(comp) {
                    comp(c);
                }
                currentGestureItemIsDismissing = NO;
            }];
        }
    }
    else if (overrideCCGestureType == SengOverrideCCGestureTypeCornerLock  &&  [prefValueForKey(@"cornerLock", YES) boolValue]) {
        currentGestureItemIsDismissing = YES;
        if (velocity.y < 0) {
            [SengAnimator fastAnimateWithActions:^{
                darkeningOverlayForLockOnHS.alpha = 1;
            } completion:^(BOOL complete) {
                [oldKeyWindowToReplaceOverlayWithOnFinish makeKeyAndVisible];
                [[%c(SBBacklightController) sharedInstance]  setBacklightFactor:0 source:1];
                [[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];
                darkeningOverlayForLockOnHS.hidden = YES;
                overrideCCGestureType = SengOverrideCCGestureTypeNone;
                if(comp){
                    comp(complete);
                }
                currentGestureItemIsDismissing = NO;
            }];
        }
        else {
            [SengAnimator fastAnimateWithActions:^{
                darkeningOverlayForLockOnHS.alpha = 0;
            } completion:^(BOOL complete) {
                [oldKeyWindowToReplaceOverlayWithOnFinish makeKeyAndVisible];
                darkeningOverlayForLockOnHS.hidden = YES;
                FBWorkspaceEvent *event = [%c(FBWorkspaceEvent) eventWithName:@"seng-CL" handler :^{
                    [workspace setCurrentTransaction:[[%c(SBAppToAppWorkspaceTransaction) alloc] initWithAlertManager:workspace.alertManager activationRequest:[%c(SBWorkspaceAppsActivationRequest) homeScreenActivationRequest] withResult:nil]];
                }];
                [(FBWorkspaceEventQueue *)[%c(FBWorkspaceEventQueue) sharedInstance] executeOrAppendEvent:event];
                overrideCCGestureType = SengOverrideCCGestureTypeNone;
                if(comp) {
                    comp(complete);
                }
                currentGestureItemIsDismissing = NO;
            }];
        }
    }
    else if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher && sController.pageController.displayLayouts.count > 0) {
        if ([sController.iconController isKindOfClass:%c(SengQuickSwitcherIconsController)]) {
            SengQuickSwitcherIconsController *iconController = (SengQuickSwitcherIconsController *)sController.iconController;
            [iconController willTerminateQuickSwitcherWithVelocity:velocity];
            currentGestureItemIsDismissing = YES;
            [SengAnimator animateWithActions:^{
                [sController _updateForAnimationFrame:1 withAnchor:nil];
            } completion :^(BOOL c) {
                [iconController didTerminateQuickSwitcher];
                if(comp) {
                    comp(c);
                }
                overrideCCGestureType = SengOverrideCCGestureTypeNone;
                isAppSwitcherActive = NO;
                currentGestureItemIsDismissing = NO;
                object_setClass(sController.iconController, %c(SengStandardIconsController));
            }];
        }
    }
    else {
        %orig;
    }
}

%end

%hook SBUIController

- (void)_showControlCenterGestureBeganWithLocation:(CGPoint)location {
    BOOL gestureNotAllowed = isLockScreenActive || [workspace alertManager].activeAlert != nil || isAppSwitcherActive || ((SBLockStateAggregator *)[%c(SBLockStateAggregator) sharedInstance]).lockState == 2 || [blacklistedApps containsObject:frontMostApplication.displayIdentifier] || frontMostApplication.isActivating || ((SBIconController *)[%c(SBIconController) sharedInstance]).hasAnimatingFolder || workspace.currentTransaction != nil || [frontMostApplication._stateSettings boolForStateSetting:16];
    if (! gestureNotAllowed) {
        CGFloat tolerance = prefValueForKey(@"hotCornerTolerance", NO) ? [prefValueForKey(@"hotCornerTolerance", NO) floatValue]:80.0;
        BOOL onRight = location.x > screenWidth() - tolerance;
        BOOL onLeft = location.x <  tolerance;
        NSInteger leftPref = prefValueForKey(@"leftAction", NO) ? [prefValueForKey(@"leftAction", NO) integerValue]:1;
        NSInteger rightPref = [prefValueForKey(@"rightAction", NO) integerValue];
        SengOverrideCCGestureType leftAction =  leftPref == 0 ? SengOverrideCCGestureTypeCornerHome : leftPref == 1 ? SengOverrideCCGestureTypeQuickSwitcher : leftPref == 3 ? SengOverrideCCGestureTypeCornerQuit : leftPref == 4? SengOverrideCCGestureTypeDefCC : SengOverrideCCGestureTypeNone;
        SengOverrideCCGestureType rightAction = rightPref == 0 ? SengOverrideCCGestureTypeCornerHome : rightPref == 1 ? SengOverrideCCGestureTypeQuickSwitcher : rightPref == 3 ? SengOverrideCCGestureTypeCornerQuit : rightPref == 4? SengOverrideCCGestureTypeDefCC : SengOverrideCCGestureTypeNone;
        if (! frontMostApplication) {
            leftAction = leftAction == SengOverrideCCGestureTypeCornerHome || leftAction == SengOverrideCCGestureTypeCornerQuit ? ([prefValueForKey(@"cornerLock", YES) boolValue] ? SengOverrideCCGestureTypeCornerLock:SengOverrideCCGestureTypeNone):leftAction;
            rightAction = rightAction == SengOverrideCCGestureTypeCornerHome || rightAction == SengOverrideCCGestureTypeCornerQuit ? ([prefValueForKey(@"cornerLock", YES) boolValue] ? SengOverrideCCGestureTypeCornerLock:SengOverrideCCGestureTypeNone):rightAction;
        }
        overrideCCGestureType = onLeft ? leftAction:onRight ? rightAction:overrideCCGestureType;
        if ((overrideCCGestureType == SengOverrideCCGestureTypeCornerHome || overrideCCGestureType == SengOverrideCCGestureTypeCornerQuit) && frontMostApplication) {     // frontMostApplication failsafe
            cornerHomeAnimationView = [(SBGestureViewVendor *)[%c(SBGestureViewVendor) sharedInstance] viewForApp:frontMostApplication gestureType:1 includeStatusBar:YES];
            [[%c(SBUIController) sharedInstance] _installSystemGestureView:cornerHomeAnimationView forKey:[[%c(SBUIController) sharedInstance] _systemGestureViewKeyForApp:frontMostApplication] forGesture:1];
            [[%c(SBUIController) sharedInstance] showSystemGestureBackdrop];
            [frontMostApplication notifyResignActiveForReason:5];
            if (reduceMotionEnabled) {
                [[%c(SBUIController) sharedInstance] tearDownIconListAndBar];
                [[%c(SBUIController) sharedInstance] restoreContentAndUnscatterIconsAnimated:NO];
                [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 0;
                [[%c(SBUIController) sharedInstance] _animateStatusBarForSuspendGesture];
            }
            else if ([prefValueForKey(@"simpleCornerHome", NO) boolValue]) {
                [[%c(SBUIController) sharedInstance] tearDownIconListAndBar];
                [[%c(SBUIController) sharedInstance] restoreContentAndUnscatterIconsAnimated:NO];
            }
            else {
                [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 0;
                [[%c(SBUIController) sharedInstance] _animateStatusBarForSuspendGesture];
            }
        }
        else if (overrideCCGestureType == SengOverrideCCGestureTypeCornerLock) {
            if (! darkeningOverlayForLockOnHS) {
                darkeningOverlayForLockOnHS = [[UIWindow alloc] init];
                darkeningOverlayForLockOnHS.windowLevel = UIWindowLevelStatusBar;
                darkeningOverlayForLockOnHS.backgroundColor = [UIColor blackColor];
            }
            CGFloat bigSide = MAX(screenHeight(), screenWidth());
            darkeningOverlayForLockOnHS.frame = CGRectMake(0, 0, bigSide, bigSide);
            darkeningOverlayForLockOnHS.alpha = 0;
            darkeningOverlayForLockOnHS.hidden = NO;
            darkeningOverlayForLockOnHS.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            oldKeyWindowToReplaceOverlayWithOnFinish = [UIApplication sharedApplication].keyWindow;
            [darkeningOverlayForLockOnHS makeKeyAndVisible];
        }
        else if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
            quickSwitcherOrientationWasPortrait = isPortrait();
            SBAppSwitcherController *sController = [[%c(SBUIController) sharedInstance] switcherController];
            [[%c(SBUIController) sharedInstance] _activateAppSwitcher];
            object_setClass(sController.iconController, %c(SengQuickSwitcherIconsController));
            NSInteger homeIndex = [sController.pageController.displayLayouts indexOfObject:[%c(SBDisplayLayout) homeScreenDisplayLayout]];
            NSInteger startIndex = ! frontMostApplication ? homeIndex:homeIndex+1;
            NSInteger numOfPages = sController.pageController.displayLayouts.count - startIndex;
            switcherIconsPerPage = isPortrait() ? (numOfPages < 4 ? 4:numOfPages < 7 ? numOfPages:7):(numOfPages < 7 ? 7:numOfPages < 11 ? numOfPages:11);
            [sController.iconController reloadInOrientation:[UIApplication sharedApplication].activeInterfaceOrientation];
            [sController.iconController setOffsetToIndex:startIndex animated:NO];
            [sController.pageController setOffsetToIndex:startIndex animated:NO];
            [(SengQuickSwitcherIconsController *)sController.iconController initiateQuickSwitcherWithBaseOffset:location.x startingAtIndex:startIndex];
        }
        %orig;
    }
    else if([blacklistedApps containsObject:frontMostApplication.displayIdentifier]) {
        %orig;
    }
}

- (void)_showControlCenterGestureChangedWithLocation:(CGPoint)location velocity:(CGPoint)velocity duration:(double)arg3 {
    CGFloat sHeight = screenHeight();
    if (overrideCCGestureType == SengOverrideCCGestureTypeCornerHome  || overrideCCGestureType == SengOverrideCCGestureTypeCornerQuit) {
        if (cornerHomeAnimationView != nil && !currentGestureItemIsDismissing) {
            if (reduceMotionEnabled) {
                CGFloat heightForProg = isPortrait() ? sHeight/2.5:sHeight/2;
                CGFloat prog = 1 - ((sHeight - location.y) / heightForProg);
                prog = (prog > 1) ? 1:((prog < 0) ? 0:prog);
                cornerHomeAnimationView.alpha = prog;
                [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 1-prog;
            }
            else {
                if ([prefValueForKey(@"simpleCornerHome", NO) boolValue]) {
                    if (isPortrait()) {
                        cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation(0, -(sHeight - location.y));
                    }
                    else {
                        cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation(-(sHeight - location.y), 0);
                    }
                }
                else {
                    CGFloat heightForProg = isPortrait() ? sHeight/2.5:sHeight/2;
                    CGFloat prog = 1 - ((sHeight - location.y) / heightForProg);
                    prog = (prog > 1) ? 1:((prog < 0) ? 0:prog);
                    cornerHomeAnimationView.transform = CGAffineTransformMakeScale(prog, prog);
                    cornerHomeAnimationView.alpha = (prog > (1.0/3.0) ? (1.0/3.0):prog)*3.0;
                    [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 1-prog;
                }
            }
        }
    }
    %orig;
}

- (void)_showControlCenterGestureEndedWithLocation:(CGPoint)location velocity:(CGPoint)velocity {
    if (overrideCCGestureType == SengOverrideCCGestureTypeCornerHome || overrideCCGestureType == SengOverrideCCGestureTypeCornerQuit) {
        BOOL isGoingHome = velocity.y < 0;
        currentGestureItemIsDismissing = YES;
        void (^completion)(BOOL) = ^(BOOL finished) {
            [[%c(SBUIController) sharedInstance] hideSystemGestureBackdrop];
            [[%c(SBUIController) sharedInstance] setFakeSpringBoardStatusBarVisible:NO];
            if (! frontMostApplication) { // for web apps
                FBWorkspaceEvent *event = [%c(FBWorkspaceEvent) eventWithName:@"seng-CHB" handler :^{
                    [workspace setCurrentTransaction:[[%c(SBAppToAppWorkspaceTransaction) alloc] initWithAlertManager:workspace.alertManager activationRequest:[%c(SBWorkspaceAppsActivationRequest) homeScreenActivationRequest] withResult:nil]];
                }];
                [(FBWorkspaceEventQueue *)[%c(FBWorkspaceEventQueue) sharedInstance] executeOrAppendEvent:event];
            }
            else {
                SBApplication *frontApp = frontMostApplication;
                [[(FBSceneManager *)[%c(FBSceneManager) sharedInstance] sceneWithIdentifier:frontApp.bundleIdentifier].contextHostManager disableHostingForRequester:@"SBUISystemGestureSuspendAppRequester"];
                [[%c(SBUIController) sharedInstance] _clearInstalledSystemGestureViewForKey:[[%c(SBUIController) sharedInstance] _systemGestureViewKeyForApp:frontMostApplication]];
                [frontApp notifyResumeActiveForReason:5];
                if (isGoingHome) {
                    FBWorkspaceEvent *event = [%c(FBWorkspaceEvent) eventWithName:@"seng-CH" handler :^{
                        [frontApp setObject:@YES forDeactivationSetting:20];
                        [frontApp setObject:@NO forDeactivationSetting:2];
                        SBAppToAppWorkspaceTransaction *transaction = [[%c(SBAppToAppWorkspaceTransaction) alloc] initWithAlertManager:workspace.alertManager exitedApp:frontApp];
                        [workspace setCurrentTransaction:transaction];
                    }];
                    [(FBWorkspaceEventQueue *)[%c(FBWorkspaceEventQueue) sharedInstance] executeOrAppendEvent:event];
                    if (overrideCCGestureType == SengOverrideCCGestureTypeCornerQuit) {
                        BKSTerminateApplicationForReasonAndReportWithDescription(frontApp.displayIdentifier, 1, 1, @"Seng killed app.");
                        [displayLayoutsToBeQuitOnSwitcherOpen addObject:[%c(SBDisplayLayout) fullScreenDisplayLayoutForApplication:frontApp]];
                    }
                    if (! [prefValueForKey(@"simpleCornerHome", NO) boolValue] && ! reduceMotionEnabled) {
                        [[%c(SBUIController) sharedInstance] tearDownIconListAndBar];
                        [[%c(SBUIController) sharedInstance] restoreContentAndUnscatterIconsAnimated:YES];
                    }
                }
                else {
                    FBWorkspaceEvent *event = [%c(FBWorkspaceEvent) eventWithName:@"seng-CHB" handler :^{
                        [workspace setCurrentTransaction:[[%c(SBAppToAppWorkspaceTransaction) alloc] initWithAlertManager:workspace.alertManager activationRequest:[%c(SBWorkspaceAppsActivationRequest) fullScreenActivationRequestForApp:frontMostApplication] withResult:nil]];
                    }];
                    [(FBWorkspaceEventQueue *)[%c(FBWorkspaceEventQueue) sharedInstance] executeOrAppendEvent:event];
                }
            }
            %orig;
            overrideCCGestureType = SengOverrideCCGestureTypeNone;
            currentGestureItemIsDismissing = NO;
        };
        if (isGoingHome) {
            if (reduceMotionEnabled) {
                [SengAnimator fastAnimateWithActions :^{
                    [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 1;
                    cornerHomeAnimationView.alpha = 0;
                } completion: completion];
            }
            else if ([prefValueForKey(@"simpleCornerHome", NO) boolValue]) {
                [SengAnimator fastAnimateWithActions:^{
                    if (isPortrait()) {
                        cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation(0, -screenHeight());
                    }
                    else {
                        cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation(-screenHeight(), 0);
                    }
                } completion: completion];
            }
            else {
                [SengAnimator fastAnimateWithActions:^{
                    [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 1;
                    cornerHomeAnimationView.alpha = 0;
                    cornerHomeAnimationView.transform = CGAffineTransformMakeScale(0.001, 0.001);
                } completion: completion];
            }
        }
        else {
            if (reduceMotionEnabled) {
                [SengAnimator fastAnimateWithActions :^{
                    [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 0;
                    cornerHomeAnimationView.alpha = 1;
                } completion: completion];
            }
            else if ([prefValueForKey(@"simpleCornerHome", NO) boolValue]) {
                [SengAnimator fastAnimateWithActions:^{
                    cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion: completion];
            }
            else {
                [SengAnimator fastAnimateWithActions:^{
                    [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 0;
                    cornerHomeAnimationView.alpha = 1;
                    cornerHomeAnimationView.transform = CGAffineTransformMakeScale(1, 1);
                } completion: completion];
            }
        }
    }
    else {
        %orig;
    }
}

- (BOOL)clickedMenuButton {
    overrideCCGestureType = SengOverrideCCGestureTypeNone;
    return %orig;
}

- (BOOL)handleMenuDoubleTap {
    overrideCCGestureType = SengOverrideCCGestureTypeNone;
    return %orig;
}

- (BOOL)shouldUseAmbiguousControlCenterActivation {
    if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        return [blacklistedApps containsObject:frontMostApplication.displayIdentifier];
    }
    else {
        return %orig;
    }
}

- (BOOL)shouldShowControlCenterTabControlOnFirstSwipe {
    // stop CC tab showing in fullscreen app so gesture goes straight to switcher
    if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        return [blacklistedApps containsObject:frontMostApplication.displayIdentifier];
    }
    else {
        return %orig;
    }
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:LIST_PATH]) {
        sengSBAlertItemPiracy *alertItem = [[%c(sengSBAlertItemPiracy) alloc] init];
        [[%c(SBAlertItemsController) sharedInstance] activateAlertItem:alertItem animated:YES];
    }
}

%end

%hook SBAppSwitcherItemScrollView

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    if([prefValueForKey(@"multiCentreEnabled", YES) boolValue] && [prefValueForKey(@"gestureAnim", YES) boolValue] && !reduceMotionEnabled) {
        SBAppSwitcherController *switcherController = versionCorrectSwitcherController();
        CGPoint velocity = [recognizer velocityInView:self];
        CGPoint translatedPoint = [recognizer translationInView:self];
        if(recognizer.state == UIGestureRecognizerStateBegan) {
            if(wantsPanGestureOverrideForDismissGesture) {
                return;
            }
            else if(velocity.y > 0 && translatedPoint.y >= 0) {
                wantsPanGestureOverrideForDismissGesture = YES;
                [bottomContainerView setGrabberStateOut:NO];
                NSInteger index = [switcherController.pageController.displayLayouts indexOfObjectIdenticalTo:[switcherController.pageController displayLayoutForScrollView:self]];
                [switcherController.pageController setOffsetToIndex:index animated:YES];
                [switcherController.iconController setOffsetToIndex:index animated:YES];
                SBAppSwitcherSnapshotView * sv = [switcherController _snapshotViewForDisplayItem:[switcherController.pageController displayLayoutForScrollView:self].displayItems[0]];
                if(sv != nil){
                    MSHookIvar<BOOL>(sv,"_needsZoomUpImage") = YES;
                    if(!MSHookIvar<UIView*>(sv,"_zoomUpSnapshotView")) {
                        [sv _crossfadeToZoomUpViewIfNecessary];
                    }
                    else {
                        MSHookIvar<UIView*>(sv,"_zoomUpSnapshotView").hidden = NO;
                        MSHookIvar<UIView*>(sv,"_zoomUpSnapshotView").alpha = 1;
                        MSHookIvar<UIView*>(sv,"_snapshotImageView").hidden = YES;
                        MSHookIvar<UIView*>(sv,"_snapshotImageView").alpha = 0;
                    }
                }
            }
            else {
                %orig;
            }
        }
        else if(recognizer.state == UIGestureRecognizerStateChanged) {
            if(wantsPanGestureOverrideForDismissGesture) {
                CGFloat heightForProg = 64;
                CGFloat prog = translatedPoint.y / heightForProg;
                prog = prog<0?0:prog>1?1:prog;
                [switcherController _updateForAnimationFrame:prog withAnchor:nil];
            }
            else {
                %orig;
            }
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded) {
            if(wantsPanGestureOverrideForDismissGesture) {
                SBDisplayLayout * layout = [switcherController.pageController displayLayoutForScrollView:self];
                if(velocity.y > 0) {
                    currentGestureItemIsDismissing = YES;
                    [SengAnimator animateWithActions:^{
                        [switcherController _updateForAnimationFrame:1 withAnchor:nil];
                    } completion:^(BOOL complete) {
                        [switcherController switcherScroller:self itemTapped:layout animated:NO];
                        isAppSwitcherActive = NO;
                        wantsPanGestureOverrideForDismissGesture = NO;
                        currentGestureItemIsDismissing = NO;
                    }];
                }
                else {
                    wantsPanGestureOverrideForDismissGesture = NO;
                    [bottomContainerView setGrabberStateOut:YES];
                    [SengAnimator animateWithActions:^{
                        [switcherController _updateForAnimationFrame:0 withAnchor:nil];
                    } completion:^(BOOL c){
                        SBAppSwitcherSnapshotView * sv = [switcherController _snapshotViewForDisplayItem:layout.displayItems[0]];
                        if(sv) {
                            MSHookIvar<UIView*>(sv,"_zoomUpSnapshotView").hidden = YES;
                            MSHookIvar<UIView*>(sv,"_zoomUpSnapshotView").alpha = 0;
                            MSHookIvar<UIView*>(sv,"_snapshotImageView").hidden = NO;
                            MSHookIvar<UIView*>(sv,"_snapshotImageView").alpha = 1;
                        }
                    }];
                }
            }
            else {
                %orig;
            }
        }
    }
    else {
        %orig;
    }
}

%end

%hook SBAppSwitcherIconView

- (void)setFrame:(CGRect)frame {
    if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        %orig(CGRectMake(CGRectGetMinX(frame), 0/*110*/, CGRectGetWidth(frame), CGRectGetHeight(frame)));
    }
    else if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        self.transform = CGAffineTransformIdentity;
        self.hidden = NO;
        if (prefsIconStlye == kSengIconStyleOverlapped) {
            CGFloat offset = -[%c(SBAppSwitcherIconView) defaultIconSize].height + 22;
            %orig(CGRectMake(CGRectGetMinX(frame), offset, CGRectGetWidth(frame), CGRectGetHeight(frame)));
        }
        else {
            %orig(CGRectMake(CGRectGetMinX(frame), 8, CGRectGetWidth(frame), CGRectGetHeight(frame)));
        }
    }
    else {
        %orig;
    }
}

%end

%end //SENG_IOS_8
