PROJECT := FloatCal.xcodeproj
SCHEME := FloatCal
CONFIG := Debug
DERIVED_DATA := .build/DerivedData
APP_PATH := $(DERIVED_DATA)/Build/Products/$(CONFIG)/FloatCal.app

.PHONY: all build run clean

all: build

build:
	@echo "Building $(SCHEME)..."
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) -derivedDataPath $(DERIVED_DATA) build

run: build
	@echo "Killing existing FloatCal..."
	-killall FloatCal 2>/dev/null || true
	@echo "Launching $(APP_PATH)..."
	open $(APP_PATH)

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(DERIVED_DATA)
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean
