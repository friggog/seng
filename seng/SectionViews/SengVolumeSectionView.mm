#import "../SharedDefs.h"

@implementation SengVolumeSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 50)];
    if (self) {
        _controller = [[objc_getClass("SBCCBrightnessSectionController") alloc] init];
        _controller.delegate = self;
        _contentView = _controller.view;
        _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 50);
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        SBCCMediaControlsSectionController *mController = [[objc_getClass("SBCCMediaControlsSectionController") alloc] init];
        [mController.view layoutSubviews];

        UIViewController *mediaControls = MSHookIvar<UIViewController *>(mController, "_systemMediaViewController");
        _controlsView  = MSHookIvar<MPUSystemMediaControlsView *>(mediaControls, "_mediaControlsView");

        UIView *bSlider = MSHookIvar<UIView *>(_controller, "_slider");
        bSlider.hidden = YES;

        [_controlsView.volumeView removeFromSuperview];
        CGFloat width = CGRectGetWidth(self.frame)-58 > 352 ? 352 : CGRectGetWidth(self.frame)-58;
        _controlsView.volumeView.frame = CGRectMake((CGRectGetWidth(self.frame)-width)/2, (CGRectGetHeight(self.frame)-50)/2, width, 50);
        _controlsView.volumeView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_contentView addSubview:_controlsView.volumeView];
        [self addSubview:_contentView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    UIView *bg = MSHookIvar<UIVisualEffectView *>(_controller, "_vibrantDarkenLayer");
    if (! bg) {
        bg = MSHookIvar<UIVisualEffectView *>(_controller, "_tintingDarkenLayer");
    }
    bg.frame = self.bounds;

    CGFloat width = CGRectGetWidth(self.frame)-58 > 352 ? 352 : CGRectGetWidth(self.frame)-58;
    _controlsView.volumeView.frame = CGRectMake((CGRectGetWidth(self.frame)-width)/2, (CGRectGetHeight(self.frame)-50)/2, width, 50);
}

- (NSString *)sectionID {
    return @"me.chewitt.seng.volume";
}

- (void)setIsInScrollView:(BOOL)s {
    if (s) {
        _contentView.tag = kSengSectionInScrollViewTag;
    }
    else {
        _contentView.tag = 0;
    }
}

@end
