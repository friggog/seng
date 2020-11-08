#import "../SharedDefs.h"
#import "sectionClassForSectionName.h"

@implementation SengScrollSectionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        _activeSections = [NSMutableArray array];
    }
    return self;
}

- (NSString *)sectionID {
    return @"me.chewitt.seng.scroll";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateForLayout:_currentLayout];
}

- (void)updateForLayout:(SengContainerViewLayout)layout {
    _currentLayout = layout;

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
    BOOL resetsToFirst = [[SengShared manualPrefsDic][[NSString stringWithFormat:@"%@_%@ScrollResetsToFirst", _layoutKey, _sizeKey]] boolValue];

    _scrollView.contentSize = verticalScroll ? CGSizeMake(CGRectGetWidth(self.frame), _pageHeight*_pageCount) : CGSizeMake(CGRectGetWidth(self.frame)*_pageCount, _pageHeight);

    for (NSInteger i = 0; i < _pageCount; i++) {
        CGPoint pos = CGPointMake(CGRectGetWidth(self.frame) * i, 0);
        if (verticalScroll) {
            pos = CGPointMake(0, _pageHeight * i);
        }
        Class sectionClass = sectionClassForSectionName(sectionIDs[i]);
        SengSectionView *sectionView = [[sectionClass alloc] initWithWidth:CGRectGetWidth(self.frame) andPosition:pos];
        sectionView.frame = CGRectMake(pos.x, pos.y, CGRectGetWidth(sectionView.frame), _pageHeight);
        if ([[self class] isEqual:[SengSmallScrollSectionView class]]) {
            [sectionView setIsInScrollView:YES];
        }
        [_activeSections addObject:sectionView];
        [_scrollView addSubview:sectionView];
    }

    if(!verticalScroll && !resetsToFirst) {
        _scrollView.contentOffset = CGPointMake(_currentPage*CGRectGetWidth(self.frame),0);
    }

    if (verticalScroll && layout == SengContainerViewLayoutTop && resetsToFirst) {
        _scrollView.contentOffset = CGPointMake(0, _pageHeight*(_pageCount-1));
    }

    _scrollView.frame = CGRectMake(0,0,CGRectGetWidth(self.frame),CGRectGetHeight(self.frame));
}

- (void)viewWillAppear {
    if ([[SengShared manualPrefsDic][[NSString stringWithFormat:@"%@_%@ScrollResetsToFirst", _layoutKey, _sizeKey]] boolValue]) {
        BOOL verticalScroll = [[SengShared manualPrefsDic][[NSString stringWithFormat:@"%@_%@ScrollDirection", _layoutKey, _sizeKey]] boolValue];
        if (verticalScroll && [_layoutKey isEqualToString:@"top"]) {
            _scrollView.contentOffset = CGPointMake(0, _pageHeight*(_pageCount-1));
        }
        else {
            _scrollView.contentOffset = CGPointMake(0, 0);
        }
    }
    for (SengSectionView *v in _activeSections) {
        [v viewWillAppear];
    }
}

- (void)viewDidDisappear {
    for (SengSectionView *v in _activeSections) {
        [v viewDidDisappear];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentPage = scrollView.contentOffset.x/CGRectGetWidth(self.frame);
}

@end
