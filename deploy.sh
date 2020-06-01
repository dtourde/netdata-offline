#!/bin/bash

set -euo pipefail

# A POSIX variable
OPTIND=1
NETDATA_VERSION="v1.19.0"
NETDATA_FILE="$(pwd)/netdata-${NETDATA_VERSION}.gz.run"
NETDATA_CHECKSUM="$(pwd)/sha256sums.txt"
NETDATA_INSTALL_SCRIPT="$(pwd)/kickstart-static64.sh"
NETDATA_ENVIRONMENT="$(pwd)/.environment"
NETDATA_UNINSTALLER="$(pwd)/netdata-uninstaller.sh"
NETDATA_ETC_FOLDER="/opt/netdata/etc/netdata"
NETDATA_NOTIFY_FILE="${NETDATA_ETC_FOLDER}/health_alarm_notify.conf"
FILES=(${NETDATA_FILE} ${NETDATA_CHECKSUM} ${NETDATA_INSTALL_SCRIPT} ${NETDATA_ENVIRONMENT} ${NETDATA_UNINSTALLER})

show_help(){
	echo "-i install"
	echo "-u uninstall"
}

check_files() {
	ret=0
	for file in ${FILES}; do
		if [[ ! -f ${file} ]]; then
			echo "File ${file} not found"
			${ret}=${ret}++
		fi
	done
	
	if [[ ${ret} -gt 0 ]]; then
		echo "Error: ${ret} files were missing, abort."
		exit 1
	fi

	return 0
}

email_notif() {
	if [[ ${1} != "YES" && ${1} != "NO" ]]; then
		echo "email_notify parameter : ${1}; expected YES or NO"
		exit 2
	fi
	echo "SEND_EMAIL=${1}" > ${NETDATA_NOTIFY_FILE}
}

remove_etc_folder() {
	rm -rf ${NETDATA_ETC_FOLDER}
}
	
install_netdata() {
	# Assume files are checked
	bash ${NETDATA_INSTALL_SCRIPT} --local-files ${NETDATA_FILE} ${NETDATA_CHECKSUM}
	email_notif "NO"
	service netdata restart #redirect to systemctl when systemd is the service manager
}

uninstall_netdata() {
	# Assume files are checked
	${NETDATA_UNINSTALLER} --yes --force --env ${NETDATA_ENVIRONMENT}
	remove_etc_folder
}

check_files

while getopts "h?iu" opt; do
	case "${opt}" in
	h|\?)
		show_help
		exit 0
		;;
	v)
		set -x
		;;
	i)
		install_netdata
		exit 0
		;;
	u)
		uninstall_netdata
		exit 0
		;;
	esac
done