#import "SharedDefs.h"

@class _UIBackdropView;

@interface SengContainerView:UIView {
    _UIBackdropView *_backgroundView;
    CGFloat _totalHeight;
    SengContainerViewLayout _layout;
    NSMutableArray *_activeSections;
    NSMutableArray *_sectionsIDS;
    BOOL _isAirplayShowing;
    BOOL _allowChevron;
    SengChevronSectionView * _grabberView;
}
@property (nonatomic) CGFloat visibleContentHeight;
- (void)setupForLayout:(SengContainerViewLayout)layout;
- (void)setupForSections:(NSArray *)section;
- (BOOL)isSectionHidden:(NSString *)section;
- (void)viewWillAppear;
- (void)viewDidDisappear;
- (BOOL)isAirplayAvailabe;
- (CGFloat)contentHeight;
- (void)setBackgroundAlphaIfAllowed:(CGFloat)a;
- (NSArray *)activeSections;
- (void)setChevronAllowed:(BOOL)a;
- (void)handleStatusUpdate:(id)update;
- (void)setGrabberStateOut:(BOOL)o;
- (BOOL)hasGrabberView;
@end
