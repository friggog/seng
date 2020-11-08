#import "../SharedDefs.h"
#import "../SengContainerView.h"

@implementation SengChevronSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 30)];
    if (self) {
        _grabberView = [[objc_getClass("SBControlCenterGrabberView") alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
        _grabberView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _grabberView.tag = kSengGrabberViewTag;
        _chevron = _grabberView.chevronView;
        [self addSubview:_grabberView];

        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chevronTapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapRecognizer];
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
        panRecognizer.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:panRecognizer];
    }
    return self;
}

- (NSString *)sectionID {
    return @"me.chewitt.seng.chevron";
}

- (void)setLayout:(SengContainerViewLayout)layout {
    _layout = layout;
    if (_layout == SengContainerViewLayoutBottom) {
        _chevron.layer.transform = CATransform3DIdentity;
    }
    else {
        _chevron.layer.transform = CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0);
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)pan {
    SBAppSwitcherController *sController = versionCorrectSwitcherController();
    CGPoint location = [pan locationInView:sController.view];
    CGPoint velocity = [pan velocityInView:sController.view];
    if (isLandscape() && ((_layout == SengContainerViewLayoutBottom && [SengShared bottomContainerView].visibleContentHeight < [SengShared bottomContainerView].contentHeight) || _layout == SengContainerViewLayoutTop)) {
        if (pan.state == UIGestureRecognizerStateEnded) {
            if (_layout == SengContainerViewLayoutTop) {
                [sController moveTopViewFinishedAtLocation:location withVelocity:velocity chevron:_chevron];
            }
            else {
                [sController moveBottomViewFinishedAtLocation:location withVelocity:velocity chevron:_chevron];
            }
        }
        else {
            [self setChevronPointed:NO];
            if (_layout == SengContainerViewLayoutTop) {
                [sController moveTopViewToYLocation:location.y+10];
            }
            else {
                [sController moveBottomViewToYLocation:location.y-10];
            }
        }
    }
    else {
        SBControlCenterController *ccController = [objc_getClass("SBControlCenterController") sharedInstance];
        if (pan.state == UIGestureRecognizerStateBegan) {
            [self setChevronPointed:NO];
            [ccController startDismissWithGrabber];
            CGFloat prog = 1 - ((screenHeight() - location.y) / [SengShared bottomContainerView].visibleContentHeight);
            [objc_getClass("SBFAnimationFactory") animateWithFactory:[SengShared sengAnimationFactory] actions:^{
                [[[objc_getClass("SBUIController") sharedInstance] switcherController] _updateForAnimationFrame:prog withAnchor:nil];
            }];
        }
        else if (pan.state == UIGestureRecognizerStateChanged) {
            CGFloat heightForProg = screenHeight()/3;
            CGFloat yPos = screenHeight() - ([SengShared bottomContainerView].visibleContentHeight > heightForProg ? [SengShared bottomContainerView].visibleContentHeight:heightForProg) * ((screenHeight() - location.y) / [SengShared bottomContainerView].visibleContentHeight);
            if(IS_IOS_(9,0)) {
                [ccController updateTransitionWithLocation:CGPointMake(screenWidth()/2, yPos) velocity:velocity andState:UIGestureRecognizerStateChanged fromRecognizer:nil];
            }
            else
                [ccController updateTransitionWithTouchLocation:CGPointMake(screenWidth()/2, yPos) velocity:velocity];
        }
        else {
            if (location.y < screenHeight() - [SengShared bottomContainerView].contentHeight) {
                velocity = CGPointMake(0, -1);
            }
            if(IS_IOS_(9,0)) {
                [ccController updateTransitionWithLocation:CGPointMake(0,0) velocity:velocity andState:UIGestureRecognizerStateEnded fromRecognizer:nil];
            }
            else
                [ccController endTransitionWithVelocity:velocity completion:nil];
            [self setChevronPointed:[SengShared isAppSwitcherActive]];
        }
    }
}

- (void)chevronTapped:(UITapGestureRecognizer *)sender {
    if (isLandscape()) {
        SBAppSwitcherController *sController = versionCorrectSwitcherController();
        if (_layout == SengContainerViewLayoutTop) {
            [sController moveTopViewToNearestEnd:_chevron];
        }
        else {
            [sController moveBottomViewToNearestEnd:_chevron];
        }
    }
    else {
        if([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9)
            [[objc_getClass("SBMainSwitcherViewController") sharedInstance] dismissSwitcherNoninteractively];
        else
            [[objc_getClass("SBUIController") sharedInstance] dismissSwitcherAnimated:YES];
    }
}

- (void)viewWillAppear {
    [self setChevronPointed:NO];
    [_grabberView controlCenterWillPresent];
    [_grabberView controlCenterWillBeginTransition];
    [_grabberView controlCenterDidFinishTransition];
    [super viewWillAppear];
}

- (void)viewDidDisappear {
    [_grabberView controlCenterWillBeginTransition];
    [_grabberView controlCenterDidFinishTransition];
    [_grabberView controlCenterDidDismiss];
    [super viewDidDisappear];
}

- (void)handleStatusUpdate:(id)update {
    [_grabberView presentStatusUpdate:update];
}

- (void)setChevronPointed:(BOOL)s {
    [_chevron setState:s animated:YES];
}

@end
