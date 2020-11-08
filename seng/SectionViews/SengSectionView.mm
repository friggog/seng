#import "../SharedDefs.h"
#import "../SengContainerView.h"

@implementation SengSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [self initWithFrame:CGRectMake(pos.x, pos.y, width, 0)];
    return self;
}

- (id)initWithFrame:(CGRect)f {
    self = [super initWithFrame:f];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (CGFloat)sectionHeight {
    return CGRectGetHeight(self.frame);
}

- (NSString *)sectionID {
    return _controller.sectionIdentifier;
}

- (SBControlCenterSectionViewController *)controller {
    return _controller;
}

- (UIView *)contentView {
    return _contentView;
}

- (void)setIsInScrollView:(BOOL)s {}

- (void)sectionWantsControlCenterDismissal:(SBControlCenterSectionViewController *)section {
    if(IS_IOS_(9,0))
        [(SBMainSwitcherViewController *)[objc_getClass("SBMainSwitcherViewController") sharedInstance] dismissSwitcherNoninteractively];
    else
        [(SBUIController *)[objc_getClass("SBUIController") sharedInstance] dismissSwitcherAnimated:YES];
}

- (void)noteSectionEnabledStateDidChange:(id)arg1 {}

- (void)section:(id)section publishStatusUpdate:(id)update {
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

- (void)viewWillAppear {
    if (_controller) {
        [_controller viewWillAppear:NO];
        [_controller controlCenterWillBeginTransition];
        [_controller controlCenterDidFinishTransition];
        [_controller controlCenterWillPresent];
    }
}

- (void)viewDidDisappear {
    if (_controller) {
        [_controller viewWillDisappear:NO];
        [_controller controlCenterWillBeginTransition];
        [_controller controlCenterDidFinishTransition];
        [_controller controlCenterDidDismiss];
        [_controller viewDidDisappear:NO];
    }
}

@end
