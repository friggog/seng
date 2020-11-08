#import "../SharedDefs.h"

@implementation SengBrightnessSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 50)];
    if (self) {
        _controller = [[objc_getClass("SBCCBrightnessSectionController") alloc] init];
        _controller.delegate = self;
        _contentView = _controller.view;
        _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 50);
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        CGFloat padding = CGRectGetWidth(self.frame) > 410 ? 29 + (CGRectGetWidth(self.frame) - 410)/2 : 29;
        [(SBControlCenterSectionView *)_contentView setEdgePadding:padding];
        [self addSubview:_contentView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat padding = CGRectGetWidth(self.frame) > 410 ? 29 + (CGRectGetWidth(self.frame) - 410)/2 : 29;
    [(SBControlCenterSectionView *)_contentView setEdgePadding:padding];
    UIView *bg = MSHookIvar<UIVisualEffectView *>(_controller, "_vibrantDarkenLayer");
    if (! bg) {
        bg = MSHookIvar<UIVisualEffectView *>(_controller, "_tintingDarkenLayer");
    }
    bg.frame = self.bounds;
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
