#!/bin/bash

# CrossOver needs following dependencies to build a deb package
#"dh_builddeb"       => "debhelper",
#"dpkg-buildpackage" => "dpkg-dev",
#"fakeroot"          => "fakeroot"

BOTTLE_MANAGER=/opt/cxoffice/bin/cxbottle

detect_apply_patch()
{
    tmpfile=`mktemp -t dcpt-XXXXXXXXXXXX`
    a=`patch --dry-run --forward "$1" "$2" -o"$tmpfile"`
    if [ "#$?" == "#0" ]; then
        echo "need apply patch to: $1"
        sudo patch "$1" "$2"
    else
        b=${a##*out of * hunk* }
        if [ "$b" == "ignored" ]; then
            :
        elif [ "$b" == "FAILED" ]; then
            echo "deb build failed. found expired cx patch: $2"
            exit 1
        else
            echo "unknown error."
            echo "$b"
            exit 1
        fi
    fi
    rm $tmpfile
}

cx_apply_patches()
{
    echo "==>check crossover patches..."
    detect_apply_patch "/opt/cxoffice/bin/cxbottle" "patch/cxbottle.patch"
    detect_apply_patch "/opt/cxoffice/share/crossover/cxbottle/deb.changelog" "patch/deb.changelog.patch"
    detect_apply_patch "/opt/cxoffice/share/crossover/cxbottle/deb.control" "patch/deb.control.patch"
    echo "<==done."
}

remove_public_bottle()
{
    if [ -d "/opt/cxoffice/support/$public_bottle_name/" ]; then
        echo "==>Remove existing public bottle..."
        sudo $BOTTLE_MANAGER --bottle="$public_bottle_name" --removeall --delete --force
        echo "<==Done."
    fi

    if [ -d "$HOME/.cxoffice/$public_bottle_name/" ]; then
        echo "==>Remove existing stub bottle..."
        rm -rf "$HOME/.cxoffice/$public_bottle_name"
        echo "<==Done."
    fi
}

make_public_bottle()
{
    echo "==>Make Public Bottle..."
    sudo $BOTTLE_MANAGER --bottle="$public_bottle_name" --copy="$HOME/.cxoffice/$origin_bottle_name" --install --scope=managed --set-uuid="$public_bottle_uuid"
    echo "<==Done."
}

make_deb_from_bottle()
{
    echo "==>Start Packaging..."
    sudo $BOTTLE_MANAGER --bottle="$public_bottle_name" --scope managed --deb --description="$deb_description" --release="$deb_version_string" --packager="Deepin"  --hardcode --pkgname="$deb_package_name"
    echo "<==Done."
}

correct_desktop_file_categories()
{
    echo "==>Correct desktop file categories..."
    sudo find /usr/local/share/applications/ -iname "cxmenu-cxoffice-$public_bottle_uuid-*.desktop" -exec sed -i "s#Categories=.*#Categories=$desktop_file_categories#" {} \;
    echo "<==Done."
}

remove_symlinks()
{
    echo "==>remove symlinks..."
    sudo rm -fv "/opt/cxoffice/bin/nodetool"
    sudo rm -fv "/opt/cxoffice/bin/tdxw"
    echo "<==Done."
}

#================main start================
if [ -z "$origin_bottle_name" ] \
        || [ -z "$public_bottle_name" ] \
        || [ -z "$public_bottle_uuid" ] \
        || [ -z "$desktop_file_categories" ] \
        || [  -z "$deb_package_name" ] \
        || [  -z "$deb_version_string" ] \
        || [  -z "$deb_description" ]; then
	echo "usage: not enough params"
	exit 1
fi

# detect the prefix exist
if [ ! -d "$HOME/.cxoffice/$origin_bottle_name" ]; then
    echo "prefix do not exists"
    exit 1
fi

echo "current home path:        $HOME"
echo "source bottle:            $origin_bottle_name"
echo "public bottle name:       $public_bottle_name"
echo "public bottle uuid:       $public_bottle_uuid"
echo "desktop file categories:  $desktop_file_categories"
echo "deb package name:         $deb_package_name"
echo "deb package description:  $deb_description"
echo "deb package version:      $deb_version_string"

# make sure crossover can produce a desktop file for launcher
if [ ! -d "/etc/xdg/menus/applications-merged" ]; then
    sudo mkdir "/etc/xdg/menus/applications-merged"
fi

cx_apply_patches
remove_public_bottle
make_public_bottle
correct_desktop_file_categories
remove_symlinks
make_deb_from_bottle
remove_public_bottle

exit 0
