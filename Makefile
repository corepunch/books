.DEFAULT_GOAL := run

BUILD_DIR ?= build
BOOK ?= three-stars
SCENE ?= attic
SCENER ?= $(shell command -v scener 2>/dev/null || printf '%s/.local/bin/scener' "$$HOME")
WIDTH ?= 1920
HEIGHT ?= 1440
CC ?= cc
CFLAGS ?= -O2 -g
BUILD_ROOT := $(abspath $(BUILD_DIR))
BOOK_BUILD_ROOT := $(BUILD_ROOT)/$(BOOK)
BOOK_SOURCE := books/$(BOOK).c
ifeq ($(wildcard $(BOOK_SOURCE)),)
$(error No C source for BOOK='$(BOOK)' (expected $(BOOK_SOURCE)))
endif
SOURCES := $(wildcard src/*.c) $(BOOK_SOURCE)
NATIVE_SOURCES := src/macos.m src/metal.m
OBJECTS := $(patsubst %.c,$(BOOK_BUILD_ROOT)/%.o,$(SOURCES)) $(patsubst %.m,$(BOOK_BUILD_ROOT)/%.o,$(NATIVE_SOURCES))
CPPFLAGS += -Isrc -Ivendor $(shell pkg-config --cflags libxml-2.0)
CFLAGS += -std=c11 -Wall -Wextra -Werror=switch-enum -MMD -MP
LDLIBS += $(filter-out -lm,$(shell pkg-config --libs libxml-2.0)) -lm
ifneq ($(shell uname -s),Darwin)
$(error Book requires macOS with AppKit and Metal)
endif
CPPFLAGS += -I$(shell xcrun --show-sdk-path)/usr/include/libxml2
LDLIBS += -framework AppKit -framework Metal -framework QuartzCore

.PHONY: all run mac check check-ui render layout clean ipad ipad-simulator ipad-mac ipad-run ipad-deploy list-devices
# The AppKit executable remains a development/headless harness.
# The shipping app is compiled directly with the iOS SDK, without an IDE project.
ipad:
	$(MAKE) -f platform/ipad/build.mk BUILD_DIR="$(BUILD_ROOT)/ipad" BOOK="$(BOOK)" SDK=iphoneos app
ipad-simulator:
	$(MAKE) -f platform/ipad/build.mk BUILD_DIR="$(BUILD_ROOT)/ipad" BOOK="$(BOOK)" SDK=iphonesimulator app
ipad-mac:
	$(MAKE) -f platform/ipad/build.mk BUILD_DIR="$(BUILD_ROOT)/ipad" BOOK="$(BOOK)" SDK=iphoneos mac
ipad-run:
	$(MAKE) -f platform/ipad/build.mk BUILD_DIR="$(BUILD_ROOT)/ipad" BOOK="$(BOOK)" SDK=iphonesimulator run
ipad-deploy:
	$(MAKE) -f platform/ipad/build.mk BUILD_DIR="$(BUILD_ROOT)/ipad" BOOK="$(BOOK)" SDK=iphoneos deploy
list-devices:
	xcrun devicectl list devices
$(BOOK_BUILD_ROOT):
	mkdir -p "$@"

all: $(BOOK_BUILD_ROOT)/book
$(BOOK_BUILD_ROOT)/%.o: %.c | $(BOOK_BUILD_ROOT)
	mkdir -p "$(@D)"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c "$<" -o "$@"
$(BOOK_BUILD_ROOT)/%.o: %.m | $(BOOK_BUILD_ROOT)
	mkdir -p "$(@D)"
	$(CC) $(CPPFLAGS) $(CFLAGS) -fobjc-arc -c "$<" -o "$@"

$(BOOK_BUILD_ROOT)/book: $(OBJECTS)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o "$@"
$(BOOK_BUILD_ROOT)/test_geometry.o: tests/test_geometry.c | $(BOOK_BUILD_ROOT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -Isrc -c "$<" -o "$@"
$(BOOK_BUILD_ROOT)/test_geometry: $(BOOK_BUILD_ROOT)/test_geometry.o $(BOOK_BUILD_ROOT)/src/geometry.o
	$(CC) $(LDFLAGS) $^ -lm -o "$@"
$(BOOK_BUILD_ROOT)/test_transition.o: tests/test_transition.c | $(BOOK_BUILD_ROOT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -Isrc -c "$<" -o "$@"
$(BOOK_BUILD_ROOT)/test_transition: $(BOOK_BUILD_ROOT)/test_transition.o $(BOOK_BUILD_ROOT)/src/transition.o $(BOOK_BUILD_ROOT)/src/geometry.o
	$(CC) $(LDFLAGS) $^ -lm -o "$@"
$(BOOK_BUILD_ROOT)/test_hotspots.o: tests/test_hotspots.c | $(BOOK_BUILD_ROOT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -Isrc -c "$<" -o "$@"
$(BOOK_BUILD_ROOT)/test_hotspots: $(BOOK_BUILD_ROOT)/test_hotspots.o $(BOOK_BUILD_ROOT)/src/hotspots.o $(BOOK_BUILD_ROOT)/src/geometry.o
	$(CC) $(LDFLAGS) $^ -lm -o "$@"
mac run: $(BOOK_BUILD_ROOT)/book
	"$(BOOK_BUILD_ROOT)/book" --root "$(CURDIR)" --book "$(BOOK)"
check: $(BOOK_BUILD_ROOT)/book $(BOOK_BUILD_ROOT)/test_geometry $(BOOK_BUILD_ROOT)/test_transition $(BOOK_BUILD_ROOT)/test_hotspots
	"$(BOOK_BUILD_ROOT)/test_geometry"
	"$(BOOK_BUILD_ROOT)/test_transition"
	"$(BOOK_BUILD_ROOT)/test_hotspots"
	python3 tests/test_book.py "$(BOOK_BUILD_ROOT)/book" "$(CURDIR)"
check-ui: $(BOOK_BUILD_ROOT)/book
	python3 tests/test_ui.py "$(BOOK_BUILD_ROOT)/book" "$(CURDIR)"
render:
	python3 tools/render.py --book "$(BOOK)" --scene "$(SCENE)" --scener "$(SCENER)" --width $(WIDTH) --height $(HEIGHT)
layout:
	cd "books/$(BOOK)/rooms" && "$(SCENER)" --layout "$(SCENE).blks" --scale 2 --format jpg --output-dir .
clean:
	rm -rf "$(BUILD_ROOT)"
-include $(OBJECTS:.o=.d) $(BOOK_BUILD_ROOT)/test_geometry.d $(BOOK_BUILD_ROOT)/test_transition.d $(BOOK_BUILD_ROOT)/test_hotspots.d
