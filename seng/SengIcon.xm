#import "SharedDefs.h"
#import <UIKit/UIImage+private.h>

%subclass SengSBIcon : SBIcon

- (id)generateIconImage:(int)arg1 {
    return [[UIImage imageWithContentsOfFile:@"/System/Library/CoreServices/SpringBoard.app/SengIcon.png"] _applicationIconImageForFormat:SBApplicationIconFormatDefault precomposed:YES scale:[UIScreen mainScreen].scale];
}

- (id)getIconImage:(int)arg1 {
    return [[UIImage imageWithContentsOfFile:@"/System/Library/CoreServices/SpringBoard.app/SengIcon.png"] _applicationIconImageForFormat:SBApplicationIconFormatDefault precomposed:YES scale:[UIScreen mainScreen].scale];
}

- (id)displayNameForLocation:(NSInteger)arg1 {
    return localisedStringForKey(@"tw_HOME");
}

- (id)displayName {
    return localisedStringForKey(@"tw_HOME");
}

%end

%subclass SengSBIconView : SBAppSwitcherIconView

- (void)setAlpha:(CGFloat)a {
    %orig(1);
}

%end

%hook SBAppSwitcherIconView

- (void)setLocation:(NSInteger)lo {
    if(lo == (IS_IOS_(8,4) ? 5:4))
        %orig((IS_IOS_(8,4) ? 4:3));
    else
        %orig;
}

%end
