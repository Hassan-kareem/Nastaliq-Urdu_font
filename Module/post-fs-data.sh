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
    
    # Copy original configuration to temp file
    cp "$src_file" "$temp_file"
    
    # Avoid duplicate mappings if ur-Arab is already present
    if grep -q 'lang="ur-Arab"' "$temp_file"; then
        rm -f "$temp_file"
        return 0
    fi
    
    # Method 1: Insert before und-Ethi fallback
    if grep -q 'lang="und-Ethi"' "$temp_file"; then
        sed -i '/lang="und-Ethi"/i \
    <family lang="ur-Arab" variant="elegant"> \
        <font weight="400" style="normal" postScriptName="NotoNastaliqUrdu">NotoNastaliqUrdu-Regular.ttf</font> \
        <font weight="700" style="normal">NotoNastaliqUrdu-Bold.ttf</font> \
    </family>' "$temp_file"
    # Method 2: Insert after fallback fonts comment
    elif grep -q '<!-- fallback fonts -->' "$temp_file"; then
        sed -i '/<!-- fallback fonts -->/a \
    <family lang="ur-Arab" variant="elegant"> \
        <font weight="400" style="normal">NotoNastaliqUrdu-Regular.ttf</font> \
        <font weight="700" style="normal">NotoNastaliqUrdu-Bold.ttf</font> \
    </family>' "$temp_file"
    fi
    
    # Method 3: Backup fallback (insert before closing familyset tag)
    if ! grep -q 'lang="ur-Arab"' "$temp_file"; then
        sed -i '/<\/familyset>/i \
    <family lang="ur-Arab" variant="elegant"> \
        <font weight="400" style="normal" postScriptName="NotoNastaliqUrdu">NotoNastaliqUrdu-Regular.ttf</font> \
        <font weight="700" style="normal">NotoNastaliqUrdu-Bold.ttf</font> \
    </family>' "$temp_file"
    fi
    
    # Anti-bootloop validation guard
    if [ -s "$temp_file" ] && grep -q 'lang="ur-Arab"' "$temp_file" && grep -q '</familyset>' "$temp_file"; then
        # Apply patched configuration if valid
        mv "$temp_file" "$dest_file"
        chmod 644 "$dest_file"
    else
        # Discard invalid temporary files
        rm -f "$temp_file"
    fi
}

# Apply patches dynamically based on API level
if [ "$APILEVEL" -le 30 ]; then
    if [ -f "$FONTS_XML_PATH" ]; then
        patch_font_xml "$FONTS_XML_PATH" "$MODIFIED_FONTS_XML_PATH"
    fi
else
    # Android 12 and above (API 31+)
    if [ -f "$FONT_FALLBACK_XML_PATH" ]; then
        patch_font_xml "$FONT_FALLBACK_XML_PATH" "$MODIFIED_FONT_FALLBACK_XML_PATH"
    fi
    if [ -f "$FONTS_XML_PATH" ]; then
        patch_font_xml "$FONTS_XML_PATH" "$MODIFIED_FONTS_XML_PATH"
    fi
fi