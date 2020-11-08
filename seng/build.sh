#!/bin/sh

RED='\e[36m'
NC='\e[0m'

if [ $# == 1 ]
then
    if [ $1 == "final" ]
    then
        FINAL=true
    else
        IP_ADDRESS=$1
    fi
elif [ $# == 2 ]
then
    FINAL=true
    IP_ADDRESS=$2
fi

TWEAK_NAME="seng"
PREFS_NAME="sengPrefs"

printf "${RED}~~~~ MAKING ~~~~${NC}\n"
cp -R ../Localisations/$TWEAK_NAME/ $PREFS_NAME/Resources
if [ $FINAL ]
then
    export DEBUG=0
    DEBUG_PATH=""
else
    export DEBUG=1
    DEBUG_PATH="debug/"
fi
make
printf "${RED}~~~~ COPYING ~~~~${NC}\n"
rm -f me.chewitt.$TWEAK_NAME/Library/MobileSubstrate/DynamicLibraries/$TWEAK_NAME.dylib
cp obj/"$DEBUG_PATH""$TWEAK_NAME".dylib me.chewitt."$TWEAK_NAME"/Library/MobileSubstrate/DynamicLibraries/"$TWEAK_NAME".dylib
rm -f -r me.chewitt.$TWEAK_NAME/Library/PreferenceBundles/$PREFS_NAME.bundle
cp -R $PREFS_NAME/obj/"$DEBUG_PATH""$PREFS_NAME".bundle me.chewitt."$TWEAK_NAME"/Library/PreferenceBundles/"$PREFS_NAME".bundle
printf "${RED}~~~~ REMOVING .DS_STOREs ~~~~${NC}\n"
find . -name .DS_Store -print -delete

if [ $FINAL ]
then
    printf "${RED}~~~~ CRUSHING .PNGs ~~~~${NC}\n"
    cp -R me.chewitt.$TWEAK_NAME ./me.chewitt."$TWEAK_NAME"_r
    find me.chewitt."$TWEAK_NAME"_r -name "*.png" -exec pincrush -i {} \;
    printf "${RED}~~~~ BINARISING .PLISTs ~~~~${NC}\n"
    find me.chewitt."$TWEAK_NAME"_r -name "*.plist" -exec plutil -convert binary1 {} \;
    printf "${RED}~~~~ PACKAGING ~~~~${NC}\n"
    dpkg-deb -Zgzip -b me.chewitt."$TWEAK_NAME"_r me.chewitt.temp.deb
    rm -R me.chewitt."$TWEAK_NAME"_r
else
    printf "${RED}~~~~ PACKAGING ~~~~${NC}\n"
    dpkg-deb -Zgzip -b me.chewitt."$TWEAK_NAME" me.chewitt.temp.deb
fi

DEB_VERSION=`dpkg-deb -f me.chewitt.temp.deb | sed -n -e 's/^.*Version: //p'`

mv me.chewitt.temp.deb me.chewitt."$TWEAK_NAME"_"$DEB_VERSION"_iphoneos-arm.deb

if ! [ -z $IP_ADDRESS ]
then
printf "${RED}~~~~ INSTALLING ~~~~${NC}\n"
scp me.chewitt."$TWEAK_NAME"_"$DEB_VERSION"_iphoneos-arm.deb root@"$IP_ADDRESS":/var/mobile/Documents/me.chewitt.temp.deb
ssh root@"$IP_ADDRESS" dpkg -i /var/mobile/Documents/me.chewitt.temp.deb
ssh root@"$IP_ADDRESS" rm /var/mobile/Documents/me.chewitt.temp.deb
#ssh root@"$IP_ADDRESS" killall SpringBoard
fi