#import "../SharedDefs.h"

@implementation SengSettingsSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 70)];
    if (self) {
        _controller = [[objc_getClass("SBCCSettingsSectionController") alloc] init];
        _controller.delegate = self;
        _contentView = _controller.view;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentView];
        [self setFrame:self.frame];
    }
    return self;
}

- (void)setFrame:(CGRect)f {
    [super setFrame:f];
    _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 62);
    [_contentView setCenter:CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2 + 6)];
    [(SBControlCenterSectionView *)_contentView setEdgePadding:15];
}

-(void)viewWillAppear {
    [super viewWillAppear];
}

@end
