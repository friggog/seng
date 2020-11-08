#!/bin/sh
./b.sh TARGET=simulator:clang:latest:8.0
xcrun simctl spawn booted launchctl debug system/com.apple.SpringBoard --environment DYLD_INSERT_LIBRARIES=/Users/Charlie/Dropbox/Tweaks/seng/seng/.theos/obj/iphone_simulator/debug/seng.dylib
xcrun simctl spawn booted launchctl stop com.apple.SpringBoard
