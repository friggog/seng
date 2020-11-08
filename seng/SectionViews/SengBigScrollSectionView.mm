#import "../SharedDefs.h"
#import "sectionClassForSectionName.h"

@implementation SengBigScrollSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 90)];
    return self;
}

- (NSString *)sectionID {
    return @"me.chewitt.seng.big-scroll";
}

- (void)updateForLayout:(SengContainerViewLayout)layout {
    _currentLayout = layout;
    _defaults = [NSArray arrayWithObjects:@"com.apple.controlcenter.settings", @"com.apple.controlcenter.quick-launch", nil];
    _sizeKey = @"big";

    for (UIView *s in _scrollView.subviews) {
        [s removeFromSuperview];
        [_activeSections removeObject:s];
    }

    _layoutKey = _currentLayout == SengContainerViewLayoutTop ? @"top" : @"bottom";

    NSArray *sectionIDs = [SengShared manualPrefsDic][[NSString stringWithFormat:@"%@_%@ScrollEnabledSections", _layoutKey, _sizeKey]];
    if (! sectionIDs) {
        sectionIDs = _defaults;
    }

    _pageCount = sectionIDs.count;

    BOOL verticalScroll = [[SengShared manualPrefsDic][[NSString stringWithFormat:@"%@_%@ScrollDirection", _layoutKey, _sizeKey]] boolValue];

    _pageHeight = 0;
    for (NSInteger i = 0; i < _pageCount; i++) {
        Class sectionClass = sectionClassForSectionName(sectionIDs[i]);
        SengSectionView *sectionView = nil;
        if (sectionClass != nil) {
            if ([sectionClass isEqual:[SengCCLoaderSectionView class]]) {
                sectionView = [[SengCCLoaderSectionView alloc] initWithWidth:CGRectGetWidth(self.frame) andPosition:CGPointZero andCCLIdentifier:sectionIDs[i]];
            }
            else {
                sectionView = [[sectionClass alloc] initWithWidth:CGRectGetWidth(self.frame) andPosition:CGPointZero];
            }
            if (sectionView.sectionHeight > _pageHeight) {
                _pageHeight = sectionView.sectionHeight;
            }
            if(sectionView != nil) {
                [_activeSections addObject:sectionView];
                [_scrollView addSubview:sectionView];
            }
        }
    }

    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), _pageHeight);
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = verticalScroll ? CGSizeMake(CGRectGetWidth(self.frame), _pageHeight*_pageCount) : CGSizeMake(CGRectGetWidth(self.frame)*_pageCount, _pageHeight);

    for (NSInteger i = 0; i < _pageCount; i++) {
        SengSectionView *sectionView = _activeSections[i];
        CGPoint pos = CGPointMake(CGRectGetWidth(self.frame) * i, 0);
        if (verticalScroll) {
            pos = CGPointMake(0, _pageHeight * i);
        }
        if ([sectionView isKindOfClass:[SengCCLoaderSectionView class]]) {
            sectionView.center = CGPointMake(pos.x + CGRectGetWidth(sectionView.frame)/2, pos.y+_pageHeight/2);
        }
        else {
            sectionView.frame = CGRectMake(pos.x, pos.y, CGRectGetWidth(sectionView.frame), _pageHeight);
        }
    }

    if (verticalScroll && _currentLayout == SengContainerViewLayoutTop) {
        _scrollView.contentOffset = CGPointMake(0, _pageHeight*(_pageCount-1));
    }
}

@end
