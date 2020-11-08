#import "SharedDefs.h"

static NSInteger _startingIndex;
static NSInteger _currentIndex;
static NSInteger _indexOffset;
static BOOL _timerRunning;
static NSTimer *_incDecTimer;
static CGPoint _currentTouchLocation;
static _UIBackdropView *_indicatorView;
static CGFloat _baseTouchOffset;
static BOOL _overrideForOpenAnim;
static BOOL _needsPageScrollAnimation;
static NSInteger _previousIndex;

static BOOL _useAlternatQuickSwitcher;
static CGFloat _basePagePositionOffset;
static CGFloat _scrollMultiplier;
static CGFloat _moveLeftThreshold;
static CGFloat _moveRightThreshold;
static CGFloat _scrollIncrement = 0.6;

static inline NSArray *switcherItems() {
    if(([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9))
        return versionCorrectSwitcherController().pageController.displayItems;
    else
        return versionCorrectSwitcherController().pageController.displayLayouts;
}

%subclass SengQuickSwitcherIconsController : SBAppSwitcherIconController

- (CGFloat)iconLabelWidth {
    return 70;
}

- (BOOL)_isIndexVisible:(unsigned long long)index withPadding:(BOOL)padding {
    return YES;
}

%new - (void)initiateQuickSwitcherWithBaseOffset:(CGFloat)o startingAtIndex:(NSInteger)index {
    [self _iconViewForIndex:index].tag = kSengQuickSwitcherDodgyIconFixFix;
    [[self _iconViewForIndex:index] layoutSubviews];
    _currentIndex = _indexOffset = _startingIndex = index;
    [self updateIconsForIndex:_currentIndex animated:NO];
    _useAlternatQuickSwitcher = NO;//[[SengShared prefsDic][@"altQS"] boolValue];
    if(_useAlternatQuickSwitcher) {
        _baseTouchOffset = o;
        CGFloat d = [versionCorrectSwitcherController().pageController _distanceBetweenCenters];
        _scrollMultiplier = [versionCorrectSwitcherController().pageController _maxXOffset] + d*2;
        _scrollMultiplier = _scrollMultiplier<2000?2000:_scrollMultiplier;
        _moveLeftThreshold = 0;
        _moveRightThreshold = viewWidth() - _moveLeftThreshold;
        _basePagePositionOffset = index * d;
        [self updateTouchLocation:CGPointMake(o, 0) velocity:CGPointZero];
        if (_indicatorView) {
            [_indicatorView removeFromSuperview];
        }
        _overrideForOpenAnim = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            _needsPageScrollAnimation = YES;
        });
    }
    else {
        _baseTouchOffset = o - viewWidth()/[SengShared switcherIconsPerPage]/2;
        if (! _indicatorView) {
            _indicatorView = [[_UIBackdropView alloc] initWithStyle:2060];
            _indicatorView.layer.cornerRadius = 17;
            _indicatorView.layer.masksToBounds = YES;
        }
        if (! [_indicatorView isDescendantOfView:self.view]) {
            [self.view insertSubview:_indicatorView atIndex:0];
        }
        if(IS_IOS_(9,0)) {
            _indicatorView.frame = CGRectMake(0, 0, [%c(SBIconView) defaultIconSize].width + 12, 350);
        }
        else {
            _indicatorView.frame = CGRectMake(0, -106 + ([SengShared areAppSwitcherIconLabelsHidden]?19:0) , [objc_getClass("SBIconView") defaultIconSize].width + 12, 300);
        }
        _indicatorView.hidden = NO;
        _overrideForOpenAnim = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            _needsPageScrollAnimation = YES;
        });
        [self _updateVisibleIconViewsWithPadding:YES];
    }
}

%new - (void)updateTouchLocation:(CGPoint)location velocity:(CGPoint)velocity {
    if(_useAlternatQuickSwitcher) {
        if (_overrideForOpenAnim && ! _needsPageScrollAnimation) {

        }
        else if(_needsPageScrollAnimation){
            _baseTouchOffset = location.x;
            _needsPageScrollAnimation = NO;
            _overrideForOpenAnim = NO;
        }
        else {
            if (! _timerRunning) {
                if (location.x < _moveLeftThreshold) {
                    _timerRunning = YES;
                    _incDecTimer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(decreaseBaseOffset) userInfo:nil repeats:YES];
                }
                else if (location.x > _moveRightThreshold) {
                    _timerRunning = YES;
                    _incDecTimer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(increaseBaseOffset) userInfo:nil repeats:YES];
                }
            }
            if (location.x >= _moveLeftThreshold && location.x <= _moveRightThreshold) {
                _timerRunning = NO;
                [_incDecTimer invalidate];
                CGFloat progX = (location.x-_baseTouchOffset+_moveLeftThreshold)/(_moveRightThreshold-_moveLeftThreshold);
                CGFloat pageScrollerOffset = progX*_scrollMultiplier;
                [self setScrollViewOffset:pageScrollerOffset];
            }
        }
    }
    else {
        if (_overrideForOpenAnim && ! _needsPageScrollAnimation) {
            _currentTouchLocation = CGPointMake(viewWidth()*0.5/[SengShared switcherIconsPerPage], 0);
        }
        else {
            _currentTouchLocation = location;
        }

        SBAppSwitcherController *switcherController = versionCorrectSwitcherController();
        NSInteger numberOfPages = switcherItems().count;
        CGFloat progX = _currentTouchLocation.x/viewWidth();

        if ((numberOfPages-_indexOffset) < [SengShared switcherIconsPerPage] && progX > (numberOfPages-_indexOffset-0.5)/[SengShared switcherIconsPerPage]) {
            _currentTouchLocation.x = (numberOfPages-_indexOffset-0.5)/[SengShared switcherIconsPerPage] * viewWidth();
        }
        else if (_indexOffset == 0 && progX < 0.5/[SengShared switcherIconsPerPage]) {
            _currentTouchLocation.x = 0.5/[SengShared switcherIconsPerPage] * viewWidth();
        }
        else if (_indexOffset == numberOfPages - [SengShared switcherIconsPerPage] && progX > 1 - 0.5/[SengShared switcherIconsPerPage]) {
            _currentTouchLocation.x = (1 - 0.5/[SengShared switcherIconsPerPage]) * viewWidth();
        }
        progX = _currentTouchLocation.x/viewWidth();
        if(IS_IOS_(9,0)) {
            CGFloat prog = 1 - ((viewHeight() - location.y) / (viewHeight()/9));
            prog = (prog > 1) ? 1:((prog < 0) ? 0:prog);
            prog = [SengShared reduceMotionEnabled] ? 0 : prog;
            _indicatorView.center = CGPointMake(_currentTouchLocation.x, (isLandscape()?-165:-200) + ([SengShared areAppSwitcherIconLabelsHidden]?19:0) + (CGRectGetHeight(_indicatorView.frame)*prog) + CGRectGetHeight(_indicatorView.frame)/2 + (IS_IPHONE_6P ? 9 : 0));
        }
        else {
            _indicatorView.center = CGPointMake(_currentTouchLocation.x, _indicatorView.center.y);
        }

        CGFloat distanceBetweenPages = switcherController.pageController._distanceBetweenCenters;
        CGFloat distanceBetweenIcons = self._distanceBetweenCenters;
        CGFloat totalOffset = distanceBetweenPages * [SengShared switcherIconsPerPage];

        CGFloat activePageOffset = ((progX-(0.5/[SengShared switcherIconsPerPage]))*totalOffset) + (_indexOffset * distanceBetweenPages);
        activePageOffset = activePageOffset > switcherController.pageController._maxXOffset ? switcherController.pageController._maxXOffset : activePageOffset < 0 ? 0 : activePageOffset;
        UIScrollView *pageScrollView = MSHookIvar<UIScrollView *>(switcherController.pageController, "_scrollView");
        if (_needsPageScrollAnimation) {
            [SengAnimator animateWithActions:^{
                pageScrollView.contentOffset = CGPointMake(activePageOffset, 0);
            }];
            _needsPageScrollAnimation = NO;
            _overrideForOpenAnim = NO;
        }
        else {
            pageScrollView.contentOffset = CGPointMake(activePageOffset, 0);
        }

        UIScrollView *iconScrollView = MSHookIvar<UIScrollView *>(self, "_scrollView");
        CGFloat activeIconOffset = viewWidth()/2 + (_indexOffset * distanceBetweenIcons) - (distanceBetweenIcons/2);
        iconScrollView.contentOffset = CGPointMake(activeIconOffset + (IS_IOS_(9,0)?[objc_getClass("SBAppSwitcherIconView") defaultIconSize].width/2:0), 0);

        NSInteger nearestIndex = floor(progX * [SengShared switcherIconsPerPage]) + _indexOffset;
        nearestIndex = nearestIndex<0 ? 0 : nearestIndex>numberOfPages-1 ? numberOfPages-1 : nearestIndex;
        if (nearestIndex != _currentIndex) {
            _previousIndex = _currentIndex;
            _currentIndex = nearestIndex;
            [self updateIconsForIndex:_currentIndex animated:YES];
        }

        if (! _timerRunning && progX < 0.25/[SengShared switcherIconsPerPage]) {
            _timerRunning = YES;
            _incDecTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(decreaseBaseOffset) userInfo:nil repeats:YES];
        }
        else if (! _timerRunning && progX > 1.0 - 0.25/[SengShared switcherIconsPerPage]) {
            _timerRunning = YES;
            _incDecTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(increaseBaseOffset) userInfo:nil repeats:YES];
        }
        else if (progX > 0.25/[SengShared switcherIconsPerPage] && progX < 1 - 0.25/[SengShared switcherIconsPerPage]) {
            [_incDecTimer invalidate];
            _timerRunning = NO;
        }
    }
}

%new - (void)increaseBaseOffset {
    if(_useAlternatQuickSwitcher) {
        CGFloat progX = (_moveRightThreshold-_baseTouchOffset+_moveLeftThreshold)/(_moveRightThreshold-_moveLeftThreshold);
        CGFloat pageScrollerOffset = progX*_scrollMultiplier;
        if (_basePagePositionOffset+pageScrollerOffset < [versionCorrectSwitcherController().pageController _maxXOffset]) {
            _basePagePositionOffset+=_scrollIncrement;
        }
        [self setScrollViewOffset:pageScrollerOffset];
    }
    else {
        if (_indexOffset < switcherItems().count - [SengShared switcherIconsPerPage]) {
            _indexOffset++;
            [SengAnimator animateWithActions:^{
                [self updateTouchLocation:_currentTouchLocation velocity:CGPointZero];
            }];
        }
    }
}

%new - (void)decreaseBaseOffset {
    if(_useAlternatQuickSwitcher) {
        CGFloat progX = (_moveLeftThreshold-_baseTouchOffset+_moveLeftThreshold)/(_moveRightThreshold-_moveLeftThreshold);
        CGFloat pageScrollerOffset = progX*_scrollMultiplier;
        if (_basePagePositionOffset+pageScrollerOffset > 0) {
            _basePagePositionOffset-=_scrollIncrement;
        }
        [self setScrollViewOffset:pageScrollerOffset];
    }
    else {
        if (_indexOffset > 0) {
            _indexOffset--;
            [SengAnimator animateWithActions:^{
                [self updateTouchLocation:_currentTouchLocation velocity:CGPointZero];
            }];
        }
    }
}

%new -(void)setScrollViewOffset:(CGFloat)offset {
    CGFloat pageScrollerOffset = offset + _basePagePositionOffset;
    SBAppSwitcherController* sController = versionCorrectSwitcherController();
    CGFloat maxOffset = [sController.pageController _maxXOffset];
    pageScrollerOffset = pageScrollerOffset > maxOffset ? maxOffset:pageScrollerOffset < 0 ? 0:pageScrollerOffset;
    UIScrollView* pageScrollView = MSHookIvar<UIScrollView*>(sController.pageController, "_scrollView");
    pageScrollView.contentOffset = CGPointMake(pageScrollerOffset, pageScrollView.contentOffset.y);
    maxOffset = maxOffset==0?1000:maxOffset;
    CGFloat progX = maxOffset == 0 ? 0:pageScrollerOffset/maxOffset;
    NSInteger numOfPages = switcherItems().count;
    UIScrollView* iconScrollView = MSHookIvar<UIScrollView*>(self, "_scrollView");
    CGFloat iconScrollerOffset = progX * (numOfPages-1)* [%c(SBAppSwitcherIconController) nominalDistanceBetween3IconCentersForSize : CGSizeMake(0, 0)];
    iconScrollerOffset = iconScrollerOffset > iconScrollView.contentSize.width ? iconScrollView.contentSize.width:iconScrollerOffset < 0 ? 0:iconScrollerOffset;
    iconScrollView.contentOffset = CGPointMake(iconScrollerOffset, iconScrollView.contentOffset.y);
    NSInteger nearestIndex = floor(progX * numOfPages);
    nearestIndex = nearestIndex<0 ? 0:nearestIndex>numOfPages-1 ? numOfPages-1:nearestIndex;
    if (nearestIndex != _currentIndex) {
        _currentIndex = nearestIndex;
        [self updateIconsForIndex:_currentIndex animated:YES];
    }
}

%new - (void)updateIconsForIndex:(NSInteger)index animated:(BOOL)anim {
    if(index != _startingIndex && [self _iconViewForIndex:_startingIndex].tag == kSengQuickSwitcherDodgyIconFixFix)
        [self _iconViewForIndex:_startingIndex].tag = 0;
    for (int i = 0; i < switcherItems().count; i++) {
        CGFloat scale = (i == index) ? 1.0 : (i == index-1 || i == index+1) ? 0.5 : (i == index-2 || i == index+2) ? 0.4 : 0.4;
        CGFloat offset = (i == index) ? -80.0 : (i == index-1 || i == index+1) ? 60 : (i == index-2 || i == index+2) ? 120 : (i == index-3 || i == index+3) ? 170 : 200;
        BOOL showing = i >= index - [SengShared switcherIconsPerPage] && i <= index + [SengShared switcherIconsPerPage];
        if ([self _iconViewForIndex:i]) {
            SBIconView *iv = (SBIconView *)[self _iconViewForIndex:i];
            if (anim) {
                [SengAnimator fastAnimateWithActions:^{
                    iv.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scale,scale), 0, offset);
                    MSHookIvar<UIView *>(iv, "_labelView").alpha = i==index;
                }];
            }
            else {
                iv.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scale,scale), 0, offset);
                MSHookIvar<UIView *>(iv, "_labelView").alpha = i==index;
            }
            iv.hidden = ! showing;
        }
    }
}

%new - (NSInteger)getCurrentIndex {
    return _currentIndex;
}

%new - (void)willTerminateQuickSwitcherWithVelocity:(CGPoint)velocity {
    [_incDecTimer invalidate];
    SBAppSwitcherController *switcherController = versionCorrectSwitcherController();
    [switcherController.pageController setOffsetToIndex:_currentIndex animated:YES];
    id switcherItem = switcherItems()[_currentIndex];
    if(([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9)) {
        SBAppSwitcherSnapshotView *sv = [switcherController _snapshotViewForDisplayItem:switcherItem];
        MSHookIvar<BOOL>(sv,"_needsZoomUpImage") = YES;
        [sv _crossfadeToZoomUpViewIfNecessaryForTransitionRequest:nil];
    }
    else {
        SBAppSwitcherSnapshotView *sv = [switcherController _snapshotViewForDisplayItem:((SBDisplayLayout*)switcherItem).displayItems[0]];
        MSHookIvar<BOOL>(sv,"_needsZoomUpImage") = YES;
        [sv _crossfadeToZoomUpViewIfNecessary];
    }
}

%new - (void)didTerminateQuickSwitcher {
    SBAppSwitcherController *switcherController = versionCorrectSwitcherController();
    id switcherItem = switcherItems()[_currentIndex];
    [switcherController switcherScroller:switcherController.pageController itemTapped:switcherItem animated:[SengShared reduceMotionEnabled]];
    _indicatorView.hidden = YES;
    for (int i = 0; i < switcherItems().count; i++) {
        if ([self _iconViewForIndex:i]) {
            UIView *iv = [self _iconViewForIndex:i];
            iv.transform = CGAffineTransformIdentity;
        }
    }
}

%end

%subclass SengStandardIconsController : SBAppSwitcherIconController
%new - (void)decreaseBaseOffset {}
%new - (void)increaseBaseOffset {}
%new - (NSInteger)getCurrentIndex {
    return _currentIndex;
}
%new - (void)willTerminateQuickSwitcherWithVelocity:(CGPoint)velocity {}
%new - (void)didTerminateQuickSwitcher {}
%end
