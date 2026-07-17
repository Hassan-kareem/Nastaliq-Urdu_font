#!/system/bin/sh

MODDIR=${0%/*}
FONTS_XML_PATH="/system/etc/fonts.xml"
FONT_FALLBACK_XML_PATH="/system/etc/font_fallback.xml"
MODIFIED_FONTS_XML_PATH="$MODDIR/system/etc/fonts.xml"
MODIFIED_FONT_FALLBACK_XML_PATH="$MODDIR/system/etc/font_fallback.xml"
APILEVEL=$(getprop ro.build.version.sdk)

mkdir -p "$MODDIR/system/etc"

patch_font_xml() {
    local src_file="$1"
    local dest_file="$2"
    local temp_file="${dest_file}.tmp"
    
    # Original file ko temp path par copy karo
    cp "$src_file" "$temp_file"
    
    # 1. Standard Android check (und-Ethi se pehle insert karo)
    if grep -q 'lang="und-Ethi"' "$temp_file"; then
        sed -i '/lang="und-Ethi"/i \
    <family lang="ur-Arab" variant="elegant"> \
        <font weight="400" style="normal" postScriptName="NotoNastaliqUrdu"> NotoNastaliqUrdu-Regular.ttf </font> \
        <font weight="700" style="normal"> NotoNastaliqUrdu-Bold.ttf </font> \
    </family>' "$temp_file"
    # 2. Legacy Android check (fallback comment ke baad insert karo)
    elif grep -q '<!-- fallback fonts -->' "$temp_file"; then
        sed -i '/<!-- fallback fonts -->/a \
    <family lang="ur-Arab" variant="elegant"> \
        <font weight="400" style="normal"> NotoNastaliqUrdu-Regular.ttf </font> \
        <font weight="700" style="normal"> NotoNastaliqUrdu-Bold.ttf </font> \
    </family>' "$temp_file"
    fi
    
    # 3. Backup Fallback: Agar upar ke dono tareeqe fail ho gaye, toh </familyset> se pehle insert karo
    if ! grep -q 'lang="ur-Arab"' "$temp_file"; then
        sed -i '/<\/familyset>/i \
    <family lang="ur-Arab" variant="elegant"> \
        <font weight="400" style="normal" postScriptName="NotoNastaliqUrdu"> NotoNastaliqUrdu-Regular.ttf </font> \
        <font weight="700" style="normal"> NotoNastaliqUrdu-Bold.ttf </font> \
    </family>' "$temp_file"
    fi
    
    # --- ANTI-BOOTLOOP VALIDATION GUARD ---
    if [ -s "$temp_file" ] && grep -q 'lang="ur-Arab"' "$temp_file" && grep -q '</familyset>' "$temp_file"; then
        # Validation Succeeded: Safe to apply!
        mv "$temp_file" "$dest_file"
        chmod 644 "$dest_file"
    else
        # Validation Failed: System ko bootloop se bachane ke liye abort karo
        rm -f "$temp_file"
    fi
}

# Dynamic patching according to Android version
if [ "$APILEVEL" -le 30 ]; then
    if [ -f "$FONTS_XML_PATH" ]; then
        patch_font_xml "$FONTS_XML_PATH" "$MODIFIED_FONTS_XML_PATH"
    fi
else
    # Android 12+ targets (API 31+)
    if [ -f "$FONT_FALLBACK_XML_PATH" ]; then
        patch_font_xml "$FONT_FALLBACK_XML_PATH" "$MODIFIED_FONT_FALLBACK_XML_PATH"
    fi
    if [ -f "$FONTS_XML_PATH" ]; then
        patch_font_xml "$FONTS_XML_PATH" "$MODIFIED_FONTS_XML_PATH"
    fi
fi