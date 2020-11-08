#import "Controllers.h"

@implementation sengPrefsBigScrollViewController

- (void)setSpecifier:(PSSpecifier *)specifier {
    sizeKey = @"big";
    allIdentifiers = IS_IOS_(9,0) ?
        [NSMutableArray arrayWithObjects:@"com.apple.controlcenter.air-stuff", @"me.chewitt.seng.volume", @"com.apple.controlcenter.brightness", @"com.apple.controlcenter.settings", @"com.apple.controlcenter.quick-launch", @"me.chewitt.seng.media-titles", @"me.chewitt.seng.media-buttons", nil] :
        [NSMutableArray arrayWithObjects:@"me.chewitt.seng.people", @"com.apple.controlcenter.air-stuff", @"me.chewitt.seng.volume", @"com.apple.controlcenter.brightness", @"com.apple.controlcenter.settings", @"com.apple.controlcenter.quick-launch", @"me.chewitt.seng.media-titles", @"me.chewitt.seng.media-buttons", nil];
    defEnabled  = [NSArray arrayWithObjects:@"com.apple.controlcenter.settings", @"com.apple.controlcenter.quick-launch", nil];
    defDisabled  = IS_IOS_(9,0) ?
        [NSArray arrayWithObjects:@"com.apple.controlcenter.air-stuff", @"me.chewitt.seng.volume", @"com.apple.controlcenter.brightness", @"me.chewitt.seng.media-titles", @"me.chewitt.seng.media-buttons", nil] :
        [NSArray arrayWithObjects:@"me.chewitt.seng.people", @"com.apple.controlcenter.air-stuff", @"me.chewitt.seng.volume", @"com.apple.controlcenter.brightness", @"me.chewitt.seng.media-titles", @"me.chewitt.seng.media-buttons", nil];
    [super setSpecifier:specifier];
}

@end
