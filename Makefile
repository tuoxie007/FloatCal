
debug:
	xcodebuild -configuration Debug -project FloatCal.xcodeproj -scheme FloatCal -derivedDataPath build

run: debug
	killall FloatCal ; open build/Build/Products/Debug/FloatCal.app
