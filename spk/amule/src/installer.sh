#!/bin/sh

# Package
PACKAGE="amule"
DNAME="aMule"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
SSS="/var/packages/${PACKAGE}/scripts/start-stop-status"
PATH="${INSTALL_DIR}/bin:${PATH}"
USER="amule"
GROUP="users"
CFG_FILE="${INSTALL_DIR}/var/settings.json"
TMP_DIR="${SYNOPKG_PKGDEST}/../../@tmp"

SERVICETOOL="/usr/syno/bin/servicetool"
SYNOSHARE="/usr/syno/sbin/synoshare"
SYNOACLTOOL="/usr/syno/bin/synoacltool"

FWPORTS="/var/packages/${PACKAGE}/scripts/${PACKAGE}.sc"


preinst ()
{
    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then
	    case $SYNOPKG_DSM_LANGUAGE in
	    	ita)
	    		ERROR_MSG1="I numeri di porta devono essere diversi."
	    		ERROR_MSG2="La directory di download e quella dei file incompleti devono risidere sullo stesso volume."
	    		;;
	    	*)
	    		ERROR_MSG1="Port values must be different."
	    		ERROR_MSG2="Download dir and Temp dir needs to be on the same volume."
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
        su - ${USER} -c "PATH=${PATH} ${INSTALL_DIR}/bin/amule-daemon -c ${INSTALL_DIR}/var/  > ${INSTALL_DIR}/var/firstrun.log"

        # Activate aMule External Connections to allow daemon start
        sed -i -e "s/^AcceptExternalConnections=.*$/AcceptExternalConnections=1/" ${INSTALL_DIR}/var/amule.conf
        ECPASSWORD=$(echo -n "${wizard_ecpassword:=admin}" | openssl md5 2>/dev/null | awk '{print $2}')
        sed -i -e "s/^ECPassword=.*$/ECPassword=${ECPASSWORD}/" ${INSTALL_DIR}/var/amule.conf
    
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

#    # Add firewall config
#    ${SERVICETOOL} --install-configure-file --package ${FWPORTS} >> /dev/null

    exit 0
}

preuninst ()
{
    # Stop the package
    ${SSS} stop > /dev/null

    # Remove the user (if not upgrading)
    if [ "${SYNOPKG_PKG_STATUS}" != "UPGRADE" ]; then
        delgroup ${USER} ${GROUP}
        deluser ${USER}
    fi

#    # Remove firewall config
#    if [ "${SYNOPKG_PKG_STATUS}" == "UNINSTALL" ]; then
#        ${SERVICETOOL} --remove-configure-file --package ${PACKAGE}.sc >> /dev/null
#    fi

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
#    # Stop the package
#    ${SSS} stop > /dev/null

#    # Save some stuff
#    rm -fr ${TMP_DIR}/${PACKAGE}
#    mkdir -p ${TMP_DIR}/${PACKAGE}
#    mv ${INSTALL_DIR}/var ${TMP_DIR}/${PACKAGE}/

    exit 0
}

postupgrade ()
{
#    # Restore some stuff
#    rm -fr ${INSTALL_DIR}/var
#    mv ${TMP_DIR}/${PACKAGE}/var ${INSTALL_DIR}/
#    rm -fr ${TMP_DIR}/${PACKAGE}

    exit 0
}
