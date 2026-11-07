MODULE  := GPXSwift
SOURCES := Sources Tests Examples Package.swift

.DEFAULT_GOAL := lint

.PHONY: format lint lint-xcode test docs demo

format:
	swift format --in-place --recursive $(SOURCES)

lint:
	swift format lint --strict --recursive $(SOURCES)
	swiftlint --strict $(SOURCES)

# Non-strict SwiftLint for the Xcode build phase: warnings only, skipped if not installed.
lint-xcode:
	@if command -v swiftlint >/dev/null; then \
		swiftlint lint $(SOURCES); \
	else \
		echo "warning: SwiftLint not installed, skipping"; \
	fi

test:
	swift test -Xswiftc -warnings-as-errors

docs:
	xcodebuild docbuild -scheme $(MODULE) -destination 'generic/platform=iOS' -quiet

demo:
	open GPXSwift.xcworkspace
