#import "Headers.h"

typedef enum {
    SengContainerViewLayoutTop,
    SengContainerViewLayoutBottom,
} SengContainerViewLayout;

typedef enum {
    SengOverrideCCGestureTypeNone,
    SengOverrideCCGestureTypeCornerHome,
    SengOverrideCCGestureTypeCornerLock,
    SengOverrideCCGestureTypeAppSwitcher,
    SengOverrideCCGestureTypeQuickSwitcher,
    SengOverrideCCGestureTypeCornerQuit,
    SengOverrideCCGestureTypeDefCC,
} SengOverrideCCGestureType;

@interface sengSBCCButtonLikeSectionSplitView:SBCCButtonLikeSectionSplitView
@end

@interface SengSectionView:UIView <SBControlCenterSectionViewControllerDelegate> {
    SBControlCenterSectionViewController *_controller;
    UIView *_contentView;
}
- (NSString *)sectionID;
- (CGFloat)sectionHeight;
- (instancetype)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos;
- (SBControlCenterSectionViewController *)controller;
- (UIView *)contentView;
- (void)setIsInScrollView:(BOOL)s;
- (void)viewWillAppear;
- (void)viewDidDisappear;
@end

@interface SengAirStuffSectionView:SengSectionView
@end
@interface SengBrightnessSectionView:SengSectionView
@end
@interface SengMediaSectionView:SengSectionView
@end
@interface SengMediaTitlesSectionView:SengSectionView
@end
@interface SengMediaButtonsSectionView:SengSectionView
@end
@interface SengMediaScrubberSectionView:SengSectionView
@end
@interface SengPeopleSectionView:SengSectionView
@end
@interface SengQuickLaunchSectionView:SengSectionView
@end
@interface SengSettingsSectionView:SengSectionView
@end
@interface SengScrollSectionView:SengSectionView <UIScrollViewDelegate> {
    UIScrollView *_scrollView;
    NSString *_sizeKey;
    NSString *_layoutKey;
    CGFloat _pageHeight;
    NSArray *_defaults;
    NSInteger _pageCount;
    SengContainerViewLayout _currentLayout;
    NSMutableArray *_activeSections;
    NSDictionary *_prefsDic;
    NSInteger _currentPage;
}
- (void)updateForLayout:(SengContainerViewLayout)layout;
@end
@interface SengSmallScrollSectionView:SengScrollSectionView {
    UIVisualEffectView *_bgView;
}
@end
@interface SengBigScrollSectionView:SengScrollSectionView
@end
@interface SengVolumeSectionView:SengSectionView {
    MPUSystemMediaControlsView *_controlsView;
}
@end
@interface SengChevronSectionView:SengSectionView {
    SBChevronView *_chevron;
    SBControlCenterGrabberView *_grabberView;
    SengContainerViewLayout _layout;
    CGFloat _initialPos;
}
- (void)setLayout:(SengContainerViewLayout)layout;
- (void)handleStatusUpdate:(id)update;
- (void)setChevronPointed:(BOOL)s;
@end
@interface SengCCLoaderSectionView:SengSectionView {
    NSString *_ccLoaderID;
}
- (instancetype)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos andCCLIdentifier:(NSString *)id;
@end

@interface sengSBCCAirStuffSectionController:SBCCAirStuffSectionController <UIPopoverControllerDelegate, UINavigationControllerDelegate>
@end

@interface sengScrollSBCCAirStuffSectionController:SBCCAirStuffSectionController <UIPopoverControllerDelegate, UINavigationControllerDelegate>
@end

@interface SengQuickSwitcherIconsController:SBAppSwitcherIconController
- (void)setScrollViewOffset:(CGFloat)offset;
- (void)initiateQuickSwitcherWithBaseOffset:(CGFloat)o startingAtIndex:(NSInteger)index;
- (void)willTerminateQuickSwitcherWithVelocity:(CGPoint)velocity;
- (void)didTerminateQuickSwitcher;
- (void)updateTouchLocation:(CGPoint)location velocity:(CGPoint)velocity;
- (NSInteger)getCurrentIndex;
- (void)updateIconsForIndex:(NSInteger)index animated:(BOOL)anim;
@end

@interface SengStandardIconsController:SBAppSwitcherIconController
@end

@interface sengSBAppSwitcherPeopleViewController:SBAppSwitcherPeopleViewController
@end

@interface sengButtonsSectionMPUSystemMediaControlsView:MPUSystemMediaControlsView
@end

@interface sengTitlesSectionMPUSystemMediaControlsView:MPUSystemMediaControlsView
@end

@interface sengScrubberSectionMPUSystemMediaControlsView:MPUSystemMediaControlsView
@end

@interface sengSBAlertItemActionSheet:SBAlertItem
@end

@interface sengSBAlertItemPiracy:SBAlertItem
@end

@interface sengSBAlertItemIOS9:SBAlertItem
@end

@interface SBAppSwitcherController (SENG)
- (void)updateMediaPlayingIndicator;
- (void)setupViews;
- (void)moveTopViewToYLocation:(CGFloat)yPos;
- (void)moveBottomViewToYLocation:(CGFloat)yPos;
- (void)moveTopViewFinishedAtLocation:(CGPoint)pos withVelocity:(CGPoint)velocity chevron:(SBChevronView *)c;
- (void)moveBottomViewFinishedAtLocation:(CGPoint)pos withVelocity:(CGPoint)velocity chevron:(SBChevronView *)c;
- (void)moveTopViewToNearestEnd:(SBChevronView *)v;
- (void)moveBottomViewToNearestEnd:(SBChevronView *)v;
- (void)quitAllApps;
- (void)resetHomeScrollViewPositionAndForceStayOpen:(BOOL)o;
- (CGFloat)_scaleForFullscreenPageView;
- (void)switcherScroller:(id)arg1 itemTapped:(id)arg2 animated:(BOOL)a;
@end

@interface SBControlCenterController (SENG)
- (void)startDismissWithGrabber;
@end

@interface SengSBScreenEdgePanGestureRecognizer : SBScreenEdgePanGestureRecognizer
@end
@interface SengCornerHomeGestureRecognizer : SBScreenEdgePanGestureRecognizer
@end
@interface SBSwitcherForcePressSystemGestureRecognizer : SBScreenEdgePanGestureRecognizer
@end
@interface SengSBForceScreenEdgePanGestureRecognizer : SBSwitcherForcePressSystemGestureRecognizer
@end
@interface  SengSBForceScreenRightEdgePanGestureRecognizer : SengSBForceScreenEdgePanGestureRecognizer
@end
