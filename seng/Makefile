ADDITIONAL_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = seng
seng_FILES = Tweak.xmi SengIcon.xm SBAlertItems.xm SengQuickSwitcherIconsController.xm SengGestureRecognizers.xm SengContainerView.mm SectionViews/SengSectionView.mm SectionViews/SengVolumeSectionView.mm SectionViews/SengBrightnessSectionView.mm SectionViews/SengSmallScrollSectionView.mm SectionViews/SengQuickLaunchSectionView.xm SectionViews/SengSettingsSectionView.mm SectionViews/SengMediaSectionView.mm SectionViews/SengAirStuffSectionView.xm SectionViews/SengBigScrollSectionView.mm SectionViews/SengScrollSectionView.mm SectionViews/SengMediaTitlesSectionView.xm SectionViews/SengMediaButtonsSectionView.xm SectionViews/SengMediaScrubberSectionView.xm SectionViews/SengCCLoaderSectionView.mm SectionViews/SengPeopleSectionView.xm SectionViews/SengChevronSectionView.mm
seng_FRAMEWORKS = UIKit CoreGraphics QuartzCore AVFoundation
seng_PRIVATE_FRAMEWORKS = BackBoardServices SpringBoardServices FrontBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += sengprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
