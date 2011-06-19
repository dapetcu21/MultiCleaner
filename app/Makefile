include ../theos/makefiles/common.mk

ADDITIONAL_CFLAGS = -I../common

APPLICATION_NAME = MultiCleaner
MultiCleaner_FILES = main.m SettingsViewController.m TableCell.m TableCellActivator.m TableCellChoice.m TableCellNavigation.m TableCellSwitch.m TableGroup.m TableModel.m About.m ActivatorToggles.m AdvancedView.m ApplicationCell.m ApplicationPickerController.m MultiCleanerAppDelegate.m MultiLineCell.m PickerTableController.m RootViewController.m SettingsView.m SwitchCell.m ../common/MCSettings.m ../common/MCIndividualSettings.m
MultiCleaner_PRIVATE_FRAMEWORKS = SpringBoardServices AppSupport
MultiCleaner_FRAMEWORKS = UIKit CoreGraphics
MultiCleaner_LDFLAGS = -lactivator

include $(THEOS_MAKE_PATH)/application.mk