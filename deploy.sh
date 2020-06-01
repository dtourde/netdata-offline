#!/usr/bin/env bash

set -euo pipefail

# A POSIX variable
OPTIND=1
NETDATA_VERSION="v1.19.0"
NETDATA_FILE"=./netdata-${NETDATA_VERSION}.gz.run"
NETDATA_CHECKSUM="./sha256sums.txt"
NETDATA_INSTALL_SCRIPT="./kickstart-static64.sh"
NETDATA_ENVIRONMENT="./.environment"
NETDATA_UNINSTALLER="./netdata-uninstaller.sh"
NETDATA_ETC_FOLDER="/etc/netdata"
FILES=(${NETDATA_FILE} ${NETDATA_CHECKSUM} ${NETDATA_INSTALL_SCRIPT} ${NETDATA_ENVIRONMENT} ${NETDATA_UNINSTALLER})

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

	return 0
}

email_notif() {
	if [[ ${1} != "YES" && ${1} != "NO" ]]; then
		echo "email_notify parameter : ${1}; expected YES or NO"
		exit 2
	echo "SEND_EMAIL="${notify} > /etc/netdata/conf.d/health_alarm_notify.conf
}

remove_etc_folder() {
	rm -rf ${NETDATA_ETC_FOLDER}
}
	
install_netdata() {
	# Assume files are checked
	bash ${NETDATA_INSTALL_SCRIPT} --local-files ${NETDATA_FILE} ${NETDATA_CHECKSUM}
	email_notif "NO"
}

uninstall_netdata() {
	# Assume files are checked
		${NETDATA_PREFIX}/usr/libexec/netdata/netdata-uninstaller.sh --yes --env <environment_file>


