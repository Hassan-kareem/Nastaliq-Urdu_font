#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk changes its mount point in the future
MODDIR=${0%/*}
# This script will be executed in post-fs-data mode

APILEVEL=$(getprop ro.build.version.sdk)

# Copy original fonts.xml to the MODDIR to overwrite dummy file
mkdir -p $MODDIR/system/etc
cp /system/etc/fonts.xml $MODDIR/system/etc

# Function to add urdu family before ethi family
add_urdu_family() {
    sed -i '/<family lang="und-Ethi">/i \
    <family lang="ur-Arab" variant="elegant"> \
        <font weight="400" style="normal" postScriptName="NotoNastaliqUrdu"> NotoNastaliqUrdu-Regular.ttf </font> \
        <font weight="700" style="normal"> NotoNastaliqUrdu-Bold.ttf </font> \
    </family>' $1
}

# Call the function to add urdu family
add_urdu_family $MODDIR/system/etc/fonts.xml
