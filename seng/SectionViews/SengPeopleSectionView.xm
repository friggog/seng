#import "../SharedDefs.h"
#import <UIKit/_UILegibilitySettings.h>

@implementation SengPeopleSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 87)];
    if (self) {
        SBAppSwitcherPeopleViewController *con = [versionCorrectSwitcherController() _peopleViewController];
        con.legibilitySettings = [[_UILegibilitySettings alloc] initWithStyle:0 primaryColor:[UIColor whiteColor] secondaryColor:[UIColor whiteColor] shadowColor:[UIColor clearColor]];
        _contentView = con.view;
        object_setClass(_contentView, %c(sengSBAppSwitcherPeopleScrollView));
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_contentView setCenter:CGPointMake(width/2, CGRectGetHeight(self.frame)/2)];
        _contentView.hidden = NO;
        [_contentView removeFromSuperview];
        [self addSubview:_contentView];
    }
    return self;
}

- (NSString *)sectionID {
    return @"me.chewitt.seng.people";
}

- (void)viewWillAppear {
    [super viewWillAppear];
    _contentView.hidden = NO;
}

@end

%subclass sengSBAppSwitcherPeopleScrollView : SBAppSwitcherPeopleScrollView
- (void)setFrame:(CGRect)f {
    %orig(CGRectMake(0, 0, f.size.width, 83));
}
- (void)setAlpha:(CGFloat)a {
    %orig(1);
}

%end
