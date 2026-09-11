.DEFAULT_GOAL := run

BUILD_DIR ?= build
BOOK ?= wondertown
SCENE ?= workshop-new
SCENER ?= $(shell command -v scener 2>/dev/null || printf '%s/.local/bin/scener' "$$HOME")
WIDTH ?= 1920
HEIGHT ?= 1440
CC ?= cc
CFLAGS ?= -O2 -g
LUA_PKG ?= $(shell for package in lua5.4 lua; do pkg-config --exists $$package 2>/dev/null && { echo $$package; break; }; done)
BUILD_ROOT := $(abspath $(BUILD_DIR))
SOURCES := $(wildcard src/*.c)
NATIVE_SOURCES := src/macos.m src/metal.m
OBJECTS := $(patsubst src/%.c,$(BUILD_ROOT)/src/%.o,$(SOURCES)) $(patsubst src/%.m,$(BUILD_ROOT)/src/%.o,$(NATIVE_SOURCES))
CPPFLAGS += -Ivendor $(shell pkg-config --cflags $(LUA_PKG) libxml-2.0)
CFLAGS += -std=c11 -Wall -Wextra -MMD -MP
LDLIBS += $(filter-out -lm,$(shell pkg-config --libs $(LUA_PKG) libxml-2.0)) -lm
ifneq ($(shell uname -s),Darwin)
$(error Book requires macOS with AppKit and Metal)
endif
CPPFLAGS += -I$(shell xcrun --show-sdk-path)/usr/include/libxml2
LDLIBS += -framework AppKit -framework Metal -framework QuartzCore

.PHONY: all run mac check check-ui render layout clean ipad ipad-simulator ipad-mac ipad-run
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
all: $(BUILD_ROOT)/book
$(BUILD_ROOT):
	mkdir -p "$@"
$(BUILD_ROOT)/src: | $(BUILD_ROOT)
	mkdir -p "$@"
$(BUILD_ROOT)/src/%.o: src/%.c | $(BUILD_ROOT)/src
	$(CC) $(CPPFLAGS) $(CFLAGS) -c "$<" -o "$@"
$(BUILD_ROOT)/src/%.o: src/%.m | $(BUILD_ROOT)/src
	$(CC) $(CPPFLAGS) $(CFLAGS) -fobjc-arc -c "$<" -o "$@"
$(BUILD_ROOT)/book: $(OBJECTS)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o "$@"
$(BUILD_ROOT)/test_geometry.o: tests/test_geometry.c | $(BUILD_ROOT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -Isrc -c "$<" -o "$@"
$(BUILD_ROOT)/test_geometry: $(BUILD_ROOT)/test_geometry.o $(BUILD_ROOT)/src/geometry.o
	$(CC) $(LDFLAGS) $^ -lm -o "$@"
$(BUILD_ROOT)/test_transition.o: tests/test_transition.c | $(BUILD_ROOT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -Isrc -c "$<" -o "$@"
$(BUILD_ROOT)/test_transition: $(BUILD_ROOT)/test_transition.o $(BUILD_ROOT)/src/transition.o $(BUILD_ROOT)/src/geometry.o
	$(CC) $(LDFLAGS) $^ -lm -o "$@"
$(BUILD_ROOT)/test_hotspots.o: tests/test_hotspots.c | $(BUILD_ROOT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -Isrc -c "$<" -o "$@"
$(BUILD_ROOT)/test_hotspots: $(BUILD_ROOT)/test_hotspots.o $(BUILD_ROOT)/src/hotspots.o $(BUILD_ROOT)/src/geometry.o
	$(CC) $(LDFLAGS) $^ -lm -o "$@"
mac run: all
	"$(BUILD_ROOT)/book" --root "$(CURDIR)" --book "$(BOOK)"
check: all $(BUILD_ROOT)/test_geometry $(BUILD_ROOT)/test_transition $(BUILD_ROOT)/test_hotspots
	"$(BUILD_ROOT)/test_geometry"
	"$(BUILD_ROOT)/test_transition"
	"$(BUILD_ROOT)/test_hotspots"
	python3 tests/test_book.py "$(BUILD_ROOT)/book" "$(CURDIR)"
check-ui: all
	python3 tests/test_ui.py "$(BUILD_ROOT)/book" "$(CURDIR)"
render:
	python3 tools/render.py --book "$(BOOK)" --scene "$(SCENE)" --scener "$(SCENER)" --width $(WIDTH) --height $(HEIGHT)
layout:
	cd "books/$(BOOK)/rooms" && "$(SCENER)" --layout "$(SCENE).blks" --scale 2 --format jpg --output-dir .
clean:
	rm -rf "$(BUILD_ROOT)/ipad"
	rm -f $(OBJECTS) $(OBJECTS:.o=.d) "$(BUILD_ROOT)/book"
	rm -f "$(BUILD_ROOT)/test_geometry" "$(BUILD_ROOT)/test_geometry.o" "$(BUILD_ROOT)/test_geometry.d"
	rm -f "$(BUILD_ROOT)/test_transition" "$(BUILD_ROOT)/test_transition.o" "$(BUILD_ROOT)/test_transition.d"
	rm -f "$(BUILD_ROOT)/test_hotspots" "$(BUILD_ROOT)/test_hotspots.o" "$(BUILD_ROOT)/test_hotspots.d"
-include $(OBJECTS:.o=.d) $(BUILD_ROOT)/test_geometry.d $(BUILD_ROOT)/test_transition.d $(BUILD_ROOT)/test_hotspots.d
