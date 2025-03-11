#!/bin/sh

# Specify the file path to write Dart defines.
# Here, we will create a file named `Dart-Defines.xcconfig`.
OUTPUT_FILE="${SRCROOT}/Flutter/Dart-Defines.xcconfig"
# To prevent old properties from remaining when the contents of Dart defines are changed, we first empty the file.
: > $OUTPUT_FILE

# This function decodes Dart defines.
function decode_url() { echo "${*}" | base64 --decode; }

IFS=',' read -r -a define_items <<<"$DART_DEFINES"

for index in "${!define_items[@]}"
do
    item=$(decode_url "${define_items[$index]}")
    # Dart defines include items automatically defined by Flutter.
    # However, if these definitions are written out, the build will fail due to errors,
    # so items starting with flutter or FLUTTER are not output.
    lowercase_item=$(echo "$item" | tr '[:upper:]' '[:lower:]')
    if [[ $lowercase_item != flutter* ]]; then
        echo "$item" >> "$OUTPUT_FILE"
    fi
done