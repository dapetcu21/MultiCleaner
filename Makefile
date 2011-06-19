SUBPROJECTS = tweak app toggle

export THEOS_KEEP_VER=1
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 3.0

include theos/makefiles/common.mk
include theos/makefiles/aggregate.mk


after-stage::
# Convert Info.plist and Defaults.plist to binary
	- find $(THEOS_STAGING_DIR) -iname '*.plist' -or -iname '*.strings' -exec plutil -convert binary1 {} \;
