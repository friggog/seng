#import "../SharedDefs.h"

@implementation SengQuickLaunchSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 87)];
    if (self) {
        _controller = [[%c(sengSBCCQuickLaunchSectionController) alloc] init];
        _controller.delegate = self;
        _contentView = _controller.view;
        [_contentView layoutSubviews];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentView];
        [self setFrame:self.frame];
    }
    return self;
}

- (void)setFrame:(CGRect)f {
    [super setFrame:f];
    _contentView.frame = CGRectMake(0, 9, CGRectGetWidth(self.frame), 70);
    [(SBControlCenterSectionView *)_contentView setEdgePadding:15];
}

@end

%subclass sengSBCCQuickLaunchSectionController : SBCCQuickLaunchSectionController

- (void)_addButtonModule:(SBCCButtonModule *)mod {
    if ([mod.identifier isEqualToString:@"flashlight"]) {
        id viewController = MSHookIvar<id>([%c(SBControlCenterController) sharedInstance], "_viewController");
        if (viewController) {
            SBControlCenterContentView *contentView = MSHookIvar<SBControlCenterContentView *>(viewController, "_contentView");
            if (contentView) {
                SBCCQuickLaunchSectionController *qlSection = (SBCCQuickLaunchSectionController *)contentView.quickLaunchSection;
                NSMutableDictionary *origQLModules = MSHookIvar<NSMutableDictionary *>(qlSection, "_modulesByID");
                SBCCButtonModule *origFlashlightModule = origQLModules[@"flashlight"];
                %orig(origFlashlightModule);
            }
            else {
                %orig;
            }
        }
        else {
            %orig;
        }
    }
    else {
        %orig;
    }
}

%end
