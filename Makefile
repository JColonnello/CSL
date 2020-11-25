SOURCE_DIR := src
GENERATED_DIR := generated
BUILD_DIR := build
TARGET := csl

SOURCES := $(shell find $(SOURCE_DIR)/ -type f -name "*.c")
OBJS := $(SOURCES:%.c=$(BUILD_DIR)/%.o)
DEP_FLAGS := -MMD -MP
CFLAGS += -g -I $(GENERATED_DIR) $(DEP_FLAGS)
OBJS_GRAMMAR := $(BUILD_DIR)/$(GENERATED_DIR)/grammar.tab.o $(BUILD_DIR)/$(GENERATED_DIR)/tokens.o
ifeq ($(DEBUG),1)
BISON_DEBUG := --debug --verbose
endif


all: $(BUILD_DIR)/$(TARGET)

clean:
	rm -rf generated build

rebuild: clean all

$(GENERATED_DIR)/grammar.tab.c: $(BUILD_DIR)/$(GENERATED_DIR)/.grammar
$(GENERATED_DIR)/grammar.tab.h: $(BUILD_DIR)/$(GENERATED_DIR)/.grammar

$(BUILD_DIR)/$(GENERATED_DIR)/.grammar: grammar.y
	$(MKDIR_P) $(GENERATED_DIR)
	$(MKDIR_P) $(BUILD_DIR)/$(GENERATED_DIR)
	bison -d $(BISON_DEBUG) -b generated/grammar $<
	touch $@

$(GENERATED_DIR)/tokens.c: tokens.l
	$(MKDIR_P) $(dir $@)
	flex -o $@ $<

$(BUILD_DIR)/$(TARGET): $(OBJS_GRAMMAR) $(OBJS)
	$(MKDIR_P) $(dir $@)
	$(CC) $(CFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

-include $(OBJECTS:%.o=%.d)

MKDIR_P ?= mkdir -p

.PHONY: all clean rebuild