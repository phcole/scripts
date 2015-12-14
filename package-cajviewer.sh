#!/bin/bash

current_home_path="${HOME}"
origin_bottle_name="cajviewer"
public_bottle_name="Deepin-CAJViewer"
public_bottle_uuid="155c084b-ff37-4084-949f-f7b25a0ef3c4"
desktop_file_categories="reading;"
deb_package_name="deepinwine-cajviewer"
deb_version_string="7.2.113.0deepin0"
deb_description="CNKI CAJViewer on CrossOver Deepin"

sudo ./script-packager.sh "$current_home_path" "$origin_bottle_name" "$public_bottle_name" "$public_bottle_uuid" "$desktop_file_categories" "$deb_package_name" "$deb_version_string" "$deb_description"
