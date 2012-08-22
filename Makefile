TWEAK_NAME = StatusBulletin
StatusBulletin_FILES = Tweak.x
StatusBulletin_FRAMEWORKS = UIKit 

ADDITIONAL_CFLAGS = -std=c99 -I..

TARGET_IPHONEOS_DEPLOYMENT_VERSION := 3.0

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
