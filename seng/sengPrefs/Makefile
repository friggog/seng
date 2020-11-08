include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = sengPrefs
sengPrefs_FILES = sengPrefs.mm sengBetterPSSliderTableCell.mm sengPrefsOrganisationController.mm sengPrefsScrollViewController.mm sengPrefsSmallScrollViewController.mm sengPrefsBigScrollViewController.mm
sengPrefs_INSTALL_PATH = /Library/PreferenceBundles
sengPrefs_FRAMEWORKS = UIKit MessageUI Social
sengPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/me.chewitt.seng.plist$(ECHO_END)
