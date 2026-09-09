.DEFAULT_GOAL := all

# Use the sibling platform checkout available in the developer workspace.
# Override PLATFORM_DIR when building from a different workspace layout.
PLATFORM_DIR ?= ../../platform
BUILD_DIR ?= ../build/standalone
PLATFORM_ROOT := $(abspath $(PLATFORM_DIR))
BUILD_ROOT := $(abspath $(BUILD_DIR))
BOOK_ROOT := $(abspath ..)
LUA ?= lua
LUA_PKG ?= $(shell for package in lua5.4 lua; do pkg-config --exists $$package 2>/dev/null && { echo $$package; break; }; done)
CC ?= cc
CFLAGS ?= -O2 -g
CPPFLAGS += -I. -Ivendor -I$(PLATFORM_ROOT) $(shell pkg-config --cflags $(LUA_PKG) 2>/dev/null)
CFLAGS += -std=c11 -Wall -Wextra -MMD -MP
LUA_LIBS := $(shell pkg-config --libs $(LUA_PKG) 2>/dev/null)
LDLIBS += -L$(BUILD_ROOT) -lplatform $(filter-out -lm,$(LUA_LIBS)) -lm

ifeq ($(shell uname -s),Darwin)
PLATFORM_LIB := $(BUILD_ROOT)/libplatform.dylib
LDLIBS += -framework OpenGL
LDFLAGS += -Wl,-rpath,@loader_path
else
PLATFORM_LIB := $(BUILD_ROOT)/libplatform.so
CPPFLAGS += -D_POSIX_C_SOURCE=200809L
LDLIBS += -lGL
LDFLAGS += -Wl,-rpath,'$$ORIGIN'
endif

OBJECTS := $(addprefix $(BUILD_ROOT)/,main.o render.o)

.PHONY: all run check clean check-deps platform
all: $(BUILD_ROOT)/book

check-deps:
	@test -f "$(PLATFORM_ROOT)/platform.h" || { echo 'Set PLATFORM_DIR to the libplatform source directory.'; exit 1; }
	@test -n "$(LUA_PKG)" || { echo 'Lua development files and pkg-config are required (lua5.4 or lua).'; exit 1; }

$(BUILD_ROOT):
	mkdir -p "$@"

platform: | check-deps $(BUILD_ROOT)
	$(MAKE) -C "$(PLATFORM_ROOT)" OUTDIR="$(BUILD_ROOT)"

$(PLATFORM_LIB): | platform

$(BUILD_ROOT)/%.o: %.c | check-deps $(BUILD_ROOT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c "$<" -o "$@"

$(BUILD_ROOT)/book: $(OBJECTS) $(PLATFORM_LIB)
	$(CC) $(LDFLAGS) $(OBJECTS) $(LDLIBS) -o "$@"

run: all
	"$(BUILD_ROOT)/book" "$(BOOK_ROOT)"

check: all
	cd /tmp && $(LUA) "$(BOOK_ROOT)/Standalone/test_scene.lua" "$(BOOK_ROOT)"
	cd /tmp && $(LUA) "$(BOOK_ROOT)/Standalone/test_book.lua" "$(BOOK_ROOT)"
	cd /tmp && "$(BUILD_ROOT)/book" "$(BOOK_ROOT)" --check

clean:
	rm -f $(OBJECTS) $(OBJECTS:.o=.d) "$(BUILD_ROOT)/book" "$(PLATFORM_LIB)"

-include $(OBJECTS:.o=.d)
