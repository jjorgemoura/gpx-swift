MODULE  := GPXSwift
SOURCES := Sources Tests Package.swift

.DEFAULT_GOAL := lint

.PHONY: format lint test docs demo

format:
	swift format --in-place --recursive $(SOURCES)

lint:
	swift format lint --strict --recursive $(SOURCES)
	swiftlint --strict

test:
	swift test -Xswiftc -warnings-as-errors

docs:
	xcodebuild docbuild -scheme $(MODULE) -destination 'generic/platform=iOS' -quiet

demo:
	open GPXSwift.xcworkspace
