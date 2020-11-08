#import "../SharedDefs.h"

@implementation SengMediaSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 150)];
    if (self) {
        _controller = [[objc_getClass("SBCCMediaControlsSectionController") alloc] init];
        _controller.delegate = self;
        _contentView = _controller.view;
        _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 150);
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentView];
    }
    return self;
}

-(void) viewWillAppear {
    [super viewWillAppear];
    [[objc_getClass("VolumeControl") sharedVolumeControl] addAlwaysHiddenCategory:@"Audio/Video"];
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    [[objc_getClass("VolumeControl") sharedVolumeControl] removeAlwaysHiddenCategory:@"Audio/Video"];
}

@end
