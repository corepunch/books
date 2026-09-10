.DEFAULT_GOAL := run

PLATFORM_DIR ?= ../orca/libs/platform
BUILD_DIR ?= build
BOOK ?= wondertown
SCENE ?= workshop-new
SCENER ?= $(shell command -v scener 2>/dev/null || printf '%s/.local/bin/scener' "$$HOME")
WIDTH ?= 1920
HEIGHT ?= 1440
CC ?= cc
CFLAGS ?= -O2 -g
LUA_PKG ?= $(shell for package in lua5.4 lua; do pkg-config --exists $$package 2>/dev/null && { echo $$package; break; }; done)
PLATFORM_ROOT := $(abspath $(PLATFORM_DIR))
BUILD_ROOT := $(abspath $(BUILD_DIR))
CPPFLAGS += -Ivendor -I$(PLATFORM_ROOT) $(shell pkg-config --cflags $(LUA_PKG) libxml-2.0)
CFLAGS += -std=c11 -Wall -Wextra -MMD -MP
LDLIBS += -L$(BUILD_ROOT) -lplatform $(filter-out -lm,$(shell pkg-config --libs $(LUA_PKG) libxml-2.0)) -lm
ifeq ($(shell uname -s),Darwin)
CPPFLAGS += -I$(shell xcrun --show-sdk-path)/usr/include/libxml2
PLATFORM_LIB := $(BUILD_ROOT)/libplatform.dylib
LDLIBS += -framework OpenGL
LDFLAGS += -Wl,-rpath,@loader_path
else
CPPFLAGS += -D_POSIX_C_SOURCE=200809L
PLATFORM_LIB := $(BUILD_ROOT)/libplatform.so
LDLIBS += -lGL
LDFLAGS += -Wl,-rpath,'$$ORIGIN'
endif

.PHONY: all run check render layout platform clean
all: $(BUILD_ROOT)/book
$(BUILD_ROOT):
	mkdir -p "$@"
platform: | $(BUILD_ROOT)
	$(MAKE) -C "$(PLATFORM_ROOT)" OUTDIR="$(BUILD_ROOT)"
$(PLATFORM_LIB): | platform
$(BUILD_ROOT)/main.o: main.c | $(BUILD_ROOT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c "$<" -o "$@"
$(BUILD_ROOT)/book: $(BUILD_ROOT)/main.o $(PLATFORM_LIB)
	$(CC) $(LDFLAGS) $^ $(filter-out -lplatform,$(LDLIBS)) -o "$@"
run: all
	"$(BUILD_ROOT)/book" --root "$(CURDIR)" --book "$(BOOK)"
check: all
	python3 tests/test_book.py "$(BUILD_ROOT)/book" "$(CURDIR)"
render:
	python3 tools/render.py --book "$(BOOK)" --scene "$(SCENE)" --scener "$(SCENER)" --width $(WIDTH) --height $(HEIGHT)
layout:
	cd "books/$(BOOK)/rooms" && "$(SCENER)" --layout "$(SCENE).blks" --scale 2 --format jpg --output-dir .
clean:
	rm -f "$(BUILD_ROOT)/main.o" "$(BUILD_ROOT)/main.d" "$(BUILD_ROOT)/book"
-include $(BUILD_ROOT)/main.d
