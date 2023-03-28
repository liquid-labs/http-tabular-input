# liq-alert/Makefile

# Copyright 2022, Liquid Labs, LLC. All rights reserved.

## Variables and target identification

MAIN_KEY:=http-tabular-input

### Project parameters

### Static scripts and paths
CATALYST_SCRIPTS:=npx catalyst-scripts

SRC:=src
DIST:=dist

MAIN:=$(DIST)/$(MAIN_KEY).js

### Dynamic build targets
MAIN_FILES:=$(shell find $(SRC) \( -name "*.js" -o -name "*.mjs" \) -not -path "*/test/*" -not -name "*.test.js")

BUILD_TARGETS:=$(MAIN)

### Dynamic test targets
MAIN_TEST_SRC_FILES:=$(shell find $(SRC) -name "*.test.js")
MAIN_TEST_BUILT_FILES=$(patsubst $(SRC)/%, test-staging/%, $(MAIN_TEST_SRC_FILES))

## Rules

default: build

all: build # classic make convention

build: $(BUILD_TARGETS)

clean:
	rm -rf $(DIST)

## Rules

### Build rules
$(MAIN): package.json $(MAIN_FILES)
	JS_SRC=$(SRC) JS_OUT=$@ $(CATALYST_SCRIPTS) build

$(MAIN_TEST_BUILT_FILES) &: $(MAIN_TEST_SRC_FILES)
	JS_SRC=$(SRC) $(CATALYST_SCRIPTS) pretest

### QA rules

# Test and lint.

# $(MAIN_TEST_BUILT_DATA): test-staging/%: $(SRC)%
# 	mkdir -p $(dir $@)
# 	cp $< $@

# test: $(MAIN_TEST_BUILT_FILES) $(MAIN_TEST_BUILT_DATA)
#	JS_SRC=test-staging $(CATALYST_SCRIPTS) test

last-lint.txt: $(ALL_FILES)
	( set -e; set -o pipefail; \
		JS_LINT_TARGET=$(SRC) $(CATALYST_SCRIPTS) lint | tee last-lint.txt; )

lint: last-lint.txt

lint-fix:
	JS_SRC=$(SRC) $(CATALYST_SCRIPTS) lint-fix

qa: lint # test

## Configurations and settings

.DELETE_ON_ERROR:

# skip use of implicit rules
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

.PHONY: all build clean lint lint-fix # qa test
