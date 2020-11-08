#import <UIKit/_UILegibilitySettings.h>
#import <UIKit/_UIBackdropView.h>
#import <UIKit/_UIBackdropViewSettings.h>

@protocol SBControlCenterSectionViewControllerDelegate <NSObject>
@required
- (void)noteSectionEnabledStateDidChange:(id)arg1;
- (void)section:(id)arg1 publishStatusUpdate:(id)arg2;
- (void)sectionWantsControlCenterDismissal:(id)arg1;
@end

@interface SBControlCenterSectionView:UIView
- (void)setEdgePadding:(CGFloat)arg1;
@end

@interface SBControlCenterSectionViewController:UIViewController
@property (nonatomic, copy, readonly) NSString *sectionIdentifier;
@property (assign, nonatomic) id<SBControlCenterSectionViewControllerDelegate> delegate;
- (CGSize)contentSizeForOrientation:(long long)arg1;
- (void)controlCenterWillBeginTransition;
- (void)controlCenterDidFinishTransition;
- (void)controlCenterWillPresent;
- (void)controlCenterDidDismiss;
@end

@interface SBCCButtonSectionController:SBControlCenterSectionViewController
@end

@interface SBCCMediaControlsSectionController:SBControlCenterSectionViewController
@end

@interface SBCCSettingsSectionController:SBCCButtonSectionController
@end

@interface SBCCQuickLaunchSectionController:SBControlCenterSectionViewController
@end

@interface SBCCBrightnessSectionController:SBControlCenterSectionViewController
- (void)_updateEffects;
@end

@interface SBCCAirStuffSectionController:SBControlCenterSectionViewController
- (void)_updateForAirPlayStateChange;
- (void)controlCenterWillPresent;
- (void)_dismissAirplayControllerAnimated:(BOOL)arg1;
@end

@interface SBCCButtonLikeSectionSplitView:UIView
@property (assign, nonatomic) UIView *leftSection;               //@synthesize leftSection=_leftSection - In the implementation block
@property (assign, nonatomic) UIView *rightSection;              //@synthesize rightSection=_rightSection - In the implementation block
@end

@interface SBCCButtonLikeSectionView:UIControl
- (void)_updateBackgroundForStateChange;
- (void)_updateEffects;
@end

@interface UIView (seng)
- (void)_setDrawsAsBackdropOverlayWithBlendMode:(long)m;
@end

@interface SBAppSwitcherPeopleViewController:UIViewController
@property (nonatomic, retain) id activeDataSource;
@property (nonatomic, retain) id legibilitySettings;
@property (assign, nonatomic) id delegate;
- (void)_configureDataSourceIfNecessaryAndPossible;
- (void)_configurePeopleScrollView;
- (void)_configureGestureRecognizers;
- (void)switcherWillBePresented:(BOOL)arg1;
@end

typedef NS_ENUM (NSUInteger, CCBundleType) {
    CCBundleTypeDefault,
    CCBundleTypeWeeApp,
    CCBundleTypeBBWeeApp
};

@interface CCSectionViewController:SBControlCenterSectionViewController
- (instancetype)initWithCCLoaderBundle:(NSBundle *)bundle type:(CCBundleType)type;
- (CGFloat)_CCLoader_height;
- (void)_CCLoader_controlCenterDidDisappear;
- (void)_CCLoader_controlCenterDidAppear;
- (void)_CCLoader_controlCenterWillAppear;
@end

@interface MPUSystemMediaControlsView:UIView
@property (nonatomic, readonly) UIView * /*MPUChronologicalProgressView*/ timeInformationView;
@property (nonatomic, readonly) UIView * /*MPUMediaControlsVolumeView */ volumeView;
@property (nonatomic, readonly) UIView * /*MPUTransportControlsView */ transportControlsView;
@property (nonatomic, readonly) UIView * /*MPUMediaControlsTitlesView */ trackInformationView;
@end

@interface SBCCButtonLayoutView:UIView
- (void)setContentEdgeInsets:(UIEdgeInsets)arg1;
@end

@interface SBChevronView:UIView
@property (assign, nonatomic) long long state;
@property (nonatomic, retain) UIColor *color;
- (instancetype)initWithColor:(id)arg1;
- (void)setState:(NSInteger)state animated:(BOOL)anim;
@end

@interface SBFAnimationFactory:NSObject
- (void)_animateWithAdditionalDelay:(CGFloat)a options:(long)b actions:(id)c completion:(id)d;
+ (id)factoryWithSettings:(id)arg1;
+ (void)animateWithFactory:(id)arg1 additionalDelay:(double)arg2 options:(unsigned long long)arg3 actions:(/*^block*/ id)arg4 completion:(/*^block*/ id)arg5;
+ (id)factoryWithSettings:(id)arg1 timingFunction:(id)arg2;
+ (id)factoryWithAnimationAttributes:(id)arg1;
+ (id)factoryWithDuration:(double)arg1;
+ (id)factoryWithDuration:(double)arg1 delay:(double)arg2;
+ (id)factoryWithDuration:(double)arg1 timingFunction:(id)arg2;
+ (id)factoryWithDuration:(double)arg1 delay:(double)arg2 timingFunction:(id)arg3;
+ (id)factoryWithMass:(CGFloat)arg1 stiffness:(CGFloat)arg2 damping:(CGFloat)arg3;
+ (id)factoryWithMass:(CGFloat)arg1 stiffness:(CGFloat)arg2 damping:(CGFloat)arg3 epsilon:(CGFloat)arg4;
+ (id)factoryWithMass:(CGFloat)arg1 stiffness:(CGFloat)arg2 damping:(CGFloat)arg3 timingFunction:(id)arg4;
+ (id)factoryWithMass:(CGFloat)arg1 stiffness:(CGFloat)arg2 damping:(CGFloat)arg3 epsilon:(CGFloat)arg4 timingFunction:(id)arg5;
+ (void)animateWithFactory:(id)arg1 actions:(/*^block*/ id)arg2;
+ (void)animateWithFactory:(id)arg1 actions:(/*^block*/ id)arg2 completion:(/*^block*/ id)arg3;
+ (void)animateWithFactory:(id)arg1 options:(unsigned long long)arg2 actions:(/*^block*/ id)arg3;
+ (void)animateWithFactory:(id)arg1 options:(unsigned long long)arg2 actions:(/*^block*/ id)arg3 completion:(/*^block*/ id)arg4;
+ (void)animateWithFactory:(id)arg1 additionalDelay:(double)arg2 actions:(/*^block*/ id)arg3;
+ (void)animateWithFactory:(id)arg1 additionalDelay:(double)arg2 actions:(/*^block*/ id)arg3 completion:(/*^block*/ id)arg4;
+ (void)animateWithFactory:(id)arg1 additionalDelay:(double)arg2 options:(unsigned long long)arg3 actions:(/*^block*/ id)arg4;
@end

@interface BSUIAnimationFactory:NSObject
- (void)_animateWithAdditionalDelay:(CGFloat)a options:(long)b actions:(id)c completion:(id)d;
+ (id)factoryWithSettings:(id)arg1;
+ (void)animateWithFactory:(id)arg1 additionalDelay:(double)arg2 options:(unsigned long long)arg3 actions:(/*^block*/ id)arg4 completion:(/*^block*/ id)arg5;
+ (id)factoryWithSettings:(id)arg1 timingFunction:(id)arg2;
+ (id)factoryWithAnimationAttributes:(id)arg1;
+ (id)factoryWithDuration:(double)arg1;
+ (id)factoryWithDuration:(double)arg1 delay:(double)arg2;
+ (id)factoryWithDuration:(double)arg1 timingFunction:(id)arg2;
+ (id)factoryWithDuration:(double)arg1 delay:(double)arg2 timingFunction:(id)arg3;
+ (id)factoryWithMass:(CGFloat)arg1 stiffness:(CGFloat)arg2 damping:(CGFloat)arg3;
+ (id)factoryWithMass:(CGFloat)arg1 stiffness:(CGFloat)arg2 damping:(CGFloat)arg3 epsilon:(CGFloat)arg4;
+ (id)factoryWithMass:(CGFloat)arg1 stiffness:(CGFloat)arg2 damping:(CGFloat)arg3 timingFunction:(id)arg4;
+ (id)factoryWithMass:(CGFloat)arg1 stiffness:(CGFloat)arg2 damping:(CGFloat)arg3 epsilon:(CGFloat)arg4 timingFunction:(id)arg5;
+ (void)animateWithFactory:(id)arg1 actions:(/*^block*/ id)arg2;
+ (void)animateWithFactory:(id)arg1 actions:(/*^block*/ id)arg2 completion:(/*^block*/ id)arg3;
+ (void)animateWithFactory:(id)arg1 options:(unsigned long long)arg2 actions:(/*^block*/ id)arg3;
+ (void)animateWithFactory:(id)arg1 options:(unsigned long long)arg2 actions:(/*^block*/ id)arg3 completion:(/*^block*/ id)arg4;
+ (void)animateWithFactory:(id)arg1 additionalDelay:(double)arg2 actions:(/*^block*/ id)arg3;
+ (void)animateWithFactory:(id)arg1 additionalDelay:(double)arg2 actions:(/*^block*/ id)arg3 completion:(/*^block*/ id)arg4;
+ (void)animateWithFactory:(id)arg1 additionalDelay:(double)arg2 options:(unsigned long long)arg3 actions:(/*^block*/ id)arg4;
@end

@interface SBDisplayLayout:NSObject
@property (nonatomic, readonly) NSMutableArray *displayItems;
+ (id)fullScreenDisplayLayoutForApplication:(id)arg1;
+ (id)homeScreenDisplayLayout;
@end

@interface SBDisplayItem:NSObject
@property (nonatomic, readonly) NSString *displayIdentifier;
@property (nonatomic, readonly) NSString *type;
// ios 9
+ (id)displayItemWithType:(NSString *)arg1 displayIdentifier:(id)arg2;
+ (id)homeScreenDisplayItem;
@end


@interface SBAppSwitcherPageView:UIView
- (UIView *)view;
@end

@interface SBAppSwitcherItemScrollView:UIScrollView
@property (nonatomic, retain) SBAppSwitcherPageView *item;
@end

@interface SBAppSwitcherPageViewController:UIViewController
- (void)_handleTapGesture:(id)arg1;
- (unsigned long long)currentPage;
@property (nonatomic, copy) NSArray *displayLayouts;
- (id)pageViewForDisplayLayout:(id)arg1;
- (void)setOffsetToIndex:(unsigned long long)arg1 animated:(BOOL)arg2;
- (void)setOffsetToIndex:(unsigned long long)arg1 animated:(BOOL)arg2 completion:(/*^block*/ id)arg3;
- (CGFloat)_distanceBetweenCenters;
- (CGFloat)_maxXOffset;
- (void)_setContentOffset:(CGPoint)arg1 animated:(BOOL)arg2;
- (CGFloat)_halfWidth;
- (CGPoint)_centerOfIndex:(unsigned long long)arg1;
// ios 9
@property(copy, nonatomic) NSArray *displayItems;
- (id)pageViewForDisplayItem:(id)arg1;
//seng
- (SBDisplayLayout *)displayLayoutForScrollView:(SBAppSwitcherItemScrollView *)s;
- (SBDisplayItem *)displayItemForScrollView:(SBAppSwitcherItemScrollView *)s;
@end

@interface  SBAppSwitcherIconController:UIViewController
@property (nonatomic, retain) _UILegibilitySettings *legibilitySettings;
@property (nonatomic, copy) NSArray *displayLayouts;
- (void)setOffsetToIndex:(unsigned long long)arg1 animated:(BOOL)arg2;
- (UIView *)_iconViewForIndex:(unsigned long long)arg1;
- (unsigned long long)_centeredIndex;
+ (CGFloat)nominalDistanceBetween3IconCentersForSize:(CGSize)siz;
- (CGFloat)_maxXOffsetForDistance:(CGFloat)arg1;
- (CGFloat)_distanceBetweenCenters;
- (void)_updateVisibleIconViewsWithPadding:(BOOL)arg1;
- (CGFloat)_recalculateLayout:(BOOL)arg1;
- (void)reloadInOrientation:(long long)arg1;
- (CGRect)_iconFaultRectForIndex:(unsigned long long)arg1;
@end

@interface SBAppSwitcherController:UIViewController
@property (nonatomic, readonly) SBAppSwitcherIconController *iconController;
@property (nonatomic) SBFAnimationFactory *_transitionAnimationFactory;
- (void)_quitAppWithDisplayItem:(id)arg1;
- (void)forceDismissAnimated:(BOOL)arg1;
- (UIView *)pageForDisplayLayout:(id)arg1;
- (id)switcherScroller:(id)arg1 viewForDisplayLayout:(id)arg2;
- (void)switcherScroller:(id)arg1 itemTapped:(id)arg2;
- (void)animateDismissalToDisplayLayout:(id)arg1 withCompletion:(/*^block*/ id)arg2;
- (SBAppSwitcherPageViewController *)pageController;
- (void)_updateForAnimationFrame:(CGFloat)arg1 withAnchor:(id)arg2;
- (void)switcherWasDismissed:(BOOL)arg1;
+ (CGFloat)pageScale;
- (CGFloat)_switcherThumbnailVerticalPositionOffset;
- (long long)_windowInterfaceOrientation;
- (void)_bringIconViewToFront;
- (void)_quitAppWithDisplayItem:(id)arg1;
- (CGFloat)_frameScaleValueForAnimation;
- (void)_removeDisplayLayout:(id)arg1 completion:(/*^block*/ id)arg2;
- (id)_peopleViewController;
- (void)_updatePageViewScale:(CGFloat)arg1;
- (id)_snapshotViewForDisplayItem:(id)arg1;
- (void)_updateSnapshots;
-(void)switcherScroller:(id)arg1 displayItemWantsToBeRemoved:(id)arg2 ;
-(CGFloat)_frameScaleValueForAnimation;
// 9
- (CGRect)_nominalPageViewFrameForOrientation:(long long)arg1;
- (void)handleReachabilityModeActivated;
- (BOOL)_inMode:(int)arg1;
@end

@interface SBUIController:NSObject
+ (instancetype)sharedInstance;
- (void)getRidOfAppSwitcher;
- (SBAppSwitcherController *)switcherController;
- (UIWindow *)window;
- (void)dismissSwitcherAnimated:(BOOL)arg1;
- (void)_toggleSwitcher;
- (id)switcherWindow;
- (BOOL)isAppSwitcherShowing;
- (void)activateApplicationAnimated:(id)arg1;
- (void)_installSystemGestureView:(id)arg1 forKey:(id)arg2 forGesture:(unsigned long long)arg3;
- (void)tearDownIconListAndBar;
- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)arg1;
- (void)_clearInstalledSystemGestureViewForKey:(NSString *)a;
- (BOOL)handleMenuDoubleTap;
- (BOOL)_activateAppSwitcher;
- (void)_showControlCenterGestureChangedWithLocation:(CGPoint)location velocity:(CGPoint)velocity duration:(CGFloat)duration;
- (void)_showControlCenterGestureEndedWithLocation:(CGPoint)arg1 velocity:(CGPoint)arg2;
- (void)requestApplicationEventsEnabledIfNecessary;
- (void)removeAppFromSwitchAppList:(id)arg1;
- (void)cleanupRunningGestureIfNeeded;
- (void)_clearAllInstalledSystemGestureViews;
- (void)finishLaunching;
- (BOOL)clickedMenuButton;
- (void)_suspendGestureBegan;
- (void)_suspendGestureChanged:(float)arg1;
- (void)_suspendGestureEndedWithCompletionType:(long long)arg1;
- (void)showSystemGestureBackdrop;
- (void)hideSystemGestureBackdrop;
- (id)systemGestureSnapshotForApp:(id)arg1 includeStatusBar:(BOOL)arg2 decodeImage:(BOOL)arg3;
- (void)_animateStatusBarForSuspendGesture;
- (void)setFakeSpringBoardStatusBarVisible:(BOOL)arg1;
- (void)handleFluidScaleSystemGesture:(id)arg1;
- (id)_systemGestureViewKeyForApp:(id)arg1;
- (UIView *)_fakeSpringBoardStatusBar;
- (void)_hideKeyboard;
-(void)_switchAppGestureBegan:(CGFloat)arg1;
-(void)_switchAppGestureChanged:(CGFloat)arg1;
-(void)_switchAppGestureEndedWithCompletionType:(long long)arg1 cumulativePercentage:(CGFloat)arg2;
- (void)programmaticSwitchAppGestureMoveToRight;
- (void)programmaticSwitchAppGestureMoveToLeft;
- (void)_handleSwitchAppGesture:(id)arg1;
// 9
- (void)_handleScrunchGesture:(id)arg1;
- (void)_scrunchGestureBegan;
+ (id)zoomViewForApplication:(id)arg1 sceneID:(id)arg2 interfaceOrientation:(long long)arg3 statusBarDescriptor:(id)arg4 decodeImage:(_Bool)arg5;
+ (id)zoomViewWithIOSurfaceSnapshotOfApp:(id)arg1 sceneID:(id)arg2 screen:(id)arg3 statusBarDescriptor:(id)arg4;
@end

@interface SBScrunchAppsSystemGestureWorkspaceTransaction : NSObject
- (void)_suspendGestureEndedWithCompletionType:(long long)arg1;
- (void)_suspendGestureChanged:(double)arg1;
- (void)_beginAnimation;
- (void)_setupAnimation;
@end

@interface SBAlertItem:NSObject <UIAlertViewDelegate>
- (id)alertSheet;
- (void)dismiss;
@end

@interface SBAlertItemsController:NSObject
+ (instancetype)sharedInstance;
- (void)activateAlertItem:(id)arg1 animated:(BOOL)arg2;
@end

@interface SBStateSettings:NSObject
- (BOOL)boolForStateSetting:(unsigned)arg1;
@end

@interface SBApplication:NSObject
@property (nonatomic, readonly) NSString *bundleIdentifier;
@property (copy) NSString *displayIdentifier;
@property (setter = _setStateSettings:, nonatomic, copy) SBStateSettings *_stateSettings;
- (void)notifyResignActiveForReason:(long)r;
- (void)notifyResumeActiveForReason:(long)r;
- (void)setObject:(id)a forDeactivationSetting:(long)b;
- (BOOL)isSpringBoard;
- (void)kill;
- (BOOL)isActivating;
- (NSInteger)activationState;
- (long long)launchingInterfaceOrientationForCurrentOrientation;
- (id)mainSceneID;
@end

@interface SBMediaController:NSObject
@property (nonatomic, readonly) SBApplication *nowPlayingApplication;
+ (instancetype)sharedInstance;
- (BOOL)isPlaying;
- (void)scrollViewWillEndDragging:(id)arg1 withVelocity:(CGPoint)arg2 targetContentOffset:(CGPoint *)arg3;
-(BOOL)suppressHUD;
-(void)setSuppressHUD:(BOOL)arg1;
@end

@interface SBApplicationController:NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)applicationWithBundleIdentifier:(id)s;
@end

@interface UIApplication (seng)
- (long long)activeInterfaceOrientation;
@end

@interface SpringBoard:UIApplication
@property SBApplication *_accessibilityFrontMostApplication;
- (void)relaunchSpringBoard;
- (void)powerDown;
- (void)reboot;
- (BOOL)isLocked;
- (void)userDefaultsDidChange:(id)defaults;
@end

@interface SBGestureRecognizer:NSObject
@property (assign, nonatomic) unsigned long long types;
@property (assign, nonatomic) NSInteger state;
@end

@interface SBFluidSlideGestureRecognizer:SBGestureRecognizer
@end

@interface SBScaleGestureRecognizer:SBFluidSlideGestureRecognizer
@end

@interface SBUIAnimationZoomDownAppToHome:NSObject
- (void)prepareZoom;
- (void)animateZoomWithCompletion:(/*^block*/ id)arg1;
@end

@interface SBGestureViewVendor:NSObject
+ (instancetype)sharedInstance;
- (UIView *)viewForApp:(id)a gestureType:(NSInteger)b includeStatusBar:(BOOL)c;
@end

@interface SBWallpaperController:NSObject
+ (instancetype)sharedInstance;
- (void)beginRequiringWithReason:(NSString *)r;
- (void)endRequiringWithReason:(NSString *)r;
@end

@interface FBWindowContextHostManager:NSObject
- (void)disableHostingForRequester:(NSString *)a;
@end

@interface FBScene:NSObject
@property (nonatomic, retain, readonly) FBWindowContextHostManager *contextHostManager;
@end

@interface FBSceneManager:NSObject
+ (instancetype)sharedInstance;
- (FBScene *)sceneWithIdentifier:(id)arg1;
@end

@interface SBIconController:NSObject
+ (SBIconController *)sharedInstance;
- (BOOL)hasAnimatingFolder;
@end

@interface SBAlertManager:NSObject
- (id)activeAlert;
@end

@interface SBWorkspaceTransaction:NSObject
@end



@interface SBWorkspace:NSObject
+(SBWorkspace*)mainWorkspace;
@property SBAlertManager *alertManager;
@property(retain, nonatomic) SBWorkspaceTransaction *currentTransaction;
-(id)createRequestWithOptions:(long)o;
- (id)createRequestForApplicationActivation:(id)arg1 options:(unsigned long long)arg2;
-(void)executeTransitionRequest:(id)r;
@end

@interface SBWorkspaceTransitionRequest : NSObject
-(void)setSource:(long)s;
-(void)setEventLabel:(NSString*)l;
-(void)setTransactionProvider:(id)b;
-(void)modifyApplicationContext:(id)c;
@end

@interface SBWorkspaceApplicationTransitionContext : NSObject
-(void)setEntity:(id)s forLayoutRole:(long)d;
@end

@interface SBWorkspaceHomeScreenEntity :NSObject
+(id)entity;
@end

@interface SBWorkspaceApplication : NSObject
+(id)entityForApplication:(id)a actions:(long)a;
@end

@interface SBAppToAppWorkspaceTransaction:SBWorkspaceTransaction
- (instancetype)initWithAlertManager:(id)a exitedApp:(id)b;
- (instancetype)initWithAlertManager:(id)arg1 from:(id)arg2 to:(id)arg3 withResult:(/*^block*/ id)arg4;
- (instancetype)initWithAlertManager:(id)arg1 activationRequest:(id)arg2 withResult:(/*^block*/ id)arg3;
@end

@interface FBWorkspaceEvent:NSObject
+ (id)eventWithName:(NSString *)n handler:(id)a;
@end

@interface FBWorkspaceEventQueue:NSObject
+ (instancetype)sharedInstance;
- (void)executeOrAppendEvent:(id)a;
@end

@interface SBIcon:NSObject
- (id)generateIconImage:(NSInteger)arg1;
@end

@interface SBControlCenterButton:UIView
@end

@interface SengSBIcon:SBIcon
@end

@interface SBIconView:UIView
@property (nonatomic, retain) SBIcon *icon;
@property (assign, nonatomic) NSInteger location;
@property (assign, nonatomic) id delegate;
+ (CGSize)defaultIconSize;
+ (CGSize)defaultIconImageSize;
+ (CGRect)defaultIconImageFrame;
+ (int)_defaultIconFormat;
+ (CGFloat)_labelHeight;
- (instancetype)initWithDefaultSize;
- (instancetype)initWithContentType:(unsigned long long)arg1;
- (UIImageView *)_iconImageView;
- (void)setLegibilitySettings:(_UILegibilitySettings *)arg1;
- (void)updateShadow;
- (CGRect)iconImageFrame;
-(void)_updateLabel;
-(void)setImageCrossfadeMorphFraction:(float)fraction totalScale:(float)scale;
@end

@interface SBAppSwitcherIconView:SBIconView
@end

@interface SengSBIconView:SBAppSwitcherIconView
@end

@interface MPAVRoutingController:NSObject
- (NSArray *)availableRoutes;
- (void)_updateCachedRoutes;
@end

@interface MPAVRoute:NSObject
- (NSDictionary *)avRouteDescription;
@end

@interface UIDevice (chew)
+ (long long)currentDeviceOrientationAllowingAmbiguous:(BOOL)arg1;
@end

@interface SBControlCenterContentView:UIView
@property (nonatomic, retain) UIViewController *airplaySection;
@property (nonatomic, retain) UIViewController *quickLaunchSection;
- (void)controlCenterWillPresent;
@end

@interface SBControlCenterController:UIViewController
+ (instancetype)sharedInstance;
@property (assign, getter = isPresented, nonatomic) BOOL presented;
@property (assign, getter = isTransitioning, nonatomic) BOOL transitioning;
@property (assign, getter = isFullyRevealed, nonatomic) BOOL fullyRevealed;
- (BOOL)isVisible;
- (void)beginTransitionWithTouchLocation:(CGPoint)location;
- (void)updateTransitionWithTouchLocation:(CGPoint)duration velocity:(CGPoint)velocity;
- (void)endTransitionWithVelocity:(CGPoint)arg1 completion:(/*^block*/ id)arg2;
- (void)_beginTransitionWithTouchLocation:(CGPoint)a;

-(BOOL)updateTransitionWithLocation:(CGPoint)location velocity:(CGPoint)velocity andState:(UIGestureRecognizerState)state fromRecognizer:(id)rec;
@end

@interface SBLockScreenManager:NSObject
+ (instancetype)sharedInstance;
- (BOOL)isUILocked;
- (void)lockUIFromSource:(NSInteger)arg1 withOptions:(id)arg2;
@end

@interface SBBacklightController:NSObject
- (void)animateBacklightToFactor:(CGFloat)arg1 duration:(CGFloat)arg2 source:(NSInteger)arg3 completion:(/*^block*/ id)arg4;
- (void)setBacklightFactor:(CGFloat)arg1 source:(NSInteger)arg2;
@end

@interface SBWorkspaceAppsActivationRequest:NSObject
+ (id)fullScreenActivationRequestForApp:(id)arg1;
+ (id)homeScreenActivationRequest;
@end

@interface SBControlCenterContentContainerView:UIView
- (_UIBackdropView *)backdropView;
@end

@interface SBControlCenterContainerView:UIView
- (SBControlCenterContentContainerView *)contentContainerView;
@end

@interface SBActivatorIconView:SBIconView
@end

@interface _UIScreenEdgePanRecognizerEdgeSettings:NSObject
@property (assign, nonatomic) CGFloat hysteresis;
@property (assign, nonatomic) CGFloat bottomEdgeRegionSize;
@property (assign, nonatomic) CGFloat topEdgeRegionSize;
@end

@interface _UIScreenEdgePanRecognizerSettings:NSObject
@property (nonatomic, retain) _UIScreenEdgePanRecognizerEdgeSettings *edgeSettings;
@end

@interface SBPowerDownController:NSObject
- (void)powerDown;
@end

@interface UIDevice (seng)
- (void)setOrientation:(NSUInteger)o;
- (void)setOrientation:(NSUInteger)o animated:(BOOL)a;
@end

@interface AVFlashlight:NSObject
+ (BOOL)hasFlashlight;
@end

@interface SBCCButtonModule:NSObject
- (id)identifier;
@end

@interface SBLockStateAggregator:NSObject
- (unsigned long long)lockState;
@end

@interface VolumeControl : NSObject
+(id)sharedVolumeControl;
-(void)addAlwaysHiddenCategory:(id)arg1;
-(void)removeAlwaysHiddenCategory:(id)arg1;
@end

@interface SBFAnimationSettings : NSObject
-(void)setStiffness:(double)arg1;
-(void)setDamping:(double)arg1;
-(void)setMass:(double)arg1;
-(void)setEpsilon:(double)arg1;
@end

@interface SBAppSwitcherSnapshotView : UIView
@property (nonatomic,retain) UIImage * deferredUpdateImage;
-(void)_crossfadeToZoomUpViewIfNecessary;
-(void)_crossfadeToZoomUpViewIfNecessaryForTransitionRequest:(id)re;
-(void)prepareToBecomeVisibleIfNecessary;
-(void)simplifyForMotion;
-(void)unsimplifyAfterMotion;
-(void)_crossfadeToNewSnapshotImage:(id)arg1;
-(void)invalidate;
-(void)_layoutContainer;
-(void)_loadZoomUpSnapshotSync;
@end

@interface SBAppSwitcherModel : NSObject
+(id)sharedInstance;
-(void)removeDisplayItem:(id)arg1;
-(void)remove:(id)arg1;
@end

@interface SBDisplayLayoutManager : NSObject
@property (nonatomic,retain) SBDisplayLayout * activeLayout;
+(id)sharedInstance;
@end

@interface SBControlCenterGrabberView : UIView
-(SBChevronView*)chevronView;
-(void)presentStatusUpdate:(id)arg1;
-(void)controlCenterWillBeginTransition;
-(void)controlCenterDidFinishTransition;
-(void)controlCenterWillPresent;
-(void)controlCenterDidDismiss;
@end

@interface CCSectionView : UIView
@property (assign, nonatomic) id delegate;
@end

@interface SBAppSwitcherSettings : NSObject
+ (id)settingsControllerModule;
@property long long switcherStyle;
@end

@interface SBMainSwitcherViewController : UIViewController
+ (id)sharedInstance;
- (id)_contentViewController;
- (BOOL)activateSwitcherNoninteractively;
- (BOOL)dismissSwitcherNoninteractively;
- (BOOL)toggleSwitcherNoninteractively;
@property(copy, nonatomic, setter=_setInitialDisplayItem:) SBDisplayItem *_initialDisplayItem;
- (BOOL)isVisible;
- (void)_quitAppRepresentedByDisplayItem:(id)arg1 forReason:(long long)arg2;
- (void)_updateContentViewControllerClassFromSettings;
@end

@interface SBScreenEdgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer
- (id)initWithTarget:(id)arg1 action:(SEL)arg2;
- (id)initWithTarget:(id)arg1 action:(SEL)arg2 type:(long long)arg3;
- (void)sb_commonInitScreenEdgePanGestureRecognizer;
@end

@interface SBSystemGestureManager : NSObject
- (void)addGestureRecognizer:(id)arg1 withType:(unsigned long long)arg2;
- (void)removeGestureRecognizer:(id)arg1;
+ (id)mainDisplayManager;
@end

@interface SBMainDisplaySystemGestureManager : SBSystemGestureManager
@end

@interface FBSystemGestureManager : NSObject
+(id)sharedInstance;
-(void)addGestureRecognizer:(id)r toDisplay:(id)d;
@end

@interface FBDisplayManager : NSObject
+(id)mainDisplay;
@end

@interface SBIconImageView : UIView
-(SBIcon *)icon;
@property (nonatomic,retain) UIImage * fixedImage;
@end

@interface SBSwitchAppList : NSObject
- (id)applicationBundleIDBeforeBundleID:(id)arg1;
- (id)applicationBundleIDAfterBundleID:(id)arg1;
@end

@interface SBSwitchAppSwipeTransaction : NSObject
@property(readonly, nonatomic, getter=isFinishedAnimating) _Bool finishedAnimating;
@end
