#!/system/bin/sh

# Define paths
MODDIR=${0%/*}
FONTS_XML_PATH="/system/etc/fonts.xml"
MODIFIED_FONTS_XML_PATH="$MODDIR/system/etc/fonts.xml"

# Copy original fonts.xml to the MODDIR to overwrite dummy file
mkdir -p "$MODDIR/system/etc"
cp "$FONTS_XML_PATH" "$MODIFIED_FONTS_XML_PATH"

# Function to add urdu family before ethi family
add_ur_arab_family() {
    if [ "$APILEVEL" -ge 31 ]; then
        # Android 12 and later format
        sed -i '/<family lang="und-Ethi">/i \
        <family lang="ur-Arab" variant="elegant"> \
            <font weight="400" style="normal" postScriptName="NotoNastaliqUrdu"> NotoNastaliqUrdu-Regular.ttf </font> \
            <font weight="700" style="normal"> NotoNastaliqUrdu-Bold.ttf </font> \
        </family>' "$MODIFIED_FONTS_XML_PATH"
    else
        # Android 11 and earlier format
        sed -i '/<family lang="und-Ethi">/a \
        <family lang="ur-Arab" variant="elegant"> \
            <font weight="400" style="normal"> NotoNastaliqUrdu-Regular.ttf </font> \
            <font weight="700" style="normal"> NotoNastaliqUrdu-Bold.ttf </font> \
        </family>' "$MODIFIED_FONTS_XML_PATH"
    fi
}

# Get Android API level
APILEVEL=$(getprop ro.build.version.sdk)

# Call the function to add the ur-Arab family language above Ethi
add_ur_arab_family

# Restart zygote for changes to take effect
stop
start