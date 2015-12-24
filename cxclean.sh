#!/bin/sh

WINE="/opt/cxoffice/bin/wine"

remove_file()
{
    echo "============remove [$1]"
    rm -rfv "$1"
}

purge_dir()
{
    echo "=============clean [$1]"
    if [ -e "$1" ]; then
        find "$1" -mindepth 1 -ignore_readdir_race -exec rm -rfv {} \;
    else
        mkdir -p "$1"
    fi
}

shutdown_bottle()
{
    echo "==>Shutdown Original Bottle..."
    $WINE --bottle="$BottleName" --no-update --wl-app wineboot.exe -- --end-session --shutdown --force --kill

    # i don't know why 1 for not running, 0 for running....
    while [ "$?" -eq "0" ]; do $WINE --bottle="$BottleName" --no-update --ux-app wineserver -k0;done
    echo "<==done."
}

clean_gecko()
{
    if [ ! -e "bin/gecko-cleaner" ]; then
        echo "gecko cleaner found, skip."
        return
    fi

    bin/gecko-cleaner -bottle="$BottleName"
#    /opt/cxoffice/bin/wine --bottle="$BottleName" reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\{2DA75DC7-0865-4BAD-BA86-074500CC350E}" # 2.24
#    /opt/cxoffice/bin/wine --bottle="$BottleName" reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\{43E91AE4-1065-4255-B035-3035D5287CF8}" # 2.40
#    # remove all old gecko kernels
#    for i in $(ls "$BottleBase/windows/system32/gecko/" | grep -v plugin | sort -V |head -n -1);do
    for i in $(ls "$BottleBase/windows/system32/gecko/" | grep -v plugin);do
        echo "=============remove gecko dir [$i]"
        rm -rfv "$BottleBase/windows/system32/gecko/$i"
    done
}

clean_temp()
{
    purge_dir   "$BottleBase/windows/temp"
    purge_dir   "$BottleBase/windows/Installer"
    purge_dir   "$BottleBase/users/crossover/Temp"
    purge_dir   "$BottleBase/users/Public/Temp"
    purge_dir   "$BottleBase/users/crossover/Cookies"
    purge_dir   "$BottleBase/users/crossover/Recent"
    remove_file "$BottleBase/users/crossover/Application Data/pcmaster"
    purge_dir   "$BottleBase/users/crossover/Application Data/wine_gecko"
    purge_dir   "$BottleBase/users/crossover/Local Settings/Temporary Internet Files"
    remove_file "$BottleBase/users/phcole"
}

cleanup_qq()
{
    if [ ! -e "$BottleBase/Program Files/Tencent/QQ/Bin/QQ.exe" ];then return;fi

    echo "++++QQ detected. cleaning..."
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/AndroidAssist"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/AndroidServer"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/DeskUpdate"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/Logs"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQ/commonf_inst"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQ/InstallPackageDR"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQ/Misc"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQ/AuTemp"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQ/STemp"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQ/Temp"
    remove_file "$BottleBase/users/crossover/Application Data/Tencent/QQ/webkit_cache"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQDownload"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQMiniDL"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQPhoneAssistant"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQPhoneManager"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQWifi"
    remove_file "$BottleBase/users/crossover/Application Data/Tencent/Tencentdl/dlcore.tlg"
    remove_file "$BottleBase/users/crossover/Application Data/Tencent/Tencentdl/TencentDL.tlg"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/TXSSO"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/Users"
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/WebGamePlugin"
    purge_dir   "$BottleBase/users/crossover/Local Settings/Application Data/Tencent/QQPet"
    purge_dir   "$BottleBase/users/Public/Application Data/Tencent/QQPCMgr"
    purge_dir   "$BottleBase/users/Public/Application Data/Tencent/QQProtect"
    purge_dir   "$BottleBase/Program Files/Common Files/Tencent"
    remove_file "$BottleBase/Program Files/Tencent/QQ/Plugin/Com.Tencent.QQPet/bin/QQPet"
}

cleanup_qqdownload()
{
    if [ ! -e "$BottleBase/Program Files/Tencent/QQDownload/QQDownload.exe" ];then return;fi

    echo "++++QQDownload detected. cleaning..."
    purge_dir   "$BottleBase/users/crossover/Application Data/Tencent/QQDownload"
}

cleanup_foobar2000()
{
    if [ ! -e "$BottleBase/Program Files/foobar2000/foobar2000.exe" ];then return;fi

    echo "++++foobar2000 detected. cleaning..."
    purge_dir   "$BottleBase/Program Files/foobar2000/configuration"
    purge_dir   "$BottleBase/Program Files/foobar2000/library"
    purge_dir   "$BottleBase/Program Files/foobar2000/playlists-v1.3"
    remove_file "$BottleBase/Program Files/foobar2000/theme.fth"
}

cleanup_aliwangwang()
{
    if [ ! -e "$BottleBase/Program Files/AliWangWang/AliIM.exe" ];then return;fi

    echo "++++AliWangWang detected. cleaning..."
    purge_dir   "$BottleBase/Program Files/AliWangWang/profiles"
    purge_dir   "$BottleBase/Program Files/AliWangWang/new"
}


cleanup_flash()
{
    echo "++++flash detected. cleaning..."
    remove_file "$BottleBase/users/crossover/Application Data/Adobe"
    remove_file "$BottleBase/users/crossover/Application Data/Macromedia"
    remove_file "$BottleBase/windows/system32/FlashPlayerApp.exe"
    remove_file "$BottleBase/windows/ControlPanelDB/FlashPlayerCPLApp.ico"
    remove_file "$BottleBase/windows/system32/FlashPlayerCPLApp.cpl"
    remove_file "$BottleBase/windows/system32/Macromed/Flash/FlashInstall.log"
    remove_file "$BottleBase/windows/system32/Macromed/Flash/Flash*.dll"
    remove_file "$BottleBase/windows/system32/Macromed/Flash/Flash*.exe"
    remove_file "$BottleBase/windows/system32/Macromed/Flash/mms.cfg"
}

cleanup_mailmaster()
{
    if [ ! -e "$BottleBase/MailMaster/MailMaster.exe" ];then return;fi

    echo "++++MailMaster detected. cleaning..."
    remove_file "$BottleBase/MailMaster/account"
    remove_file "$BottleBase/MailMaster/address"
    remove_file "$BottleBase/MailMaster/tmp"
    remove_file "$BottleBase/MailMaster/UpdateTemp"
    remove_file "$BottleBase/MailMaster/applog.txt"
    remove_file "$BottleBase/MailMaster/netlog.txt"
    remove_file "$BottleBase/MailMaster/global.cfg"
    remove_file "$BottleBase/MailMaster/schd.sdb"
}


software_cleaner()
{
    cleanup_qq
    cleanup_qqdownload
    cleanup_foobar2000
    cleanup_aliwangwang
    cleanup_mailmaster
    #cleanup_flash
}

optimize()
{
    sed -i 's#\(C:\\\\windows\\\\system32\\\\winebrowser\(\.exe\)\?\) #\\\"\1\\\" #' "$BottleBase/../system.reg"
}

#=============================================

if [ -z "$1" ]; then
    echo "prefix should be given"
    exit 1
fi

BottleName=$1
BottleBase=${HOME}/.cxoffice/$BottleName/drive_c

if [ ! -d "${HOME}/.cxoffice/$BottleName" ]; then
    echo "prefix do not exists"
    exit 2
fi

if [ ! -e "${HOME}/.cxoffice/$BottleName/cxbottle.conf" ]; then
    echo "invalid prefix"
    exit 3
fi

clean_gecko
clean_temp
software_cleaner
#optimize
shutdown_bottle

exit 0
