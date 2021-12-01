#!/bin/sh
set -e

command_available() {
  type "$1" >/dev/null 2>&1
}

package_manager(){
    os_release=$(ls /etc/*release /etc/*version | xargs -n 1 basename | grep -ie 'redhat*\|arch*\|gentoo*\|SuSE*\|debian*')
    
    case $os_release in
        redhat-release) echo yum ;;
        arch-release) echo pacman ;;
        gentoo-release) echo emerge ;;
        SuSE-release) echo zypp ;;
        debian_version) echo apt-get ;;
        *) echo "OS not recognized, please contact CARTO at enterprise-support@carto.com" && exit 1
    esac
}

if ! command_available git
then
    pm=$(package_manager)
    sudo $pm update && sudo $pm -y install git
fi

if ! command_available curl
then
    pm=$(package_manager)
    sudo $pm update && sudo $pm -y install curl
fi

