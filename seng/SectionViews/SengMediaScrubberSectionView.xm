#import "../SharedDefs.h"

@implementation SengMediaScrubberSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 30)];
    if (self) {
        _controller = [[%c(SBCCMediaControlsSectionController) alloc] init];
        _controller.delegate = self;
        _contentView = _controller.view;
        _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 30);
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_contentView setCenter:CGPointMake(width/2, CGRectGetHeight(self.frame)/2)];
        UIViewController *mediaControls = MSHookIvar<UIViewController *>(_controller, "_systemMediaViewController");
        MPUSystemMediaControlsView *controlsView  = MSHookIvar<MPUSystemMediaControlsView *>(mediaControls, "_mediaControlsView");
        object_setClass(controlsView, %c(sengScrubberSectionMPUSystemMediaControlsView));
        [self addSubview:_contentView];
    }
    return self;
}

- (NSString *)sectionID {
    return @"me.chewitt.seng.media-scrubber";
}

-(void) viewWillAppear {
    [super viewWillAppear];
    [[objc_getClass("VolumeControl") sharedVolumeControl] removeAlwaysHiddenCategory:@"Audio/Video"];
}

@end

%subclass sengScrubberSectionMPUSystemMediaControlsView : MPUSystemMediaControlsView
- (void)layoutSubviews {
    %orig;
    self.volumeView.hidden = YES;
    self.trackInformationView.alpha = 0;
    self.transportControlsView.alpha = 0;
    self.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 30);
    UIView *tiv = self.timeInformationView;
    tiv.frame = CGRectMake(CGRectGetMinX(tiv.frame), 0, CGRectGetWidth(tiv.frame), 30);
}
%end
