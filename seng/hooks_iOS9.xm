
static SBWorkspaceApplication *cornerHomeGoBackToApplication;
static void(^completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked)(BOOL);

static BOOL stopDismissalDuringNonInteractivePresentation;

%group SENG_IOS_9

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;

    if (! [[NSFileManager defaultManager] fileExistsAtPath:LIST_PATH]) {
        sengSBAlertItemPiracy *alertItem = [[%c(sengSBAlertItemPiracy) alloc] init];
        [[%c(SBAlertItemsController) sharedInstance] activateAlertItem:alertItem animated:YES];
    }

    BOOL useForce = [prefValueForKey(@"forceToSwitchApp", YES) boolValue];

    panLeft = useForce ? [[%c(SengSBForceScreenEdgePanGestureRecognizer) alloc] initWithTarget:self action:@selector(leftEdgePan:)]
                       : [[%c(SengSBScreenEdgePanGestureRecognizer) alloc] initWithTarget:self action:@selector(leftEdgePan:)];
    [panLeft setEdges:UIRectEdgeLeft];
    [[%c(FBSystemGestureManager) sharedInstance] addGestureRecognizer:panLeft toDisplay:[%c(FBDisplayManager) mainDisplay]];

    panRight = useForce ? [[%c(SengSBForceScreenRightEdgePanGestureRecognizer) alloc] initWithTarget:self action:@selector(rightEdgePan:)]
                        : [[%c(SengSBScreenEdgePanGestureRecognizer) alloc] initWithTarget:self action:@selector(rightEdgePan:)];
    [panRight setEdges:UIRectEdgeRight];
    [[%c(FBSystemGestureManager) sharedInstance] addGestureRecognizer:panRight toDisplay:[%c(FBDisplayManager) mainDisplay]];

    panLeft.enabled = panRight.enabled = [prefValueForKey(@"swipeToSwitchApp", YES) boolValue] && UIInterfaceOrientationIsPortrait([(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation]);
}

- (void)noteInterfaceOrientationChanged:(UIInterfaceOrientation)orientation duration:(CGFloat)arg2 updateMirroredDisplays:(BOOL)arg3 force:(BOOL)arg4{
    %orig;
    panLeft.enabled = panRight.enabled = [prefValueForKey(@"swipeToSwitchApp", YES) boolValue] && UIInterfaceOrientationIsPortrait(orientation);
}

%new -(void)leftEdgePan:(UIScreenEdgePanGestureRecognizer *)r {
    CGPoint touchPoint = [r locationInView: [UIApplication sharedApplication].keyWindow];
    BOOL inZone = [prefValueForKey(@"swipeToSwitchAppZone", NO) integerValue]==3 ? touchPoint.y < screenHeight()/3 :
                  [prefValueForKey(@"swipeToSwitchAppZone", NO) integerValue]==2 ?  touchPoint.y > screenHeight()/3 && touchPoint.y < 2*screenHeight()/3 :
                  [prefValueForKey(@"swipeToSwitchAppZone", NO) integerValue]==1 ? touchPoint.y > 2 * screenHeight()/3 :
                  YES;

    if(![prefValueForKey(@"swipeToSwitchApp", YES) boolValue] || (r.state == UIGestureRecognizerStateBegan && ([%c(SBWorkspace) mainWorkspace].currentTransaction || frontMostApplication == nil || !inZone))) {
        r.enabled = NO;
        r.enabled = YES;
    }
    else {
        MSHookIvar<id>([%c(SBUIController) sharedInstance],"_switchAppSystemGestureRecognizer") = r;
        [[%c(SBUIController) sharedInstance] _handleSwitchAppGesture:r];
    }
}

%new -(void)rightEdgePan:(UIScreenEdgePanGestureRecognizer *)r {
    CGPoint touchPoint = [r locationInView: [UIApplication sharedApplication].keyWindow];
    BOOL inZone = [prefValueForKey(@"swipeToSwitchAppZone", NO) integerValue]==3 ? touchPoint.y < screenHeight()/3 :
                  [prefValueForKey(@"swipeToSwitchAppZone", NO) integerValue]==2 ?  touchPoint.y > screenHeight()/3 && touchPoint.y < 2*screenHeight()/3 :
                  [prefValueForKey(@"swipeToSwitchAppZone", NO) integerValue]==1 ? touchPoint.y > 2 * screenHeight()/3 :
                  YES;
    if(![prefValueForKey(@"swipeToSwitchApp", YES) boolValue] || (r.state == UIGestureRecognizerStateBegan && ([%c(SBWorkspace) mainWorkspace].currentTransaction || frontMostApplication == nil || !inZone))) {
        r.enabled = NO;
        r.enabled = YES;
    }
    else {
        MSHookIvar<id>([%c(SBUIController) sharedInstance],"_switchAppSystemGestureRecognizer") = r;
        [[%c(SBUIController) sharedInstance] _handleSwitchAppGesture:r];
    }
}

%end

%hook SBSwitchAppList

static BOOL defaultAppList = NO;

- (id)applicationBundleIDBeforeBundleID:(id)arg1{
    if(defaultAppList)
        return %orig;
    defaultAppList = YES;
    id ret = [self applicationBundleIDAfterBundleID:arg1];
    defaultAppList = NO;
    return ret;
}

- (id)applicationBundleIDAfterBundleID:(id)arg1 {
    if(defaultAppList)
        return %orig;
    defaultAppList = YES;
    id ret = [self applicationBundleIDBeforeBundleID:arg1];
    defaultAppList = NO;
    return ret;
}

%end

%hook SBAppSwitcherSettings

-(long long) switcherStyle {
    if([prefValueForKey(@"multiCentreEnabled", YES) boolValue] || overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher)
        return 0;
    return %orig;
}

-(void) setSwitcherStyle:(long long)s {
    if([prefValueForKey(@"multiCentreEnabled", YES) boolValue] || overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher)
        %orig(0);
    else
        %orig;
}

-(void)setDefaultValues {
    %orig;
    if([prefValueForKey(@"multiCentreEnabled", YES) boolValue] || overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher)
        self.switcherStyle = 0;
}

%end

%hook SBAppSwitcherPageView

-(void)addSubview:(UIView*)a {
    if([a isKindOfClass:%c(SBOrientationTransformWrapperView)] && [prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        a.frame = CGRectMake(-viewWidth()/3,-viewHeight()/3,viewWidth(),viewHeight());
    }
    %orig;
}

%end

%hook SBAppSwitcherSnapshotView

- (void)layoutSubviews {
    %orig;
    self.clipsToBounds = YES;
}

- (void)setClipsToBounds:(BOOL)s {
    %orig(YES);
}

%end

%hook SBMainSwitcherGestureCoordinator

- (void)handleSwitcherForcePressGesture:(id)arg1 {
    if(![prefValueForKey(@"multiCentreEnabled", YES) boolValue])
        %orig;
}

%end

%hook SBMainSwitcherViewController

- (BOOL)toggleSwitcherNoninteractively {
    if([prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        if([self isVisible])
            return [self dismissSwitcherNoninteractively];
        else
            return [self activateSwitcherNoninteractively];
    }
    else
        return %orig;
}

- (BOOL)activateSwitcherNoninteractively {
    switcherJustOpenedFromApp = frontMostApplication != nil;
    return %orig;
}

- (BOOL)dismissSwitcherNoninteractively {
    if([prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        if(![versionCorrectSwitcherController() respondsToSelector:@selector(_inMode:)])
            return NO;
        if(![versionCorrectSwitcherController() _inMode:2])
            return NO;
    }
    return %orig;
}

- (void)performPresentationAnimationForTransitionRequest:(id)request withCompletion:(void(^)(BOOL))completion {
    if(![prefValueForKey(@"multiCentreEnabled", YES) boolValue] && overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher) {
        %orig;
    }
    else if(overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher || overrideCCGestureType == SengOverrideCCGestureTypeAppSwitcher) {
        completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked = completion;
        %orig(request,NULL);
    }
    else {
        stopDismissalDuringNonInteractivePresentation = YES;
        void (^newComp)(BOOL) = ^(BOOL finished) {
            stopDismissalDuringNonInteractivePresentation = NO;
            completion(finished);
        };
        %orig(request,newComp);
    }
}

%end

%hook SBAppSwitcherController

- (void)_updatePageViewScale:(CGFloat)s xTranslation:(CGFloat)xT {
    if(overrideCCGestureType != SengOverrideCCGestureTypeNone || wantsPanGestureOverrideForDismissGesture) {
        CGFloat progress = 1 - (s - 1)/(self._scaleForFullscreenPageView-1);
        UIView *pageView = MSHookIvar<UIView *>(self, "_pageView");
        pageView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(s,s),CGAffineTransformMakeTranslation(xT*progress,progress*self._switcherThumbnailVerticalPositionOffset));
    }
    else {
        %orig;
    }
}

- (void)animatePresentationForTransitionRequest:(id)request withCompletion:(void(^)(BOOL))completion {
    BOOL mcEnabled = [prefValueForKey(@"multiCentreEnabled", YES) boolValue];
    if (mcEnabled && overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher) {
        [self updateMediaPlayingIndicator];
        UIView * contentView = MSHookIvar<UIView*>([%c(SBMainSwitcherViewController) sharedInstance],"_contentView");
        [contentView addSubview:topContainerView];
        [topContainerView viewWillAppear];
        [contentView addSubview:bottomContainerView];
        [bottomContainerView viewWillAppear];
        if(nineForceReload) {
            forceReload = YES;
            [self setupViews];
            forceReload = NO;
            nineForceReload = NO;
        }
        if (lastSwitcherOrientationLandscape != isLandscape()) {
            lastSwitcherOrientationLandscape = isLandscape();
            [self setupViews];
        }
        if (isLandscape() &&  overrideCCGestureType != SengOverrideCCGestureTypeQuickSwitcher && needsFixForLandscape) {
            CGFloat sizeForSwitcher = viewHeight();
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
        %orig(request, NULL);
        UIView *pageView = MSHookIvar<UIView *>(self, "_pageView");
        [pageView.layer removeAnimationForKey:@"transform"];
        UIView *iconView = MSHookIvar<UIView *>(self, "_iconView");
        [iconView.layer removeAnimationForKey:@"position"];
        [iconView.layer removeAnimationForKey:@"opacity"];
        completion(YES);
    }
    else {
        [bottomContainerView setGrabberStateOut:YES];
            %orig(request, NULL);
            UIView *pageView = MSHookIvar<UIView *>(self, "_pageView");
            CABasicAnimation *anim = (CABasicAnimation *)[pageView.layer animationForKey:@"transform"];
            [pageView.layer removeAnimationForKey:@"transform"];
            CGPoint initial = CGPointApplyAffineTransform(CGPointZero, CATransform3DGetAffineTransform([anim.fromValue CATransform3DValue]));
            CGPoint final = CGPointApplyAffineTransform(CGPointZero, CATransform3DGetAffineTransform([anim.toValue CATransform3DValue]));
            CGFloat scale = self._scaleForFullscreenPageView;
            pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scale, scale), initial.x/scale, initial.y/scale);
            if(reduceMotionEnabled) {
                pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, 1), final.x, final.y + self._switcherThumbnailVerticalPositionOffset);
                completion(YES);
            }
            else {
                [SengAnimator animateWithActions:^{
                    pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, 1), final.x, final.y + self._switcherThumbnailVerticalPositionOffset);
                } completion:^(BOOL c){
                    completion(c);
                }];
            }
    }
    isAppSwitcherActive = YES;
    [self _bringIconViewToFront];
}

- (void)animateDismissalToDisplayItem:(id)dispItem forTransitionRequest:(id)request withCompletion:(void(^)(BOOL))completion {
    UIView *pageView = MSHookIvar<UIView *>(self, "_pageView");
    if (overrideDismissSwitcherAnimation) {
        %orig(dispItem, request, NULL);
        [pageView.layer removeAnimationForKey:@"transform"];
        UIView *iconView = MSHookIvar<UIView *>(self, "_iconView");
        [iconView.layer removeAnimationForKey:@"position"];
        [iconView.layer removeAnimationForKey:@"position-2"];
        [iconView.layer removeAnimationForKey:@"opacity"];
        isAppSwitcherActive = NO;
        topContainerView.hidden = YES;
        [topContainerView removeFromSuperview];
        bottomContainerView.hidden = YES;
        [bottomContainerView removeFromSuperview];
        completion(YES);
    }
    else {
        [bottomContainerView setGrabberStateOut:NO];
        void (^newComp)(BOOL) = ^(BOOL c) {
            isAppSwitcherActive = NO;
            topContainerView.hidden = YES;
            [topContainerView removeFromSuperview];
            bottomContainerView.hidden = YES;
            [bottomContainerView removeFromSuperview];
            completion(c);
        };
        if(reduceMotionEnabled) {
            %orig(dispItem,request,newComp);
        }
        else {
            %orig(dispItem,request,NULL);
            CABasicAnimation *anim = (CABasicAnimation *)[pageView.layer animationForKey:@"transform"];
            [pageView.layer removeAnimationForKey:@"transform"];
            CGPoint initial = CGPointApplyAffineTransform(CGPointZero, CATransform3DGetAffineTransform([anim.fromValue CATransform3DValue]));
            CGPoint final = CGPointApplyAffineTransform(CGPointZero, CATransform3DGetAffineTransform([anim.toValue CATransform3DValue]));
            CGFloat scale = self._scaleForFullscreenPageView;
            pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, 1), 0, self._switcherThumbnailVerticalPositionOffset);
            [SengAnimator animateWithActions:^{
                pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scale, scale), -initial.x, final.y);
            } completion:newComp];
        }
        [self _bringIconViewToFront];
    }
    [topContainerView viewDidDisappear];
    [bottomContainerView viewDidDisappear];
}

%new -(id)pageController {
    return MSHookIvar<id>(self,"_pageController");
}

%new -(void)quitAllApps {
    NSMutableArray *displayItemsToKill = [NSMutableArray array];
    SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
    BOOL isPlaying = [mediaController isPlaying];
    SBApplication *nowPlayingApp = [mediaController nowPlayingApplication];
    NSString *playingID = [nowPlayingApp bundleIdentifier];
    for (SBDisplayItem *dispItem in self.pageController.displayItems) {
        if (! [dispItem.type isEqualToString:@"Homescreen"] && [self.pageController.displayItems indexOfObjectIdenticalTo:dispItem] > 0) {
            if ((! [dispItem.displayIdentifier isEqualToString:playingID] || [prefValueForKey(@"closeNowPlaying", NO) boolValue] || ! isPlaying) && ! [whitelistedQuitAllApps containsObject:dispItem.displayIdentifier]) {
                [displayItemsToKill addObject:dispItem];
            }
        }
    }
    NSInteger hsIndex = [self.pageController.displayItems indexOfObject:[%c(SBDisplayItem) homeScreenDisplayItem]];
    [self.iconController setOffsetToIndex:hsIndex animated:YES];
    [self.pageController setOffsetToIndex:hsIndex animated:YES];
    for (SBDisplayItem *toKill in displayItemsToKill) {
        [SengAnimator animateWithActions:^{
            UIView *pView = [self.pageController pageViewForDisplayItem:toKill];
            if (pView != nil) {
                pView.alpha = 0;
            }
            NSInteger pIndex = [self.pageController.displayItems indexOfObjectIdenticalTo:toKill];
            if (pIndex < self.pageController.displayItems.count) {
                UIView *iv = [self.iconController _iconViewForIndex:pIndex];
                if (iv != nil) {
                    iv.alpha = 0;
                }
            }
        }
         completion: ^(BOOL completed) {
            if ([[%c(SBUIController) sharedInstance] isAppSwitcherShowing]) {
                [self switcherScroller:self.pageController displayItemWantsToBeRemoved:toKill];
            }
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self resetHomeScrollViewPositionAndForceStayOpen:NO];
    });
}

%new - (CGFloat)_switcherThumbnailVerticalPositionOffset {
    if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        return quickSwitcherOrientationWasPortrait ? -80:-50;//-130.0:-100.0;
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
        return 0;
    }
}

%new -(void)resetHomeScrollViewPositionAndForceStayOpen:(BOOL)o {
    needsAnimationOverrideForHomeScreenCardReset = YES;
    SBDisplayItem *hsDisplayItem = [%c(SBDisplayItem) homeScreenDisplayItem];
    UIScrollView *homeScrollView = (UIScrollView *)((UIView*)[self.pageController pageViewForDisplayItem:hsDisplayItem]).superview;
    homeScrollView.contentOffset = CGPointMake(0, -viewHeight());
    [SengAnimator animateWithActions:^{
        if (homeScrollView) {
            homeScrollView.contentOffset = CGPointMake(0, 0);
        }
    }
    completion: ^(BOOL completed) {
        needsAnimationOverrideForHomeScreenCardReset = NO;
        if ([prefValueForKey(@"dismissAfterQuitAll", YES) boolValue] && ! o) {
            [self switcherScroller:self.pageController itemTapped:hsDisplayItem animated:YES];
        }
    }];
}

%end

%hook SBAppSwitcherPageViewController

-(id)valueForKey:(NSString*)k {
    // DODGY FIX FOR CCSETTINGS
    if([k isEqualToString:@"_displayLayouts"])
        return self.displayItems;
    return %orig;
}

%new -(SBDisplayItem *)displayItemForScrollView:(SBAppSwitcherItemScrollView *)s {
    for (SBDisplayItem *l in self.displayItems) {
        if ([s.item isEqual:[self pageViewForDisplayItem:l]]) {
            return l;
        }
    }
    return nil;
}

%end

%hook SBAppSwitcherIconController

- (id)_iconViewForIndex:(NSInteger)index {
    if (index == [versionCorrectSwitcherController().pageController.displayItems indexOfObject:[%c(SBDisplayItem) homeScreenDisplayItem]]) {
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

- (CGPoint)_adjustedCenter:(CGPoint)arg1 forIconView:(id)arg2 {
    if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue] || overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
        CGFloat scrollViewOrigin = versionCorrectSwitcherController().iconController.view.frame.origin.y;
        CGFloat desiredScreenPosition = viewHeight()/2.0 + versionCorrectSwitcherController()._switcherThumbnailVerticalPositionOffset + viewHeight() * [objc_getClass("SBAppSwitcherController") pageScale]/2.0 - (prefsIconStlye == kSengIconStyleOverlapped?[objc_getClass("SBAppSwitcherIconView") defaultIconSize].height:20) + (areAppSwitcherIconLabelsHidden?35:28);
        if(overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
            desiredScreenPosition = isPortrait() ? viewHeight()-200 : viewHeight()-120;
        }
        CGFloat iconViewFinalOrigin = desiredScreenPosition - scrollViewOrigin;
        return CGPointMake(%orig.x,iconViewFinalOrigin + [objc_getClass("SBAppSwitcherIconView") defaultIconSize].height/2);
    }
    return %orig;
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
                SBDisplayItem *dispItem = [switcherController.pageController displayItemForScrollView:self];
                NSInteger index = [switcherController.pageController.displayItems indexOfObjectIdenticalTo:dispItem];
                [switcherController.pageController setOffsetToIndex:index animated:YES];
                [switcherController.iconController setOffsetToIndex:index animated:YES];
                SBAppSwitcherSnapshotView * sv = [switcherController _snapshotViewForDisplayItem:dispItem];
                if(sv != nil){
                    MSHookIvar<BOOL>(sv,"_needsZoomUpImage") = YES;
                    [sv _crossfadeToZoomUpViewIfNecessaryForTransitionRequest:nil];
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
                SBDisplayItem * dispItem = [switcherController.pageController displayItemForScrollView:self];
                if(velocity.y > 0) {
                    currentGestureItemIsDismissing = YES;
                    [SengAnimator animateWithActions:^{
                        [switcherController _updateForAnimationFrame:1 withAnchor:nil];
                    } completion:^(BOOL complete) {
                        [switcherController switcherScroller:self itemTapped:dispItem animated:NO];
                        isAppSwitcherActive = NO;
                        wantsPanGestureOverrideForDismissGesture = NO;
                        currentGestureItemIsDismissing = NO;
                    }];
                }
                else {
                    [bottomContainerView setGrabberStateOut:YES];
                    [SengAnimator animateWithActions:^{
                        [switcherController _updateForAnimationFrame:0 withAnchor:nil];
                    } completion:^(BOOL c){
                        wantsPanGestureOverrideForDismissGesture = NO;
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

static UIInterfaceOrientation gestureStartedInOrientation;
static BOOL firstChange;

%subclass SengCornerHomeGestureRecognizer : SBScreenEdgePanGestureRecognizer

%new -(CGFloat)cumulativePercentage {
    //TODO FIX THIS SOMETIMES BEING WRONG
    CGPoint touchPoint = [self locationInView: [UIApplication sharedApplication].keyWindow];
    CGFloat sH = screenHeight();
    if(!IS_IPHONE_6P) {
        if([(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation] == UIInterfaceOrientationLandscapeLeft) {
            touchPoint = CGPointMake(touchPoint.y,touchPoint.x);
        }
        else if ([(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation] == UIInterfaceOrientationLandscapeRight) {
            touchPoint = CGPointMake(touchPoint.y,screenHeight() - touchPoint.x);
        }
    }
    else if(UIInterfaceOrientationIsLandscape(gestureStartedInOrientation)) {
        sH = screenWidth();
    }
    CGFloat prog = 2 * (sH - touchPoint.y)/sH;
    return -prog;
}

%new -(long long)projectedCompletionTypeForInterval:(CGFloat)interval {
    CGPoint velocity = [self velocityInView:versionCorrectSwitcherController().view];
    UIInterfaceOrientation o = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    return (isPortrait()?velocity.y:o==UIInterfaceOrientationLandscapeLeft?velocity.x:-velocity.x) < 0 ? 1 : -1;
}

%end

static SBApplication *applicationToCloseForCornerQuit;

%hook SBControlCenterController

%new -(BOOL)updateTransitionWithLocation:(CGPoint)location velocity:(CGPoint)velocity andState:(UIGestureRecognizerState)state fromRecognizer:(id)rec {
    BOOL gestureNotAllowed = overrideCCGestureType != SengOverrideCCGestureTypeNone || isLockScreenActive || [[%c(SBWorkspace) mainWorkspace] alertManager].activeAlert != nil || isAppSwitcherActive || ((SBLockStateAggregator *)[%c(SBLockStateAggregator) sharedInstance]).lockState == 2 || [blacklistedApps containsObject:frontMostApplication.bundleIdentifier] || frontMostApplication.isActivating || ((SBIconController *)[%c(SBIconController) sharedInstance]).hasAnimatingFolder  || [%c(SBWorkspace) mainWorkspace].currentTransaction != nil || [frontMostApplication._stateSettings boolForStateSetting:16];
    SBAppSwitcherController *sController = versionCorrectSwitcherController();
    if (isLockScreenActive || overrideCCGestureType == SengOverrideCCGestureTypeDefCC || ((SBControlCenterController *)[%c(SBControlCenterController) sharedInstance]).isPresented) {
        if((state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) && overrideCCGestureType == SengOverrideCCGestureTypeDefCC)
            overrideCCGestureType = SengOverrideCCGestureTypeNone;
        return YES;
    }
    else if(!gestureNotAllowed && state == UIGestureRecognizerStateBegan) {
        firstChange = YES;
        gestureStartedInOrientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
        if(gestureStartedInOrientation == UIInterfaceOrientationLandscapeLeft) {
            location = CGPointMake((IS_IPHONE_6P && UIInterfaceOrientationIsLandscape(gestureStartedInOrientation)?screenHeight():screenWidth())-location.y,location.x);
        }
        else if(gestureStartedInOrientation == UIInterfaceOrientationLandscapeRight) {
            location = CGPointMake(location.y,screenWidth()-location.x);
        }
        CGFloat tolerance = prefValueForKey(@"hotCornerTolerance", NO) ? [prefValueForKey(@"hotCornerTolerance", NO) floatValue]:80.0;
        BOOL onRight = location.x > (IS_IPHONE_6P && UIInterfaceOrientationIsLandscape(gestureStartedInOrientation)?screenHeight():screenWidth()) - tolerance;
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
            applicationToCloseForCornerQuit = frontMostApplication;
            object_setClass(rec,%c(SengCornerHomeGestureRecognizer));
            MSHookIvar<id>([%c(SBUIController) sharedInstance],"_scrunchSystemGestureRecognizer") = rec;
            [[%c(SBUIController) sharedInstance] _handleScrunchGesture:rec];
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
            hackyFixForAppSwitcherOpenGesture = YES;
            quickSwitcherOrientationWasPortrait = isPortrait();

            if(![prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
                MSHookIvar<SBAppSwitcherSettings*>([%c(SBMainSwitcherViewController) sharedInstance],"_settings").switcherStyle = 0;
                [[%c(SBMainSwitcherViewController) sharedInstance] _updateContentViewControllerClassFromSettings];
            }

            [[%c(SBMainSwitcherViewController) sharedInstance] activateSwitcherNoninteractively];
            SBAppSwitcherController *sController = versionCorrectSwitcherController();
            object_setClass(sController.iconController, %c(SengQuickSwitcherIconsController));
            NSInteger homeIndex = [sController.pageController.displayItems indexOfObject:[%c(SBDisplayItem) homeScreenDisplayItem]];
            NSInteger startIndex = ! switcherJustOpenedFromApp ? homeIndex:homeIndex+1;
            NSInteger numOfPages = MSHookIvar<NSArray*>([%c(SBMainSwitcherViewController) sharedInstance],"_displayItems").count - startIndex;
            switcherIconsPerPage = isPortrait() ? (numOfPages < 4 ? 4:numOfPages < 7 ? numOfPages:7):(numOfPages < 7 ? 7:numOfPages < 11 ? numOfPages:11);
            [sController.iconController reloadInOrientation:[UIApplication sharedApplication].activeInterfaceOrientation];
            [sController.iconController setOffsetToIndex:startIndex animated:NO];
            [sController.pageController setOffsetToIndex:startIndex animated:NO];
            [(SengQuickSwitcherIconsController *)sController.iconController initiateQuickSwitcherWithBaseOffset:location.x startingAtIndex:startIndex];
        }
        else if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue] && [prefValueForKey(@"overrideCCGesture",YES) boolValue] && overrideCCGestureType == SengOverrideCCGestureTypeNone) {
            if ([prefValueForKey(@"gestureAnim", YES) boolValue] && ! reduceMotionEnabled) {
                overrideCCGestureType = SengOverrideCCGestureTypeAppSwitcher;
            }
            hackyFixForAppSwitcherOpenGesture = overrideCCGestureType == SengOverrideCCGestureTypeAppSwitcher;
            [[%c(SBMainSwitcherViewController) sharedInstance] activateSwitcherNoninteractively];
        }
        else {
            return YES;
        }
    }
    else if(!currentGestureItemIsDismissing && state == UIGestureRecognizerStateChanged) {
        if (overrideCCGestureType == SengOverrideCCGestureTypeCornerHome  || overrideCCGestureType == SengOverrideCCGestureTypeCornerQuit) {
            object_setClass(rec,%c(SengCornerHomeGestureRecognizer));
            MSHookIvar<id>([%c(SBUIController) sharedInstance],"_scrunchSystemGestureRecognizer") = rec;
            [[%c(SBUIController) sharedInstance] _handleScrunchGesture:rec];
        }
        else if (overrideCCGestureType == SengOverrideCCGestureTypeCornerLock &&  [prefValueForKey(@"cornerLock", YES) boolValue]) {
            CGFloat sHeight = screenHeight();
            if(gestureStartedInOrientation == UIInterfaceOrientationLandscapeLeft) {
                sHeight = screenWidth();
                location = CGPointMake(screenHeight()-location.y,location.x);
            }
            else if(gestureStartedInOrientation == UIInterfaceOrientationLandscapeRight) {
                sHeight = screenWidth();
                location = CGPointMake(location.y,screenWidth()-location.x);
            }
            CGFloat heightForProg = isPortrait() ? sHeight/2.5:sHeight/2;
            CGFloat prog = 1 - ((sHeight - location.y) / heightForProg);
            if(firstChange) {
                [SengAnimator fastAnimateWithActions:^{
                    darkeningOverlayForLockOnHS.alpha = 1-prog;
                }];
                firstChange = NO;
            }
            else
                darkeningOverlayForLockOnHS.alpha = 1-prog;
        }
        else if (overrideCCGestureType == SengOverrideCCGestureTypeAppSwitcher && [prefValueForKey(@"gestureAnim", YES) boolValue]) {
            CGFloat heightForProg = viewHeight()/3;
            CGFloat prog = 1 - ((viewHeight() - location.y) / (bottomContainerView.visibleContentHeight > heightForProg ? bottomContainerView.visibleContentHeight:heightForProg));
            prog = (prog > 1) ? 1:((prog < -0.1) ? -0.1:prog);
            if(firstChange) {
                SBAppSwitcherPageView *page = [versionCorrectSwitcherController().pageController pageViewForDisplayItem:[%c(SBDisplayItem) homeScreenDisplayItem]];
                if (page) MSHookIvar<UIView *>(page.view, "_wallpaperView").alpha = 0;
                [SengAnimator fastAnimateWithActions:^{
                    [versionCorrectSwitcherController() _updateForAnimationFrame:prog withAnchor:nil];
                }];
                firstChange = NO;
            }
            else
                [versionCorrectSwitcherController() _updateForAnimationFrame:prog withAnchor:nil];
        }
        else if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher) {
            CGFloat prog = 1 - ((viewHeight() - location.y) / (viewHeight()/9));
            prog = (prog > 1) ? 1:((prog < 0) ? 0:prog);
            prog = reduceMotionEnabled ? 0:prog;
            SBAppSwitcherController *sController = versionCorrectSwitcherController();
            if(firstChange) {
                SBAppSwitcherPageView *page = [versionCorrectSwitcherController().pageController pageViewForDisplayItem:[%c(SBDisplayItem) homeScreenDisplayItem]];
                if (page) MSHookIvar<UIView *>(page.view, "_wallpaperView").alpha = 0;
                [SengAnimator fastAnimateWithActions:^{
                    [sController _updateForAnimationFrame:prog withAnchor:nil];
                }];
                firstChange = NO;
            }
            else {
                [sController _updateForAnimationFrame:prog withAnchor:nil];
            }
            if (! [object_getClass(sController.iconController) isEqual:%c(SengQuickSwitcherIconsController)]) {
                object_setClass(sController.iconController, %c(SengQuickSwitcherIconsController));
            }
            [(SengQuickSwitcherIconsController *)sController.iconController updateTouchLocation:location velocity:velocity];
        }
        else {
            return YES;
        }
    }
    else if(state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        firstChange = NO;
        if (overrideCCGestureType == SengOverrideCCGestureTypeCornerHome || overrideCCGestureType == SengOverrideCCGestureTypeCornerQuit) {
            object_setClass(rec,%c(SengCornerHomeGestureRecognizer));
            MSHookIvar<id>([%c(SBUIController) sharedInstance],"_scrunchSystemGestureRecognizer") = rec;
            [[%c(SBUIController) sharedInstance] _handleScrunchGesture:rec];
            if(gestureStartedInOrientation == UIInterfaceOrientationLandscapeLeft) {
                velocity = CGPointMake(0,velocity.x);
            }
            else if(gestureStartedInOrientation == UIInterfaceOrientationLandscapeRight) {
                velocity = CGPointMake(0,-velocity.x);
            }
            if (velocity.y < 0 && overrideCCGestureType == SengOverrideCCGestureTypeCornerQuit) {
                [[%c(SBMainSwitcherViewController) sharedInstance] _quitAppRepresentedByDisplayItem:[%c(SBDisplayItem) displayItemWithType:@"App" displayIdentifier:applicationToCloseForCornerQuit.bundleIdentifier] forReason:0];
            }
            overrideCCGestureType = SengOverrideCCGestureTypeNone;
        }
        else if (overrideCCGestureType == SengOverrideCCGestureTypeAppSwitcher) {
            if (velocity.y < 0) {
                [bottomContainerView setGrabberStateOut:YES];
                currentGestureItemIsDismissing = YES;
                [SengAnimator animateWithActions:^{
                    [sController _updateForAnimationFrame:0 withAnchor:nil];
                } completion: ^(BOOL c){
                    if(completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked) {
                        completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked(c);
                        completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked = nil;
                    }
                    overrideCCGestureType = SengOverrideCCGestureTypeNone;
                    currentGestureItemIsDismissing = NO;
                }];
            }
            else {
                currentGestureItemIsDismissing = YES;
                [SengAnimator animateWithActions:^{
                    [sController _updateForAnimationFrame:1.0 withAnchor:nil];
                } completion:^(BOOL c) {
                    if(completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked) {
                        completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked(YES);
                        completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked = nil;
                    }
                    [versionCorrectSwitcherController() switcherScroller:self itemTapped:[versionCorrectSwitcherController().pageController.displayItems objectAtIndex:versionCorrectSwitcherController().pageController.currentPage] animated:NO];
                    overrideCCGestureType = SengOverrideCCGestureTypeNone;
                    isAppSwitcherActive = NO;
                    currentGestureItemIsDismissing = NO;
                }];
            }
        }
        else if (overrideCCGestureType == SengOverrideCCGestureTypeCornerLock  &&  [prefValueForKey(@"cornerLock", YES) boolValue]) {
            currentGestureItemIsDismissing = YES;
            if(gestureStartedInOrientation == UIInterfaceOrientationLandscapeLeft) {
                velocity = CGPointMake(0,velocity.x);
            }
            else if(gestureStartedInOrientation == UIInterfaceOrientationLandscapeRight) {
                velocity = CGPointMake(0,-velocity.x);
            }
            if (velocity.y < 0) {
                [SengAnimator fastAnimateWithActions:^{
                    darkeningOverlayForLockOnHS.alpha = 1;
                } completion:^(BOOL complete) {
                    [oldKeyWindowToReplaceOverlayWithOnFinish makeKeyAndVisible];
                    [[%c(SBBacklightController) sharedInstance]  setBacklightFactor:0 source:1];
                    [[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];
                    darkeningOverlayForLockOnHS.hidden = YES;
                    overrideCCGestureType = SengOverrideCCGestureTypeNone;
                    currentGestureItemIsDismissing = NO;
                }];
            }
            else {
                [SengAnimator fastAnimateWithActions:^{
                    darkeningOverlayForLockOnHS.alpha = 0;
                } completion:^(BOOL complete) {
                    [oldKeyWindowToReplaceOverlayWithOnFinish makeKeyAndVisible];
                    darkeningOverlayForLockOnHS.hidden = YES;
                    overrideCCGestureType = SengOverrideCCGestureTypeNone;
                    currentGestureItemIsDismissing = NO;
                }];
            }
        }
        else if (overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher && MSHookIvar<NSArray*>([%c(SBMainSwitcherViewController) sharedInstance],"_displayItems").count > 0) {
            if ([sController.iconController isKindOfClass:%c(SengQuickSwitcherIconsController)]) {
                SengQuickSwitcherIconsController *iconController = (SengQuickSwitcherIconsController *)sController.iconController;
                if(completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked) {
                    completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked(YES);
                    completionBlockForSwitcherPresentationSoGestureRecognizerDoesntGetFucked = nil;
                }
                [iconController willTerminateQuickSwitcherWithVelocity:velocity];
                currentGestureItemIsDismissing = YES;

                void (^finishBlock)(BOOL) = ^(BOOL finished) {
                    [iconController didTerminateQuickSwitcher];
                    overrideCCGestureType = SengOverrideCCGestureTypeNone;
                    isAppSwitcherActive = NO;
                    currentGestureItemIsDismissing = NO;
                    object_setClass(sController.iconController, %c(SengStandardIconsController));
                    if(![prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
                        MSHookIvar<SBAppSwitcherSettings*>([%c(SBMainSwitcherViewController) sharedInstance],"_settings").switcherStyle = 1;
                        [[%c(SBMainSwitcherViewController) sharedInstance] _updateContentViewControllerClassFromSettings];
                    }
                };

                if(reduceMotionEnabled) {
                    weirdReduceMotionQuickSwitcherFix = YES;
                    finishBlock(YES);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        weirdReduceMotionQuickSwitcherFix = NO;
                    });
                }
                else {
                    [SengAnimator animateWithActions:^{
                        [sController _updateForAnimationFrame:1.0 withAnchor:nil];
                    } completion: finishBlock];
                }
            }
        }
        else {
            return YES;
        }
    }
    return NO;
}

- (void)_handleShowControlCenterGesture:(UIScreenEdgePanGestureRecognizer*)rec {
    CGPoint location = [rec locationInView:versionCorrectSwitcherController().view];
    CGPoint velocity = [rec velocityInView:versionCorrectSwitcherController().view];
    if([self updateTransitionWithLocation:location velocity:velocity andState:rec.state fromRecognizer:rec]) %orig;
}

- (BOOL)_shouldShowGrabberOnFirstSwipe {
    // stop CC tab showing in fullscreen app so gesture goes straight to switcher
    if ([prefValueForKey(@"multiCentreEnabled", YES) boolValue]) {
        return [blacklistedApps containsObject:frontMostApplication.bundleIdentifier];
    }
    else {
        return %orig;
    }
}

%new - (void)startDismissWithGrabber {
    overrideCCGestureType = SengOverrideCCGestureTypeAppSwitcher;
}

%end

%hook SBIconImageView

%property (nonatomic,retain) UIImage *fixedImage;

- (void)setIcon:(SBIcon*)arg1 location:(int)arg2 animated:(_Bool)arg3 {
    if([self.superview isKindOfClass:%c(SBAppSwitcherIconView)]) {
        self.fixedImage = [arg1 generateIconImage:2];
    }
    %orig;
}

-(id)contentsImage {
    if([self.superview isKindOfClass:%c(SBAppSwitcherIconView)] && ([prefValueForKey(@"multiCentreEnabled", YES) boolValue] || overrideCCGestureType == SengOverrideCCGestureTypeQuickSwitcher)) {
        if(!self.fixedImage)
            self.fixedImage = [self.icon generateIconImage:2];
        return self.fixedImage;
    }
    else {
        return %orig;
    }
}

%end

%end

/*if(cornerHomeAnimationView)
    [cornerHomeAnimationView removeFromSuperview];
cornerHomeAnimationView = [%c(SBUIController) zoomViewWithIOSurfaceSnapshotOfApp:frontMostApplication sceneID:frontMostApplication.mainSceneID screen:[UIScreen mainScreen] statusBarDescriptor:nil];
cornerHomeGoBackToApplication = [%c(SBWorkspaceApplication) entityForApplication:frontMostApplication actions:0];
[[UIApplication sharedApplication].keyWindow addSubview:cornerHomeAnimationView];
SBWorkspaceTransitionRequest *request = [[%c(SBWorkspace) mainWorkspace] createRequestWithOptions:0x5];
[request setSource:0xc];
[request setEventLabel:@"SengCornerHome"];
[request modifyApplicationContext:^(SBWorkspaceApplicationTransitionContext *context) {
    SBWorkspaceHomeScreenEntity *hsEntity = [%c(SBWorkspaceHomeScreenEntity) entity];
    [context setEntity:hsEntity forLayoutRole:0x2];
    return;
}];
[[%c(SBWorkspace) mainWorkspace] executeTransitionRequest:request];
if(![prefValueForKey(@"simpleCornerHome", NO) boolValue] && !reduceMotionEnabled)
    [[%c(SBUIController) sharedInstance] tearDownIconListAndBar];*/
/*if(gestureStartedInOrientation == UIInterfaceOrientationLandscapeLeft) {
    location = CGPointMake(0,location.x);
}
else if(gestureStartedInOrientation == UIInterfaceOrientationLandscapeRight) {
    location = CGPointMake(0,viewWidth()-location.x);
}
if (cornerHomeAnimationView != nil && !currentGestureItemIsDismissing) {
    CGFloat heightForProg = [prefValueForKey(@"simpleCornerHome", NO) boolValue] ? sHeight : UIInterfaceOrientationIsPortrait(gestureStartedInOrientation) ? sHeight/2.5 : viewWidth()/2;
    CGFloat prog = 1 - (((UIInterfaceOrientationIsPortrait(gestureStartedInOrientation)?sHeight:viewWidth()) - location.y) / heightForProg);
    prog = (prog > 1) ? 1:((prog < 0) ? 0:prog);
    if (reduceMotionEnabled) {
        if(firstChange) {
            [SengAnimator fastAnimateWithActions:^{
                cornerHomeAnimationView.alpha = prog;
                [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 1-prog;
            }];
            firstChange = NO;
        }
        else {
            cornerHomeAnimationView.alpha = prog;
            [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 1-prog;
        }
    }
    else {
        if ([prefValueForKey(@"simpleCornerHome", NO) boolValue]) {
            if(firstChange) {
                [SengAnimator fastAnimateWithActions:^{
                    if (UIInterfaceOrientationIsPortrait(gestureStartedInOrientation)) {
                        cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation(0, sHeight*(prog-1));
                    }
                    else {
                        cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation((gestureStartedInOrientation == UIInterfaceOrientationLandscapeRight?-1:1)*sHeight*(prog-1), 0);
                    }
                }];
                firstChange = NO;
            }
            else {
                if (UIInterfaceOrientationIsPortrait(gestureStartedInOrientation)) {
                    cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation(0, sHeight*(prog-1));
                }
                else {
                    cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation((gestureStartedInOrientation == UIInterfaceOrientationLandscapeRight?-1:1)*sHeight*(prog-1), 0);
                }
            }
        }
        else {
            if(firstChange) {
                [SengAnimator fastAnimateWithActions:^{
                    cornerHomeAnimationView.transform = CGAffineTransformMakeScale(prog, prog);
                    cornerHomeAnimationView.alpha = (prog > (1.0/3.0) ? (1.0/3.0):prog)*3.0;
                    [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 1-prog;
                }];
                firstChange = NO;
            }else {
                cornerHomeAnimationView.transform = CGAffineTransformMakeScale(prog, prog);
                cornerHomeAnimationView.alpha = (prog > (1.0/3.0) ? (1.0/3.0):prog)*3.0;
                [[%c(SBUIController) sharedInstance] _fakeSpringBoardStatusBar].alpha = 1-prog;
            }
        }
    }
}*/
/*    currentGestureItemIsDismissing = YES;
    void (^completion)(BOOL) = ^(BOOL finished) {
        if (!isGoingHome) {
            SBWorkspaceTransitionRequest *request = [[%c(SBWorkspace) mainWorkspace] createRequestForApplicationActivation:cornerHomeGoBackToApplication options:0];
            [request setEventLabel:@"SengCornerHome"];
            [request setSource:0xc];
            [[%c(SBWorkspace) mainWorkspace] executeTransitionRequest:request];
        }
        else {
            if (! [prefValueForKey(@"simpleCornerHome", NO) boolValue] && ! reduceMotionEnabled) {
                [[%c(SBUIController) sharedInstance] restoreContentAndUnscatterIconsAnimated:YES];
            }
        }
        overrideCCGestureType = SengOverrideCCGestureTypeNone;
        currentGestureItemIsDismissing = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [cornerHomeAnimationView removeFromSuperview];
            cornerHomeAnimationView = nil;
        });
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
                if (UIInterfaceOrientationIsPortrait(gestureStartedInOrientation)) {
                    cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation(0, -viewHeight());
                }
                else {
                    cornerHomeAnimationView.transform = CGAffineTransformMakeTranslation((gestureStartedInOrientation == UIInterfaceOrientationLandscapeRight?1:-1)*viewHeight(), 0);
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
    }*/
