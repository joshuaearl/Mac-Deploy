#!/bin/bash
basedir="\\\\networkshare\installers"

# Install Dialog if not present (for menu)
required_pkg="dialog"
pkg_ok=$(dpkg-query -W --showformat='${Status}\n' $required_pkg|grep "install ok installed")

echo Checking for $required_pkg: $pkg_ok
if [ "" = "$pkg_ok" ]; then
	echo "No $required_pkg. Setting up $required_pkg."
	sudo apt-get --yes install $required_pkg
fi

echo "Reading settings file..."

oifs=$IFS # Setting variable for Old Internal Field Seperator (space)
IFS=',' # New Internal Field Seperator (semi-colon)

filename='packages.csv'
i=0
while read line
do
	j=0
	for x in $line
	do
		case $j in
			0)
				name[$i]=$x
				;;
			1)
				folder[$i]=$x
				;;
			2)
				file[$i]=$x
				;; 
			*)
				echo "Settings file error, extra column?"
				exit
				;;
		esac
		j=$((j+1))
	done

	echo "App ID $i: ${name[$i]}"
	i=$((i+1))
done < <(tail -n +2 "$filename")

IFS=$oifs
echo "Found $i packages!"

# Create a multi-select menu with Dialog
cmd=(dialog --title "Mac Deployment" --separate-output --ok-label "Install" --checklist "Select applications to install:" 22 76 16)

for i in "${name[@]}"
do
	options+=($((++count)) "$i" off)
done

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

# Has the user selected atleast one application?
if [ "${choices[@]}" == "" ]; then
	echo "No apps selected. Exiting."
	[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

# List user selected apps and verify
for choice in $choices
do
	appid=$((choice-1))
	appname=${name[$appid]}
	echo "$appname"
done
printf "\n"
read -p "Is this correct? (y/n) " -n 1 -r
printf "\n\n"
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "Installing..."
    for choice in $choices
	do
		appid=$((choice-1))
		appname=${name[$appid]}
		path="$basedir\\${folder[$appid]}\\${file[$appid]}"
		echo "$appname: $path"
		extension=${path:(-3)}
		if [ $extension = "pkg" ]; then
			echo "PKG File Installation"
			sudo installer -pkg "$path" -target /Applications
		fi
		if [ $extension = "dmg" ]; then
			echo "DMG File Installation"
			VOLUME=`hdiutil attach $path | grep Volumes | awk '{print $3}'`
			cp -rf $VOLUME/*.app /Applications
			hdiutil detach $VOLUME
		fi
	done
else
	echo "It was incorrect. Exiting."
	[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi