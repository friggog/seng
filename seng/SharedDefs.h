#import "SengHeaders.h"
#import <objc/runtime.h>
#import "substrate.h"

#define PREFS_PATH @"/var/mobile/Library/Preferences/me.chewitt.seng.plist"
#define PREFS_PATH_MANUAL @"/var/mobile/Library/Preferences/me.chewitt.seng.manual.plist"
#define PREFS_CHANGED_NAME "me.chewitt.seng.prefsChanged"
#define LIST_PATH @"/var/lib/dpkg/info/me.chewitt.seng.list"
#define kSengSectionInScrollViewTag 39234234
#define kSengQuickSwitcherDodgyIconFixFix 7456342
#define IS_IPHONE_6P ([[UIScreen mainScreen] bounds].size.height >= 730 || [[UIScreen mainScreen] bounds].size.width >= 730)

static inline BOOL isPortrait() {
    return UIInterfaceOrientationIsPortrait([(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation]);
}

static inline BOOL isLandscape() {
    return UIInterfaceOrientationIsLandscape([(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation]);
}

static inline CGFloat screenWidth() {
    return isPortrait() ? [UIScreen mainScreen].bounds.size.width :[UIScreen mainScreen].bounds.size.height;
}

static inline CGFloat screenHeight() {
    return isPortrait() ? [UIScreen mainScreen].bounds.size.height :[UIScreen mainScreen].bounds.size.width;
}

static inline CGFloat viewWidth() {
    CGFloat w = 0;
    if(IS_IOS_(9,0)) {
        w = CGRectGetWidth(MSHookIvar<UIView *>([objc_getClass("SBMainSwitcherViewController") sharedInstance],"_contentView").frame);
    }
    else {
        id sc = [[objc_getClass("SBUIController") sharedInstance] switcherController];
        if (sc) {
            w = CGRectGetWidth(MSHookIvar<UIView *>(sc, "_contentView").frame);
        }
    }
    if (w == 0) {
        w = screenWidth();
    }
    return w;
}

static inline CGFloat viewHeight() {
    CGFloat h = 0;
    if(IS_IOS_(9,0)) {
        h = CGRectGetHeight(MSHookIvar<UIView *>([objc_getClass("SBMainSwitcherViewController") sharedInstance],"_contentView").frame);
    }
    else {
        id sc = [[objc_getClass("SBUIController") sharedInstance] switcherController];
        if (sc) {
            h = CGRectGetHeight(MSHookIvar<UIView *>(sc, "_contentView").frame);
        }
    }
    if (h == 0) {
        h = screenHeight();
    }
    return h;
}

static inline SBAppSwitcherController *versionCorrectSwitcherController() {
    if(IS_IOS_(9,0)) {
        return (SBAppSwitcherController *)[[objc_getClass("SBMainSwitcherViewController") sharedInstance] _contentViewController];
    }
    return (SBAppSwitcherController *)[[objc_getClass("SBUIController") sharedInstance] switcherController];
}

@class SengContainerView;

@interface SengShared:NSObject
+ (NSDictionary *)manualPrefsDic;
+ (NSDictionary *)prefsDic;
+ (BOOL)forceReload;
+ (BOOL)isMediaPlaying;
+ (SBFAnimationFactory *)sengAnimationFactory;
+ (CGFloat)switcherIconsPerPage;
+ (SengContainerView *)bottomContainerView;
+ (SengContainerView *)topContainerView;
+ (BOOL)isAppSwitcherActive;
+ (BOOL)areAppSwitcherIconLabelsHidden;
+(BOOL) reduceMotionEnabled;
@end

static inline NSString *localisedStringForKey(NSString *key) {
    return [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/sengPrefs.bundle"] localizedStringForKey:key value:key table:nil];
}

#define kSengIconStyleOverlapped 1
#define kSengIconStyleHidden 2

#define kSengGrabberViewTag 1238972

@interface SengAnimator : NSObject
+(void) animateWithActions:(void (^)(void))actions completion:(void(^)(BOOL))comp;
+(void) animateWithActions:(void (^)(void))actions;
+(void) fastAnimateWithActions:(void (^)(void))actions completion:(void(^)(BOOL))comp;
+(void) fastAnimateWithActions:(void (^)(void))actions;
@end
