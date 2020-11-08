#import "../SharedDefs.h"

@implementation SengAirStuffSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 50)];
    if (self) {
        _controller = [[%c(sengSBCCAirStuffSectionController) alloc] init];
        _controller.delegate = self;
        _contentView = _controller.view;
        _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 50);
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];
        [(SBCCAirStuffSectionController *)_controller controlCenterWillPresent];
    }
    return self;
}

- (void)setIsInScrollView:(BOOL)s {
    SBCCButtonLikeSectionSplitView *cView = (SBCCButtonLikeSectionSplitView *)_contentView;
    if (s) {
        object_setClass(_controller, %c(sengScrollSBCCAirStuffSectionController));
        object_setClass(_contentView, %c(sengScrollSBCCButtonLikeSectionSplitView));
        cView.leftSection.tag = kSengSectionInScrollViewTag;
        cView.rightSection.tag = kSengSectionInScrollViewTag;
    }
    else {
        object_setClass(_controller, %c(sengSBCCAirStuffSectionController));
        object_setClass(_contentView, %c(sengSBCCButtonLikeSectionSplitView));
        cView.leftSection.tag = 0;
        cView.rightSection.tag = 0;
    }
}

@end

%hook UIPopoverController
+ (BOOL)_popoversDisabled {
    return NO;
}
%end

static UIPopoverController *popoverController;
static UIPopoverPresentationController *popoverPresController;

%subclass sengSBCCAirStuffSectionController : SBCCAirStuffSectionController

+(Class) viewClass {
    return %c(sengSBCCButtonLikeSectionSplitView);
}

-(void) presentViewController:(UIViewController *)vc animated:(BOOL)a completion:(id)comp {
    if(IS_IOS_(9,0)) {
        if([vc isKindOfClass:[UIAlertController class]])
            [versionCorrectSwitcherController() presentViewController:vc animated:a completion:comp];
        else {
            self.view.alpha = 0;
            %orig;
        }
    }
    else {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        popoverController.popoverContentSize = CGSizeMake(300, 300);
        popoverController.delegate = self;
        [popoverController presentPopoverFromRect:MSHookIvar<UIView*>(self, "_airPlaySection").frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void) _dismissAirplayControllerAnimated:(BOOL)arg1 {
    %orig;
    if(IS_IOS_(9,0)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.view.alpha = 1;
            self.view.frame = CGRectMake(0,0,CGRectGetWidth(self.view.superview.frame),CGRectGetHeight(self.view.superview.frame));
        });
    }
    else
        [popoverController dismissPopoverAnimated:YES];
}

%new -(void) popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    [self _dismissAirplayControllerAnimated:YES];
}

%end

%subclass sengScrollSBCCAirStuffSectionController : SBCCAirStuffSectionController

+(Class)viewClass {
    return %c(sengScrollSBCCButtonLikeSectionSplitView);
}

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)a completion:(id)comp {
    if(IS_IOS_(9,0)) {
        if([vc isKindOfClass:[UIAlertController class]])
            [versionCorrectSwitcherController() presentViewController:vc animated:a completion:comp];
        else {
            self.view.alpha = 0;
            %orig;
        }
    }
    else {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        popoverController.popoverContentSize = CGSizeMake(300, 300);
        popoverController.delegate = self;
        [popoverController presentPopoverFromRect:MSHookIvar < UIView*> (self, "_airPlaySection").frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)_dismissAirplayControllerAnimated:(BOOL)arg1 {
    %orig;
    if(IS_IOS_(9,0)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.view.alpha = 1;
            self.view.frame = CGRectMake(0,0,CGRectGetWidth(self.view.superview.frame),CGRectGetHeight(self.view.superview.frame));
        });
    }
    else
        [popoverController dismissPopoverAnimated:YES];
}

%new - (void)popoverControllerShouldDismissPopover : (UIPopoverController *)popoverController {
    [self _dismissAirplayControllerAnimated:YES];
}

%end

%subclass sengSBCCButtonLikeSectionSplitView : SBCCButtonLikeSectionSplitView

- (BOOL)_useLandscapeBehavior {
    return NO;
}

- (SBCCButtonLikeSectionView *)rightSection {
    SBCCButtonLikeSectionView *rs = %orig;
    object_setClass(rs, %c(sengSBCCButtonLikeSectionView));
    if ([[SengShared prefsDic][@"hideDarkSectionBGS"] boolValue]) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 50)];
        v.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [rs addSubview:v];
    }
    return rs;
}

- (SBCCButtonLikeSectionView *)leftSection {
    SBCCButtonLikeSectionView *ls = %orig;
    object_setClass(ls, %c(sengSBCCButtonLikeSectionView));
    return ls;
}

%end

%subclass sengScrollSBCCButtonLikeSectionSplitView : SBCCButtonLikeSectionSplitView

- (BOOL)_useLandscapeBehavior {
    return NO;
}

- (SBCCButtonLikeSectionView *)rightSection {
    SBCCButtonLikeSectionView *rs = %orig;
    object_setClass(rs, %c(sengSBCCButtonLikeSectionView));
    if (MSHookIvar<UIView *>(rs, "_vibrantDarkenLayer")) {
        MSHookIvar<UIView *>(rs, "_vibrantDarkenLayer").hidden = YES;
    }
    if (MSHookIvar<UIView *>(rs, "_tintingDarkenLayer")) {
        MSHookIvar<UIView *>(rs, "_tintingDarkenLayer").hidden = YES;
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 50)];
    if ([[SengShared prefsDic][@"hideDarkSectionBGS"] boolValue]) {
        v.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    }
    else {
        v.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
    }
    [rs addSubview:v];
    return rs;
}

- (SBCCButtonLikeSectionView *)leftSection {
    SBCCButtonLikeSectionView *ls = %orig;
    object_setClass(ls, %c(sengSBCCButtonLikeSectionView));
    if (MSHookIvar<UIView *>(ls, "_vibrantDarkenLayer")) {
        MSHookIvar<UIView *>(ls, "_vibrantDarkenLayer").hidden = YES;
    }
    if (MSHookIvar<UIView *>(ls, "_tintingDarkenLayer")) {
        MSHookIvar<UIView *>(ls, "_tintingDarkenLayer").hidden = YES;
    }
    return ls;
}

%end

%subclass sengSBCCButtonLikeSectionView : SBCCButtonLikeSectionView
- (BOOL)_shouldUseButtonAppearance {
    return NO;
}
%end
