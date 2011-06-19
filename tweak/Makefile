include ../theos/makefiles/common.mk

export GO_EASY_ON_ME=1

ADDITIONAL_CFLAGS = -I../common

TWEAK_NAME = MCTweak
MCTweak_OBJC_FILES = MCListener.mm MCImageView.m MCListenerJustMin.m MCListenerLastClosed.m MCListenerOpenBar.m MCListenerOpenEdit.m MCListenerQuitAll.m ../common/MCSettings.m ../common/MCIndividualSettings.m
MCTweak_FILES = MultiCleaner.xm MCSettingsController.xm
MCTweak_LDFLAGS = -lactivator
MCTweak_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
