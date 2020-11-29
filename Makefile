SOURCE_DIR := src
GENERATED_DIR := generated
BUILD_DIR := build
EXAMPLES_DIR := examples
TARGET := csl

SOURCES := $(shell find $(SOURCE_DIR)/ -type f -name "*.c")
OBJS := $(SOURCES:%.c=$(BUILD_DIR)/%.o)
TESTS := $(shell find $(EXAMPLES_DIR)/ -type f -name "*.csl")

DEP_FLAGS := -MMD -MP
CFLAGS += -g -std=gnu11 -I$(GENERATED_DIR) -I$(SOURCE_DIR) $(DEP_FLAGS)
OBJS_GRAMMAR := $(BUILD_DIR)/$(GENERATED_DIR)/grammar.tab.o $(BUILD_DIR)/$(GENERATED_DIR)/grammar.o
ifeq ($(DEBUG),1)
BISON_DEBUG := --debug -r states,solved
endif

all: $(BUILD_DIR)/$(TARGET)

clean:
	rm -rf generated build

rebuild: clean all

tests: $(TESTS:%.csl=$(GENERATED_DIR)/%.glsl)

$(GENERATED_DIR)/%.tab.c $(GENERATED_DIR)/%.tab.h: %.y
	$(MKDIR_P) $(GENERATED_DIR)
	$(MKDIR_P) $(BUILD_DIR)/$(GENERATED_DIR)
	bison -d $(BISON_DEBUG) -b generated/$* $<

$(GENERATED_DIR)/%.c: %.l $(GENERATED_DIR)/%.tab.h
	$(MKDIR_P) $(dir $@)
	flex -o $@ $<

$(BUILD_DIR)/%.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/$(TARGET): $(OBJS_GRAMMAR) $(OBJS)
	$(MKDIR_P) $(dir $@)
	$(CC) $(CFLAGS) -o $@ $^

$(GENERATED_DIR)/%.glsl: %.csl $(BUILD_DIR)/$(TARGET)
	$(MKDIR_P) $(dir $@)
	$(BUILD_DIR)/$(TARGET) $< $@

-include $(OBJECTS:%.o=%.d)

MKDIR_P ?= mkdir -p

.PHONY: all clean rebuild tests