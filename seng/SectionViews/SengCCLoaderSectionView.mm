#import "../SharedDefs.h"

@implementation SengCCLoaderSectionView

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos {
    self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, 0)];
    return self;
}

- (id)initWithWidth:(CGFloat)width andPosition:(CGPoint)pos andCCLIdentifier:(NSString *)identifier {
    _ccLoaderID = identifier;
    NSBundle *sectionBundle = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/CCLoader/Bundles" error:nil];
    for (NSString *file in contents) {
        if ([file.pathExtension isEqualToString:@"bundle"]) {
            NSString *path = [@"/Library/CCLoader/Bundles" stringByAppendingPathComponent:file];
            NSBundle *bundle = [NSBundle bundleWithPath:path];
            NSString *ID = bundle.bundleIdentifier;
            if ([ID isEqualToString:_ccLoaderID]) {
                sectionBundle = bundle;
            }
            [bundle unload];
        }
    }
    if (sectionBundle != nil) {
        _controller = [[objc_getClass("CCSectionViewController") alloc] initWithCCLoaderBundle:sectionBundle type:CCBundleTypeDefault];
        CGFloat sectionHeight = ((CCSectionViewController *)_controller)._CCLoader_height;
        if ([_ccLoaderID isEqualToString:@"com.rpetrich.flipcontrolcenter.topshelf"] || [_ccLoaderID isEqualToString:@"com.a3tweaks.polus.topshelf"]) {
            sectionHeight += 10;
        }
        else if ([_ccLoaderID isEqualToString:@"com.a3tweaks.polus.bottomshelf"]) {
            sectionHeight = 87;
        }
        else if ([_ccLoaderID isEqualToString:@"fr.free.f5hla.ccpinfo"]) {
            sectionHeight = 70;
        }
        self = [super initWithFrame:CGRectMake(pos.x, pos.y, width, sectionHeight)];
        if (self) {
            _contentView = _controller.view;
            _controller.delegate = self;
            if ([_ccLoaderID isEqualToString:@"com.rpetrich.flipcontrolcenter.topshelf"] || [_ccLoaderID isEqualToString:@"com.a3tweaks.polus.topshelf"]) { // FCC top view fix
                _contentView.frame = CGRectMake(0, 10, CGRectGetWidth(self.frame), sectionHeight-10);
            }
            else if ([_ccLoaderID isEqualToString:@"com.a3tweaks.polus.bottomshelf"]) {
                _contentView.frame = CGRectMake(0, 3, CGRectGetWidth(self.frame), sectionHeight);
            }
            else {
                _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), sectionHeight);
            }
            _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:_contentView];
        }
    }
    else {
        self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return self;
}

- (NSString *)sectionID {
    return _ccLoaderID;
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [(CCSectionViewController *)_controller _CCLoader_controlCenterWillAppear];
    [(CCSectionViewController *)_controller _CCLoader_controlCenterDidAppear];
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    [(CCSectionViewController *)_controller _CCLoader_controlCenterDidDisappear];
}

@end
