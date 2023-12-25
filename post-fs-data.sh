#!/system/bin/sh

MODDIR=${0%/*}
APILEVEL=$(getprop ro.build.version.sdk)

add_ur_arab_family() {
    if [ $APILEVEL -ge 31 ]; then
        # Android 12 and later format
        sed -i '/<family lang="und-Ethi">/i \
        <family lang="ur-Arab" variant="elegant"> \
            <font weight="400" style="normal" postScriptName="NotoNastaliqUrdu"> NotoNastaliqUrdu-Regular.ttf </font> \
            <font weight="700" style="normal"> NotoNastaliqUrdu-Bold.ttf </font> \
        </family>' $1
    else
        # Android 11 and earlier format
        sed -i '/<family lang="und-Ethi">/a \
        <family lang="ur-Arab" variant="elegant"> \
            <font weight="400" style="normal"> NotoNastaliqUrdu-Regular.ttf </font> \
            <font weight="700" style="normal"> NotoNastaliqUrdu-Bold.ttf </font> \
        </family>' $1
    fi
}

# Call the function to add the ur-Arab family language above Ethi
add_ur_arab_family /system/etc/fonts.xml
