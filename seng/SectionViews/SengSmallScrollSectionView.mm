#import "../SharedDefs.h"

@implementation SengSmallScrollSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 50)];
    return self;
}

- (NSString *)sectionID {
    return @"me.chewitt.seng.small-scroll";
}

- (void)updateForLayout:(SengContainerViewLayout)layout {
    _sizeKey = @"small";
    _pageHeight = 50;
    _defaults = [NSArray arrayWithObjects:@"com.apple.controlcenter.brightness", @"me.chewitt.seng.volume", nil];
    [super updateForLayout:layout];
    if (! [[[SengShared prefsDic] valueForKey:@"hideDarkSectionBGS"] boolValue] && ! _bgView) {
        SBCCBrightnessSectionController *bc = [[objc_getClass("SBCCBrightnessSectionController") alloc] init];
        [bc _updateEffects];
        _bgView = MSHookIvar<UIVisualEffectView *>(bc, "_vibrantDarkenLayer");
        if (! _bgView) {
            _bgView = MSHookIvar<UIVisualEffectView *>(bc, "_tintingDarkenLayer");
        }
        _bgView.frame = self.bounds;
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bgView];
    }
}

@end
