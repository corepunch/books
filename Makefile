.DEFAULT_GOAL := run

BUILD_DIR ?= build
BOOK ?= salt
SCENE ?= train
SCENER ?= $(shell command -v scener 2>/dev/null || printf '%s/.local/bin/scener' "$$HOME")
WIDTH ?= 1920
HEIGHT ?= 1440
# Plan views of large exterior scenes need fewer pixels per centimetre.
LAYOUT_SCALE ?= 2
CC ?= cc
CFLAGS ?= -O2 -g
BUILD_ROOT := $(abspath $(BUILD_DIR))
BOOK_BUILD_ROOT := $(BUILD_ROOT)/$(BOOK)
# A book is XML, books/<name>/title.xml and its locations, read at launch.
BOOK_XML := $(wildcard books/$(BOOK)/title.xml)
# Each book is read by tests/test_<name>.py.
BOOK_TEST := $(wildcard tests/test_$(BOOK).py)
ifeq ($(BOOK_TEST),)
$(error No test for BOOK='$(BOOK)' (expected tests/test_$(BOOK).py))
endif
ifeq ($(BOOK_XML),)
$(error No book '$(BOOK)' (expected books/$(BOOK)/title.xml))
endif
SOURCES := $(filter-out src/cli.c,$(wildcard src/*.c))
NATIVE_SOURCES := src/macos.m src/metal.m src/video.m
OBJECTS := $(patsubst %.c,$(BOOK_BUILD_ROOT)/%.o,$(SOURCES)) $(patsubst %.m,$(BOOK_BUILD_ROOT)/%.o,$(NATIVE_SOURCES))
# The book tool reads books through the same loader, runtime and scene reader.
CLI_ROOT := $(BUILD_ROOT)/cli
CLI := $(CLI_ROOT)/book
CLI_SOURCES := src/cli.c src/story.c src/storyxml.c src/scene.c src/hotspots.c src/geometry.c src/common.c
CLI_OBJECTS := $(patsubst %.c,$(CLI_ROOT)/%.o,$(CLI_SOURCES))
# Placeholder clips: one still held for a while, encoded with AVFoundation.
STILLCLIP := $(BUILD_ROOT)/tools/stillclip
CPPFLAGS += -Isrc -Ivendor $(shell pkg-config --cflags libxml-2.0)
CFLAGS += -std=c11 -Wall -Wextra -Werror=switch-enum -MMD -MP
XML_LIBS := $(filter-out -lm,$(shell pkg-config --libs libxml-2.0))
LDLIBS += $(XML_LIBS) -lm
ifneq ($(shell uname -s),Darwin)
$(error Book requires macOS with AppKit and Metal)
endif
CPPFLAGS += -I$(shell xcrun --show-sdk-path)/usr/include/libxml2
LDLIBS += -framework AppKit -framework Metal -framework QuartzCore -framework AVFoundation -framework CoreMedia -framework CoreVideo

.PHONY: all cli run mac check check-ui render layout placeholders clean ipad ipad-simulator ipad-mac ipad-run ipad-deploy list-devices
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
cli: $(CLI)
$(CLI_ROOT)/%.o: %.c
	mkdir -p "$(@D)"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c "$<" -o "$@"
$(CLI): $(CLI_OBJECTS)
	$(CC) $(LDFLAGS) $^ $(XML_LIBS) -lm -o "$@"
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
check: $(BOOK_BUILD_ROOT)/book $(BOOK_BUILD_ROOT)/test_geometry $(BOOK_BUILD_ROOT)/test_transition $(BOOK_BUILD_ROOT)/test_hotspots $(CLI) $(STILLCLIP)
	python3 tests/test_cli.py "$(CLI)" "$(CURDIR)" "$(BOOK)"
	python3 tests/test_engine.py "$(BOOK_BUILD_ROOT)/book" "$(CLI)" "$(CURDIR)" "$(STILLCLIP)"
	"$(BOOK_BUILD_ROOT)/test_geometry"
	"$(BOOK_BUILD_ROOT)/test_transition"
	"$(BOOK_BUILD_ROOT)/test_hotspots"
	python3 "$(BOOK_TEST)" "$(BOOK_BUILD_ROOT)/book" "$(CURDIR)"
check-ui: $(BOOK_BUILD_ROOT)/book
	python3 tests/test_ui.py "$(BOOK_BUILD_ROOT)/book" "$(CURDIR)" "$(BOOK)"
$(STILLCLIP): tools/stillclip.m
	mkdir -p "$(@D)"
	$(CC) $(CFLAGS) -fobjc-arc "$<" -framework AVFoundation -framework CoreMedia -framework CoreVideo -framework CoreGraphics -framework ImageIO -framework Foundation -o "$@"
# Solid-colour stills and clips with their names, briefs, anchors and prose, for playing a
# book before it is drawn. Finished art (illustrations/, or files without the marker) is kept.
placeholders: $(STILLCLIP)
	python3 tools/placeholder.py --book "$(BOOK)" --stillclip "$(STILLCLIP)"
render:
	python3 tools/render.py --book "$(BOOK)" --scene "$(SCENE)" --scener "$(SCENER)" --width $(WIDTH) --height $(HEIGHT)
layout:
	cd "books/$(BOOK)/rooms" && "$(SCENER)" --layout "$(SCENE).blks" --scale $(LAYOUT_SCALE) --format jpg --output-dir .
clean:
	rm -rf "$(BUILD_ROOT)"
-include $(OBJECTS:.o=.d) $(CLI_OBJECTS:.o=.d) $(BOOK_BUILD_ROOT)/test_geometry.d $(BOOK_BUILD_ROOT)/test_transition.d $(BOOK_BUILD_ROOT)/test_hotspots.d
