#!/bin/bash
#
# Author: Tasos Latsas
# From https://github.com/tlatsas/bash-spinner/blob/master/spinner.sh

function _spinner() {
	# $1 start/stop
	#
	# on start: $2 display message
	# on stop : $2 process exit status
	#           $3 spinner function pid (supplied from stop_spinner)

	local on_success="DONE"
	local on_fail="FAIL"
	local white="\e[1;37m"
	local green="\e[1;32m"
	local red="\e[1;31m"
	local nc="\e[0m"

	case $1 in
		start)
			# calculate the column where spinner and status msg will be displayed
			let column=$(tput cols)-${#2}-8
			# display message and position the cursor in $column column
			echo -ne ${2}
			printf "%${column}s"

			# start spinner
			i=1
			sp='\|/-'
			delay=${SPINNER_DELAY:-0.15}

			while :
			do
				printf "\b${sp:i++%${#sp}:1}"
				sleep $delay
			done
			;;
		stop)
			if [[ -z ${3} ]]; then
				echo "spinner is not running.."
				exit 1
			fi

			kill $3 > /dev/null 2>&1

			# inform the user uppon success or failure
			echo -en "\b["
			if [[ $2 -eq 0 ]]; then
				echo -en "${green}${on_success}${nc}"
			else
				echo -en "${red}${on_fail}${nc}"
			fi
			echo -e "]"
			;;
		*)
			echo "invalid argument, try {start/stop}"
			exit 1
			;;
	esac
}

function start_spinner {
	# $1 : msg to display
	_spinner "start" "${1}" &
	# set global spinner pid
	_sp_pid=$!
	disown
}

function stop_spinner {
	# $1 : command exit status
	_spinner "stop" $1 $_sp_pid
	unset _sp_pid
}

# Copyright (C) 2017 JBBgameich
# Copyright (C) 2017 TheWiseNerd
#
# License: GPLv3

function init_checks() {
	DEPENDENCIES=(qemu binfmt-support qemu-user-static e2fsprogs sudo simg2img)
	BINARIES=(simg2img qemu-arm-static mkfs.ext4 update-binfmts qemu-img)

	for bin in ${BINARIES[@]}; do
		if ! sudo bash -c "command -v $bin" >/dev/null 2>&1; then
			echo "$bin not found in \$PATH"
			echo
			echo "make sure you have all dependencies installed."
			echo "dependencies: ${DEPENDENCIES[*]}"
			return 1
		fi
	done

	# if qemu-arm-static exists, a sanely installed update-binfmts
	# -should- have qemu-arm. try to enable it in case it isnt.
	if ! sudo update-binfmts --display qemu-arm | grep -q "qemu-arm (enabled)"; then
		sudo update-binfmts --enable qemu-arm
	fi

	return 0
}

function usage() {
	cat <<-EOF
	usage: $0 rootfs.tar[.gz] system.img [release]

	positional arguments:
	    rootfs.tar[.gz]
	    system.img

	optional arguments:
	    release: run common post installation tasks for release.
	             supported: none, halium, pm
	             defaults : none
	EOF
}
