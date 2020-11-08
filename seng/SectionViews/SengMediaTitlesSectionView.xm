#import "../SharedDefs.h"

@implementation SengMediaTitlesSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 50)];
    if (self) {
        _controller = [[%c(SBCCMediaControlsSectionController) alloc] init];
        _controller.delegate = self;
        _contentView = _controller.view;
        _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 50);
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_contentView setCenter:CGPointMake(width/2, CGRectGetHeight(self.frame)/2)];
        UIViewController *mediaControls = MSHookIvar<UIViewController *>(_controller, "_systemMediaViewController");
        MPUSystemMediaControlsView *controlsView  = MSHookIvar<MPUSystemMediaControlsView *>(mediaControls, "_mediaControlsView");
        object_setClass(controlsView, %c(sengTitlesSectionMPUSystemMediaControlsView));
        [self addSubview:_contentView];
    }
    return self;
}

- (NSString *)sectionID {
    return @"me.chewitt.seng.media-titles";
}

-(void) viewWillAppear {
    [super viewWillAppear];
    [[objc_getClass("VolumeControl") sharedVolumeControl] removeAlwaysHiddenCategory:@"Audio/Video"];
}

@end

%subclass sengTitlesSectionMPUSystemMediaControlsView : MPUSystemMediaControlsView
- (void)layoutSubviews {
    %orig;
    self.volumeView.hidden = YES;
    self.timeInformationView.hidden = YES;
    self.transportControlsView.alpha = 0;
    self.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 50);
    UIView *tiv = self.trackInformationView;
    tiv.frame = CGRectMake(CGRectGetMinX(tiv.frame), 5, CGRectGetWidth(tiv.frame), CGRectGetHeight(tiv.frame));
}
%end
