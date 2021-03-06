#!/bin/bash
# Usage: ./update_browserhax.sh <path to repos base directory> <path to pub_html root> <webpageURL>
# example: ./update_browserhax.sh /home/user/repos /home/user/public_html "http://example.com"

# please install the package qrencode for automated qrcode generation
# apt-get install qrencode

# You will have to adjust for hard-coded absolute file-paths used in the scripts.
# See also the setup described here: https://github.com/yellows8/3ds_browserhax_common

if [ "$#" -ne 3 ]; then
	echo "Usage: ./update_browserhax.sh <path to repos base directory> <path to pub_html root> <webpageURL>"
	echo 'Example: ./update_browserhax.sh /home/user/repos /home/user/public_html "http://example.com"'
	exit 1
fi

repobase=$1
webroot=$2
websitebase=$3



if [[ -n $(find $repobase -mindepth 1 -maxdepth 1 -type d ! -name browserhax_site ! -name 3ds_browserhax_common ! -name browserhax_fright ! -name 3ds_webkithax) ]]; then
	echo "WARNING: It's recommended to create an empty directory specifically for the repos."
	read -p "Continue anyway (y/N)? " choice
	case "$choice" in
		y|Y ) ;;
		* ) exit 1;;
	esac
fi

if [[ $repobase != /* ]]; then
	echo "WARNING: You are not using the full path for the repository base. This will probably break the symlinks and not work."
	if [ -z "$repobase" ]; then echo "Example: $(pwd)/$repobase"; else echo "Example: $(pwd)"; fi
	read -p "Continue anyway (y/N)? " choice
	case "$choice" in
		y|Y ) ;;
		* ) exit 1;;
	esac
fi



function get_repo
{
	echo "Processing $1..."
	cd "$repobase"
	if [[ -d $1 ]]; then
		cd "$1" && git reset --hard && git pull --progress
	else
		git clone "https://github.com/yellows8/$1.git" --progress
	fi
}

function create_symlink
{
	if [ ! -L "$webroot/$2" ]; then
		ln -s "$repobase/$1" "$webroot/$2"
	fi
}

function copy_file
{
	if [ ! -e "$webroot/$2" ]; then
		cp -p "$repobase/$1" "$webroot/$2"
	fi
}

function replace_hardcoded
{
	find $repobase/$1 -type f -exec sed -i "s#$2#$3#g" {} \;
}

hardcodedpath="/home/yellows8/browserhax"

get_repo browserhax_site
get_repo 3ds_browserhax_common
get_repo browserhax_fright
get_repo 3ds_webkithax

replace_hardcoded browserhax_site $hardcodedpath $webroot
replace_hardcoded 3ds_browserhax_common $hardcodedpath $webroot
replace_hardcoded browserhax_fright $hardcodedpath $webroot
replace_hardcoded 3ds_webkithax $hardcodedpath $webroot

create_symlink browserhax_site/3dsbrowserhax.php 3dsbrowserhax.php
create_symlink browserhax_site/3dsbrowserhax.php 3dsbrowserhax_auto.php

create_symlink 3ds_browserhax_common/3dsbrowserhax_common.php 3dsbrowserhax_common.php
copy_file 3ds_browserhax_common/browserhax_cfg_example.php browserhax_cfg.php


create_symlink browserhax_fright/browserhax_fright.php browserhax_fright.php
create_symlink browserhax_fright/browserhax_fright_tx3g.php browserhax_fright_tx3g.php
create_symlink browserhax_fright/skater31hax.php skater31hax.php
create_symlink browserhax_fright/frighthax_header.mp4 frighthax_header.mp4
create_symlink browserhax_fright/frighthax_header_tx3g.mp4 frighthax_header_tx3g.mp4

# Obsolete exploits are not included here.

create_symlink 3ds_webkithax/3dsbrowserhax_webkit_r106972.php spider28hax.php
create_symlink 3ds_webkithax/spider31hax.php spider31hax.php

curl -o $webroot/3dsbrowserhax_auto_qrcode.png -G -s "https://chart.googleapis.com/chart?cht=qr&chs=150x150" --data-urlencode "chl=$websitebase/3dsbrowserhax_auto.php"

