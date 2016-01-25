#!/bin/sh

# Package
PACKAGE="amule"
DNAME="aMule Daemon"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
SSS="/var/packages/${PACKAGE}/scripts/start-stop-status"
PATH="${INSTALL_DIR}/bin:${PATH}"
USER="amule"
GROUP="users"
CFG_FILE="${INSTALL_DIR}/var/amule.conf"
TMP_DIR="${SYNOPKG_PKGDEST}/../../@tmp"
BACKUP_DIR="${SYNOPKG_PKGDEST}/../../@${PACKAGE}"
INSTALL_LOG="${INSTALL_DIR}/var/installer.log"

SERVICETOOL="/usr/syno/bin/servicetool"
SYNOSHARE="/usr/syno/sbin/synoshare"
SYNOACLTOOL="/usr/syno/bin/synoacltool"
FWPORTS="/var/packages/${PACKAGE}/scripts/${PACKAGE}.sc"

IPFILTER_URL=http://upd.emule-security.org/ipfilter.zip


preinst ()
{
    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then
        case $SYNOPKG_DSM_LANGUAGE in
            ita)
                ERROR_MSG1="I numeri di porta devono essere diversi."
                ERROR_MSG2="La directory di download e quella dei file incompleti devono risidere sullo stesso volume."
                ERROR_MSG3="La directory condivisa deve essere la stessa per entrambi i percorsi."
                ;;
            *)
                ERROR_MSG1="Port values must be different."
                ERROR_MSG2="Download directory and Temp directory needs to be on the same volume."
                ERROR_MSG3="Shared directory needs to be the same for both paths."
                ;;
   		esac
    
        if [ "${wizard_tcpport}" == "${wizard_udpport}" ]; then
            echo "${ERROR_MSG1}"
            exit 1
        fi

		VOLUME=`echo ${wizard_download_dir} | cut -d"/" -f2`
		VOLUME_TMP=`echo ${wizard_incomplete_dir} | cut -d"/" -f2`
		if [  "${VOLUME}" != "${VOLUME_TMP}" ]; then
    		echo "${ERROR_MSG2}"
			exit 1
		fi
		
        SHARE=`echo ${wizard_download_dir} | cut -d"/" -f3`
        SHARE_TMP=`echo ${wizard_incomplete_dir} | cut -d"/" -f3`
        if [  "${SHARE}" != "${SHARE_TMP}" ]; then
            echo "${ERROR_MSG3}"
            exit 1
        fi

		# Da spostare in postinst()
		#VOLUME=`echo ${wizard_download_dir} | cut -d"/" -f3`
#		SHARE_NAME=`echo ${wizard_download_dir} | cut -d"/" -f3`
#		${SYNOSHARE} --get ${SHARE_NAME} > /dev/null
#		if [ $? != 0 ]; then
#			#${SYNOSHARE} --add ${SHARE_NAME} "" /${VOLUME}/${SHARE_NAME} "" "admin,guest" "" 1 0
#			#${SYNOACLTOOL} -add /${VOLUME}/${SHARE_NAME} user:${USER}:allow:rwxpdDaARWc--:fd--
#			echo "${SHARE_NAME} NON ESISTE!!"
#			exit 1
#		else					
#			echo "${SHARE_NAME} ESISTE!!"
#			exit 1
#		fi



		
		
		
#        if [ ! -d "${wizard_download_dir}" ]; then
#            echo "Download directory ${wizard_download_dir} does not exist."
#            exit 1
#        fi
#        if [ -n "${wizard_watch_dir}" -a ! -d "${wizard_watch_dir}" ]; then
#            echo "Watch directory ${wizard_watch_dir} does not exist."
#            exit 1
#        fi
#        if [ -n "${wizard_incomplete_dir}" -a ! -d "${wizard_incomplete_dir}" ]; then
#            echo "Incomplete directory ${wizard_incomplete_dir} does not exist."
#            exit 1
#        fi
    fi

    exit 0
}

change_config_all_param_value ()
{
    sed -i -e "s/^${1}=.*$/${1}=${2}/" ${CFG_FILE}
}

# Add escape backslash char before every slash char
# args: input string
escape_slash ()
{
    echo ${1} | sed 's/\//\\\//g'
}

change_config_param_value ()
{
    echo "change_config_param_value start"
#    echo "\${1}="${1}
#    echo "\${2}="${2}
#    echo "\${3}="${3}
#    echo "\${4}="${4}
    KEY=${1}
    VALUE=$(escape_slash ${2})
    INI_SECTION=${3}
    FILE_NAME=${CFG_FILE}
    if [ ! -z "${4}" ]; then
        FILE_NAME=${4}
    fi
    R_START=$(grep -n "^\[${INI_SECTION}\].*$" ${FILE_NAME} | cut -d':' -f1)
    R_END=$((R_START+$(sed -n -e "/^\[${INI_SECTION}\]/,/^\s*\[/{/^[^;].*\=.*/p;}" ${FILE_NAME} | wc -l)))
    echo "KEY="$KEY
    echo "VALUE="$VALUE
    echo "INI_SECTION"=$INI_SECTION
    echo "FILE_NAME="$FILE_NAME
    sed -i -e "${R_START},${R_END} s/^${KEY}=.*$/${KEY}=${VALUE}/" ${FILE_NAME}
    echo "change_config_param_value end"
}

extract_config_section ()
{
    INI_SECTION=${1}
    FILE_NAME=${CFG_FILE}
    if [ ! -z "${2}" ]; then
        FILE_NAME=${2}
    fi
    sed -n -e "/^\[${INI_SECTION}\]/,/^\s*\[/{/^[^;].*\=.*/p;}" ${FILE_NAME}
}

get_config_param_value ()
{
    KEY=${1}
    INI_SECTION=${2}
    FILE_NAME=${CFG_FILE}
    if [ ! -z "${3}" ]; then
        FILE_NAME=${3}
    fi
    echo $(extract_config_section ${INI_SECTION} ${FILE_NAME} | grep ^${KEY} | sed -e "s/^${KEY}\=//g")
}

create_shared_dir ()
{
    SHARED_PATH=${1}
    VOLUME=`echo ${SHARED_PATH} | cut -d"/" -f2`
    SHARE_NAME=`echo ${SHARED_PATH} | cut -d"/" -f3`
    ${SYNOSHARE} --get ${SHARE_NAME} > /dev/null
    if [ $? != 0 ]; then
	${SYNOSHARE} --add ${SHARE_NAME} "" /${VOLUME}/${SHARE_NAME} "" "admin" "" 1 0
#		echo "${SHARE_NAME} NON ESISTE!!"
#		exit 1
#	else
#		echo "${SHARE_NAME} ESISTE!!"
#		exit 1
    fi
    ${SYNOACLTOOL} -add /${VOLUME}/${SHARE_NAME} user:${USER}:allow:rwxpdDaARWc--:fd--

    # Save share path for future use
    echo "/${VOLUME}/${SHARE_NAME}" > ${INSTALL_DIR}/var/uninstall.txt
}

# display part of path
# args: string holding path
#       number of parts to display
subpath()
{
    echo "$1" | cut -d"/" -f1-$2
}

# display last char of a string
# args: input string
getlastchar()
{
	input=$1
	len=${#input};
	echo $input | awk -v var=$len '{ string=substr($0, var, 1); print string; }'
}

# create all subdir of a path starting from a subdir of choice
# args: input path
#       order number of starting dir
create_subdir()
{
    MY_PATH=${1}
    START=${2}
    START=$((START+1))
    echo "lastchar = "$(getlastchar $MY_PATH)
    END=$(echo $MY_PATH | grep -o "/" | wc -l)
    if [  "$(getlastchar $MY_PATH)" != "/" ]; then
	    END=$((END+1))
    fi
    echo "end_dir_number = "$END
    for i in $(seq ${START} ${END}); do
	    DIR=$(subpath $MY_PATH $i);
	    if [ ! -d "$DIR" ]; then
		    mkdir $DIR;
		    echo $DIR;
	    fi
    done
}

postinst_configure_amule_conf()
{
    # Activate aMule External Connections to allow daemon start
    #sed -i -e "s/^AcceptExternalConnections=.*$/AcceptExternalConnections=1/" ${INSTALL_DIR}/var/amule.conf
    change_config_param_value AcceptExternalConnections 1 ExternalConnect >> ${INSTALL_LOG}
    ECPASSWORD=$(echo -n "${wizard_ecpassword:=admin}" | openssl md5 2>/dev/null | awk '{print $2}')
    change_config_param_value ECPassword ${ECPASSWORD} ExternalConnect >> ${INSTALL_LOG}
    #sed -i -e "s/^ECPassword=.*$/ECPassword=${ECPASSWORD}/" ${INSTALL_DIR}/var/amule.conf
    #-------------- Configure WebServer ------------------
    WEBPASSWORD=$(echo -n "${wizard_webpassword:=admin}" | openssl md5 2>/dev/null | awk '{print $2}')
    change_config_param_value Enabled 1 WebServer >> ${INSTALL_LOG}
    change_config_param_value Password ${WEBPASSWORD} WebServer >> ${INSTALL_LOG}
    #--------------- User Preferences --------------------
    change_config_param_value Port ${wizard_tcpport} eMule >> ${INSTALL_LOG}
    change_config_param_value UDPPort ${wizard_udpport} eMule >> ${INSTALL_LOG}
    change_config_param_value IncomingDir "${wizard_download_dir}" eMule >> ${INSTALL_LOG}
    change_config_param_value TempDir "${wizard_incomplete_dir}" eMule >> ${INSTALL_LOG}
    #------------- Recommended Settings ------------------
    change_config_param_value MaxUpload ${upspeed} eMule >> ${INSTALL_LOG}
    change_config_param_value SlotAllocation 5 eMule >> ${INSTALL_LOG}
    change_config_param_value MaxSourcesPerFile 450 eMule >> ${INSTALL_LOG}
    change_config_param_value MaxConnections 350 eMule >> ${INSTALL_LOG}
    change_config_param_value SafeServerConnect 1 eMule >> ${INSTALL_LOG}
    #change_config_param_value AddNewFilesPaused 1 eMule >> ${INSTALL_LOG}
    change_config_param_value StartNextFile 1 eMule >> ${INSTALL_LOG}
    change_config_param_value StartNextFileSameCat 1 eMule >> ${INSTALL_LOG}
    change_config_param_value StartNextFileAlpha 1 eMule >> ${INSTALL_LOG}
    change_config_param_value IPFilterAutoLoad 0 eMule >> ${INSTALL_LOG}
    change_config_param_value IPFilterURL ${IPFILTER_URL} eMule >> ${INSTALL_LOG}
    change_config_param_value ShareHiddenFiles 1 eMule >> ${INSTALL_LOG}
    change_config_param_value SmartIdState 1 eMule >> ${INSTALL_LOG}
    change_config_param_value UseSrcSeeds 1 ExternalConnect >> ${INSTALL_LOG}
    change_config_param_value CoreCommand "${INSTALL_DIR}/var/doneDL.sh \"%NAME\" \"%FILE\" %HASH %SIZE \"%DLACTIVETIME\"" UserEvents\\/DownloadCompleted >> ${INSTALL_LOG}
}

postinst ()
{
    # Link
    ln -s ${SYNOPKG_PKGDEST} ${INSTALL_DIR}

    # Install busybox stuff
    ${INSTALL_DIR}/bin/busybox --install ${INSTALL_DIR}/bin

    # Create user
    adduser -h ${INSTALL_DIR}/var -g "${DNAME} User" -G ${GROUP} -s /bin/sh -S -D ${USER}

    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then

        # aMule Daemon first run needed to initialize standard config files
        su - ${USER} -c "PATH=${PATH} ${INSTALL_DIR}/bin/amule-daemon -c ${INSTALL_DIR}/var/ > ${INSTALL_LOG}"

        # Restore configuration if required
        if [ -d "${BACKUP_DIR}/var" -a -f "${BACKUP_DIR}/var/amule.conf" ]; then
            if [ "${wizard_restore_config_yes}" == "true" ]; then
                cp -fr ${BACKUP_DIR}/var ${INSTALL_DIR} >> ${INSTALL_LOG}
                # IMPORTANT: uninstall.txt contains only /VOLUME_DIR/SHARE_DIR, not the complete wizard_download_dir and incomplete_dir
                # We need to obtain this values from amule.conf previously copied in backup directory
                wizard_download_dir=$(get_config_param_value IncomingDir eMule ${BACKUP_DIR}/var/amule.conf)
                wizard_incomplete_dir=$(get_config_param_value TempDir eMule ${BACKUP_DIR}/var/amule.conf)
                wizard_tcpport=$(get_config_param_value Port eMule ${BACKUP_DIR}/var/amule.conf)
                wizard_udpport=$(get_config_param_value UDPPort eMule ${BACKUP_DIR}/var/amule.conf)
            elif [ "${wizard_restore_config_credits}" == "true" ]; then
                cp -f ${BACKUP_DIR}/var/cryptkey.dat ${INSTALL_DIR}/var >> ${INSTALL_LOG}
                cp -f ${BACKUP_DIR}/var/clients.met ${INSTALL_DIR}/var >> ${INSTALL_LOG}
                cp -f ${BACKUP_DIR}/var/preferences.dat ${INSTALL_DIR}/var >> ${INSTALL_LOG}
                if [ -f "${BACKUP_DIR}/var/nodes.dat" ]; then
                    cp -f ${BACKUP_DIR}/var/nodes.dat ${INSTALL_DIR}/var >> ${INSTALL_LOG}
                fi
            fi
        fi

        if [ "${wizard_restore_config_yes}" == "false" ]; then
            python ${INSTALL_DIR}/var/speedtest_mod.py --cspath ${INSTALL_DIR}/var/ > ${INSTALL_DIR}/var/speedtest_mod.log
            if [ $? == 0 ]; then
                upspeed=$(cat ${INSTALL_DIR}/var/calculatedUploadSpeed.out)
            else
                upspeed=50
            fi
            postinst_configure_amule_conf
        fi

        # Configure ipfilter.dat
        unzip ${INSTALL_DIR}/var/ipfilter.zip -d ${INSTALL_DIR}/var/ >> ${INSTALL_LOG}
        mv ${INSTALL_DIR}/var/guarding.p2p ${INSTALL_DIR}/var/ipfilter.dat >> ${INSTALL_LOG}
        rm ${INSTALL_DIR}/var/ipfilter.zip >> ${INSTALL_LOG}

        # Create shared download dir if it doesn't exists
        create_shared_dir ${wizard_download_dir} >> ${INSTALL_LOG}
        create_subdir ${wizard_download_dir} 3 >> ${INSTALL_LOG}

    fi

    # Correct the files ownership
    chown -R ${USER}:root ${SYNOPKG_PKGDEST}

#    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then
#        # Edit the configuration according to the wizard
#        sed -i -e "s|@download_dir@|${wizard_download_dir:=/volume1/downloads}|g" ${CFG_FILE}
#        sed -i -e "s|@username@|${wizard_username:=admin}|g" ${CFG_FILE}
#        sed -i -e "s|@password@|${wizard_password:=admin}|g" ${CFG_FILE}
#        if [ -d "${wizard_watch_dir}" ]; then
#            sed -i -e "s|@watch_dir_enabled@|true|g" ${CFG_FILE}
#            sed -i -e "s|@watch_dir@|${wizard_watch_dir}|g" ${CFG_FILE}
#        else
#            sed -i -e "s|@watch_dir_enabled@|false|g" ${CFG_FILE}
#            sed -i -e "/@watch_dir@/d" ${CFG_FILE}
#        fi
#        if [ -d "${wizard_incomplete_dir}" ]; then
#            sed -i -e "s|@incomplete_dir_enabled@|true|g" ${CFG_FILE}
#            sed -i -e "s|@incomplete_dir@|${wizard_incomplete_dir}|g" ${CFG_FILE}
#        else
#            sed -i -e "s|@incomplete_dir_enabled@|false|g" ${CFG_FILE}
#            sed -i -e "/@incomplete_dir@/d" ${CFG_FILE}
#        fi

#        # Set group and permissions on download- and watch dir for DSM5
#        if [ `/bin/get_key_value /etc.defaults/VERSION buildnumber` -ge "4418" ]; then
#            chgrp users ${wizard_download_dir:=/volume1/downloads}
#            chmod g+rw ${wizard_download_dir:=/volume1/downloads}
#            if [ -d "${wizard_watch_dir}" ]; then
#                chgrp users ${wizard_watch_dir}
#                chmod g+rw ${wizard_watch_dir}
#            fi
#            if [ -d "${wizard_incomplete_dir}" ]; then
#                chgrp users ${wizard_incomplete_dir}
#                chmod g+rw ${wizard_incomplete_dir}
#            fi
#        fi
#    fi

#    # Correct the files ownership
#    chown -R ${USER}:root ${SYNOPKG_PKGDEST}

    # Customize firewall config
    if [ "${SYNOPKG_PKG_STATUS}" != "INSTALL" ]; then
        wizard_tcpport=$(get_config_param_value Port eMule ${BACKUP_DIR}/var/amule.conf)
        wizard_udpport=$(get_config_param_value UDPPort eMule ${BACKUP_DIR}/var/amule.conf)
    fi
    change_config_param_value dst.ports \"${wizard_tcpport}\/tcp\" amule_tcp ${FWPORTS} >> /dev/null
    change_config_param_value dst.ports \"${wizard_udpport}\/udp\" amule_udp ${FWPORTS} >> /dev/null

    # Add firewall config
    ${SERVICETOOL} --install-configure-file --package ${FWPORTS} >> /dev/null

    exit 0
}

preuninst ()
{
    # Stop the package
    ${SSS} stop > /dev/null
    
    if [ "${SYNOPKG_PKG_STATUS}" == "UNINSTALL" ]; then
        # Remove firewall config
        ${SERVICETOOL} --remove-configure-file --package ${PACKAGE}.sc >> /dev/null
        # Remove share permissions (for security reasons)
        wizard_download_dir=$(cat ${INSTALL_DIR}/var/uninstall.txt)
        ${SYNOACLTOOL} -get ${wizard_download_dir} | grep -q "\:${USER}\:" > /dev/null
		if [ $? == 0 ]; then
		    idx=$(${SYNOACLTOOL} -get ${wizard_download_dir} | grep "\:${USER}\:" | cut -d "[" -f2 | cut -d "]" -f1)
            ${SYNOACLTOOL} -del ${wizard_download_dir} ${idx}
        fi
    fi

    # Save configuration files if required
    if [ "${wizard_backup_config_yes}" ==  "true" ]; then
        rm -fr ${BACKUP_DIR}
        mkdir -p ${BACKUP_DIR}
        mv ${INSTALL_DIR}/var ${BACKUP_DIR}
        mv ${BACKUP_DIR}/var/installer.log ${BACKUP_DIR}/var/installer.log.bak
#    else
#        rm -fr ${BACKUP_DIR}
    fi

    # Remove the user (if not upgrading)
    if [ "${SYNOPKG_PKG_STATUS}" != "UPGRADE" ]; then
        delgroup ${USER} ${GROUP}
        deluser ${USER}
    fi
    
    exit 0
}

postuninst ()
{
    # Remove link
    rm -f ${INSTALL_DIR}

    exit 0
}

preupgrade ()
{
    # Stop the package
    ${SSS} stop > /dev/null

    # Save some stuff
    rm -fr ${TMP_DIR}/${PACKAGE}
    mkdir -p ${TMP_DIR}/${PACKAGE}
    mv ${INSTALL_DIR}/var ${TMP_DIR}/${PACKAGE}/

    exit 0
}

postupgrade ()
{
    # Restore some stuff
    # DA FARE: Se non cambia la logica dello script va messa in questo punto la gestione dell'ipfilter.dat per impedire che venga ricoperto in fase di upgrade
    rm -fr ${INSTALL_DIR}/var
    mv ${TMP_DIR}/${PACKAGE}/var ${INSTALL_DIR}/
    rm -fr ${TMP_DIR}/${PACKAGE}

    exit 0
}
