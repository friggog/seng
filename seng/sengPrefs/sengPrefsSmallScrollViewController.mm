#import "Controllers.h"

@implementation sengPrefsSmallScrollViewController

- (void)setSpecifier:(PSSpecifier *)specifier {
    sizeKey = @"small";
    allIdentifiers = [NSMutableArray arrayWithObjects:@"com.apple.controlcenter.brightness", @"me.chewitt.seng.volume", @"com.apple.controlcenter.air-stuff", @"me.chewitt.seng.media-titles", @"me.chewitt.seng.media-buttons", @"me.chewitt.seng.media-scrubber", nil];
    defEnabled = [NSArray arrayWithObjects:@"com.apple.controlcenter.brightness", @"me.chewitt.seng.volume", nil];
    defDisabled  = [NSArray arrayWithObjects:@"com.apple.controlcenter.air-stuff", @"me.chewitt.seng.media-titles", @"me.chewitt.seng.media-buttons", @"me.chewitt.seng.media-scrubber", nil];
    [super setSpecifier:specifier];
}

@end
