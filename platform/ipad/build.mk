# Invoked from the repository root. No xcodebuild or generated IDE project.
.DEFAULT_GOAL := app
.DELETE_ON_ERROR:
BUILD_DIR ?= build/ipad
BOOK ?= moon-spot
SDK ?= iphoneos
ARCH ?= $(if $(filter iphoneos,$(SDK)),arm64,$(shell uname -m))
IOS_MIN ?= 16.0
BUNDLE_ID ?= com.igor.book
TEAM ?=
PROFILE ?=
DEVICE ?=

ifeq ($(filter $(SDK),iphoneos iphonesimulator),)
$(error SDK must be iphoneos or iphonesimulator)
endif
SDK_PATH := $(shell xcrun --sdk $(SDK) --show-sdk-path)
SDK_VERSION := $(shell xcrun --sdk $(SDK) --show-sdk-version)
BUILD_ROOT := $(abspath $(BUILD_DIR))/$(BOOK)/$(SDK)-$(ARCH)
APP := $(BUILD_ROOT)/Book.app
ICON_DIR := $(BUILD_ROOT)/icons
COMPILER := xcrun --sdk $(SDK) clang
MIN_FLAG := $(if $(filter iphoneos,$(SDK)),-miphoneos-version-min,-mios-simulator-version-min)=$(IOS_MIN)
COMPILE_FLAGS := -isysroot "$(SDK_PATH)" -arch $(ARCH) $(MIN_FLAG) -std=c11 -O2 -g -Wall -Wextra -Werror=switch-enum -MMD -MP
INCLUDES := -Isrc -Ivendor -I"$(SDK_PATH)/usr/include/libxml2"
BOOK_SOURCE := books/$(BOOK).c
ifeq ($(wildcard $(BOOK_SOURCE)),)
$(error No C source for BOOK='$(BOOK)' (expected $(BOOK_SOURCE)))
endif
SOURCES := $(filter-out src/main.c src/headless.c,$(wildcard src/*.c)) $(BOOK_SOURCE) src/ipad.m src/metal.m
OBJECTS := $(addprefix $(BUILD_ROOT)/,$(SOURCES:.c=.o))
OBJECTS := $(OBJECTS:.m=.o)
ICON_SOURCES := $(wildcard assets/AppIcon.xcassets/*/*.png assets/AppIcon.xcassets/*/*.json assets/AppIcon.xcassets/*.json)

.PHONY: app mac run deploy clean settings

# Record SDK/compiler settings so changing the deployment target or SDK rebuilds
# native objects even when source timestamps have not changed.
settings:
	@mkdir -p "$(BUILD_ROOT)"
	@printf '%s\n' '$(COMPILER) $(COMPILE_FLAGS) $(INCLUDES) $(SDK_VERSION)' > "$(BUILD_ROOT)/settings.tmp"
	@cmp -s "$(BUILD_ROOT)/settings.tmp" "$(BUILD_ROOT)/settings" || cp "$(BUILD_ROOT)/settings.tmp" "$(BUILD_ROOT)/settings"
$(BUILD_ROOT)/settings: settings
	@test -f "$@"

$(BUILD_ROOT)/%.o: %.c $(BUILD_ROOT)/settings platform/ipad/build.mk
	@mkdir -p "$(@D)"
	$(COMPILER) $(COMPILE_FLAGS) $(INCLUDES) -c "$<" -o "$@"
$(BUILD_ROOT)/%.o: %.m $(BUILD_ROOT)/settings platform/ipad/build.mk
	@mkdir -p "$(@D)"
	$(COMPILER) $(COMPILE_FLAGS) $(INCLUDES) -fobjc-arc -c "$<" -o "$@"
$(BUILD_ROOT)/Book: $(OBJECTS)
	$(COMPILER) -isysroot "$(SDK_PATH)" -arch $(ARCH) $(MIN_FLAG) $^ -lxml2 -lm -framework UIKit -framework Foundation -framework CoreGraphics -framework Metal -framework QuartzCore -o "$@"
$(ICON_DIR)/partial.plist: $(ICON_SOURCES) $(BUILD_ROOT)/settings platform/ipad/build.mk
	@mkdir -p "$(ICON_DIR)"
	xcrun --sdk $(SDK) actool assets/AppIcon.xcassets --compile "$(ICON_DIR)" --output-partial-info-plist "$@" --app-icon AppIcon --target-device ipad --minimum-deployment-target $(IOS_MIN) --platform $(SDK) --output-format human-readable-text

# Repack resources on every invocation so replacing book art needs no C rebuild.
app: $(BUILD_ROOT)/Book $(ICON_DIR)/partial.plist
	python3 tools/bundle_ipad.py --root "$(CURDIR)" --target "$(APP)" --book "$(BOOK)" --binary "$(BUILD_ROOT)/Book" --icons "$(ICON_DIR)" --bundle-id "$(BUNDLE_ID)" --sdk $(SDK) --sdk-version $(SDK_VERSION) --minimum $(IOS_MIN)
ifeq ($(SDK),iphonesimulator)
	codesign --force --sign - "$(APP)"
endif

mac: app
	@test "$(SDK)" = iphoneos -a "$(ARCH)" = arm64 || { echo 'Mac launch requires SDK=iphoneos ARCH=arm64'; exit 1; }
	python3 tools/sign_ipad.py "$(APP)" $(if $(TEAM),--team "$(TEAM)") $(if $(PROFILE),--profile "$(PROFILE)")
	python3 tools/wrap_ipad_mac.py "$(APP)" "$(abspath $(BUILD_DIR))/$(BOOK).app"
	open "$(abspath $(BUILD_DIR))/$(BOOK).app"

run: app
	@test "$(SDK)" = iphonesimulator || { echo 'Simulator launch requires SDK=iphonesimulator'; exit 1; }
	python3 tools/run_ipad_simulator.py "$(APP)" $(if $(DEVICE),--device "$(DEVICE)")

deploy:
	@test "$(SDK)" = iphoneos -a "$(ARCH)" = arm64 || { echo 'iPad deployment requires SDK=iphoneos ARCH=arm64'; exit 1; }
	@test -n "$(DEVICE)" || { echo 'Set DEVICE="iPad name or UDID"; use make list-devices to find it.'; exit 1; }
	$(MAKE) -f platform/ipad/build.mk app
	python3 tools/sign_ipad.py "$(APP)" $(if $(TEAM),--team "$(TEAM)") $(if $(PROFILE),--profile "$(PROFILE)")
	xcrun devicectl device install app --device "$(DEVICE)" "$(APP)"
	xcrun devicectl device process launch --device "$(DEVICE)" --terminate-existing "$(BUNDLE_ID)"

clean:
	rm -rf "$(BUILD_ROOT)"

-include $(OBJECTS:.o=.d)
