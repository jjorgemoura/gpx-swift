# The library product declared in Package.swift, so this file is identical in every repo.
MODULE  := $(shell grep -m1 '\.library' Package.swift | cut -d'"' -f2)
SOURCES := Sources Tests Examples Package.swift

.DEFAULT_GOAL := lint
.PHONY: format lint lint-xcode analyse test docs demo

format:
	swift format --in-place --recursive $(SOURCES)

lint:
	swift format lint --strict --recursive $(SOURCES)
	swiftlint --strict --no-cache $(SOURCES)

lint-xcode:
	@if command -v swiftlint >/dev/null; then \
		swiftlint lint $(SOURCES); \
	else \
		echo "warning: SwiftLint not installed, skipping"; \
	fi

# Analyzer rules need a compiler log from a clean build, so this is slow.
analyse:
	@rm -rf .build/analyse && mkdir -p .build
	swift build --scratch-path .build/analyse -v > .build/analyse.log 2>&1 || (tail -20 .build/analyse.log; exit 1)
	swiftlint analyze --compiler-log-path .build/analyse.log

test:
	swift test -Xswiftc -warnings-as-errors

docs:
	xcodebuild docbuild -scheme $(MODULE) -destination 'generic/platform=iOS' -quiet \
		OTHER_DOCC_FLAGS=--warnings-as-errors

demo:
	open $(MODULE).xcworkspace
