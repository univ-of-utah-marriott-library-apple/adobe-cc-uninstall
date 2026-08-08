#!/usr/bin/env bash
#
# Adobe 2026 - Application Uninstaller
#
# Revised - 2026.08.06
# Adobe Page Revision: 2026.04.15
# Script Revision: 1.1.2
#
# This script will remove all Adobe CC applications or a specific Adobe CC application.
# It can remove all versions including current or only previous versions of the applications. 
# 
# Reference:
#
# Adobe Creative Cloud application base versions
# https://helpx.adobe.com/business/enterprise/kb/adobe-cc-app-base-versions.html
#
#
# The above documentation page is not always accurate. A more reliable
# validation method is to inspect the current pre-generated installer
# package for the target Adobe CC application.
#
# 1. Expand the flat installer package:
#
#      rm -rf /tmp/adobe_pkg_verify
#      pkgutil --expand-full "/path/to/Adobe_Installer.pkg" /tmp/adobe_pkg_verify
#
# 2. Inspect the expanded optionXML.xml file. For current Adobe
#    pre-generated packages, this file is typically located at:
#
#      /tmp/adobe_pkg_verify/Install.pkg/Scripts/optionXML.xml
#
# 3. Search optionXML.xml for the relevant SAPCode, then read baseVersion
#    from the same HDMedia entry. For example, Adobe Bridge 2026:
#
#      <SAPCode>KBRG</SAPCode>
#      <prodVersion>16.0.6</prodVersion>
#      <mediaLEID>V7{}Bridge-16-Mac-GM</mediaLEID>
#      <baseVersion>16.0.0</baseVersion>
#      <productVersion>16.0.6.9</productVersion>
#
#    In this example, the uninstall base version for Bridge 2026 is
#    16.0.0, not the full product version 16.0.6.
#
# The package preinstall script launches AdobeDeploymentManager with:
#
#      --optXMLPath="$WD/optionXML.xml"
#
# This indicates optionXML.xml is the manifest/playlist that Adobe's
# installation tooling reads to determine what to install and which
# revision, making it a more authoritative source than the published
# documentation.
#
# (Note: corrections to the Adobe CC application base versions article
# have been submitted before, so the article is known to sometimes need
# fixing.)
#
# Copyright (c) 2026 University of Utah, Marriott Library IT. 
# All Rights Reserved.
#
# Permission to use, copy, modify, and distribute this software and
# its documentation for any purpose and without fee is hereby granted,
# provided that the above copyright notice appears in all copies and
# that both that copyright notice and this permission notice appear
# in supporting documentation, and that the name of The University
# of Utah not be used in advertising or publicity pertaining to
# distribution of the software without specific, written prior
# permission. This software is supplied as is without expressed or
# implied warranties of any kind.

# Remove Old Adobe CC Applications Parameters

REMOVE_ADOBE_CC_APP_NAME_SCOPE="${4}"                 # "ALL" or a specific application name
                                                      # (i.e. "AFTER_EFFECTS", "ANIMATE", "AUDITION", "BRIDGE", "CHARACTER_ANIMATOR", "DIMENSION", "DREAMWEAVER","ILLUSTRATOR", "INCOPY", "INDESIGN", "LIGHTROOM")
REMOVE_ADOBE_CC_APP_VERS_SCOPE="${5}"                 # "ALL" which includes current version and previous or "PREVIOUS"

ADOBE_CC_SETUP_PATH="/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup" # Path to Adobe CC Setup executable

ADOBE_CC_PARENT_DIR_PATH="/Applications/Graphical/Adobe CC" # Path to custom local Adobe CC parent directory

ADOBE_CC_SCRIPT_REVISION="1.1.2" # Script revision for logging

function ADOBE_CC_FIND_APP_PATH
{
    local ADOBE_CC_TARGET_APP_NAME="$1"
    local ADOBE_CC_APP_SEARCH_PATH
    local ADOBE_CC_APP_SEARCH_ROOT

    for ADOBE_CC_APP_SEARCH_PATH in \
        "${ADOBE_CC_PARENT_DIR_PATH}/${ADOBE_CC_TARGET_APP_NAME}.app" \
        "${ADOBE_CC_PARENT_DIR_PATH}/Adobe ${ADOBE_CC_TARGET_APP_NAME}.app" \
        "/Applications/${ADOBE_CC_TARGET_APP_NAME}.app"; do
        if [[ -d "${ADOBE_CC_APP_SEARCH_PATH}" ]]; then
            echo "${ADOBE_CC_APP_SEARCH_PATH}"
            return 0
        fi
    done

    for ADOBE_CC_APP_SEARCH_ROOT in "${ADOBE_CC_PARENT_DIR_PATH}" "/Applications"; do
        if [[ -d "${ADOBE_CC_APP_SEARCH_ROOT}" ]]; then
            ADOBE_CC_APP_SEARCH_PATH="$(find "${ADOBE_CC_APP_SEARCH_ROOT}" -maxdepth 2 -type d -name "Adobe ${ADOBE_CC_TARGET_APP_NAME}*.app" 2>/dev/null | head -n 1)"
            if [[ -n "${ADOBE_CC_APP_SEARCH_PATH}" ]]; then
                echo "${ADOBE_CC_APP_SEARCH_PATH}"
                return 0
            fi
        fi
    done

    return 1
}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_AFTER_EFFECTS

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""
     
    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="After Effects"
    ADOBE_CC_SAP_CODE="AEFT"
    ADOBE_CC_CURRENT_BASE_VERSION="26.0"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("25.0" "24.0" "23.0" "22.0" "18.0" "17.0" "16.0" "15.0.0" "14.0.0" "13.8.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_ANIMATE

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Animate"
    ADOBE_CC_SAP_CODE="FLPR"
    ADOBE_CC_CURRENT_BASE_VERSION="24.0.13"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("23.0" "22.0" "21.0" "20.0" "19.0" "18.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_AUDITION

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Audition"
    ADOBE_CC_SAP_CODE="AUDT"
    ADOBE_CC_CURRENT_BASE_VERSION="26.0"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("25.0" "24.0" "23.0" "22.0" "14.0" "13.0" "12.0" "11.0.0" "10.0.0" "9.2.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_BRIDGE

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Bridge"
    ADOBE_CC_SAP_CODE="KBRG"
    ADOBE_CC_CURRENT_BASE_VERSION="16.0.0"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("15.0.0" "14.0.0" "13.0" "12.0.0" "11.0.0" "10.0.0" "9.0.0" "8.0.0" "7.0.0" "6.3")
    ADOBE_CC_PLATFORM="osx10-64"

     if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_CHARACTER_ANIMATOR

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Character Animator"
    ADOBE_CC_SAP_CODE="CHAR"
    ADOBE_CC_CURRENT_BASE_VERSION="26.0"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("25.0" "24.0" "23.0" "22.0" "4.0" "3.0" "2.0" "1.1.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_DIMENSION

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Dimension"
    ADOBE_CC_SAP_CODE="ESHR"
    ADOBE_CC_CURRENT_BASE_VERSION="4.1.8"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("3.0" "2.0" "1.0" "0.1.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_DREAMWEAVER

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Dreamweaver"
    ADOBE_CC_SAP_CODE="DRWV"
    ADOBE_CC_CURRENT_BASE_VERSION="21.7"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("20.0" "19.0" "21.0" "20.2.1" "18.0" "17.0.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_ILLUSTRATOR

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Illustrator"
    ADOBE_CC_SAP_CODE="ILST"
    ADOBE_CC_CURRENT_BASE_VERSION="30.3"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("29.0" "28.0" "27.0" "26.0" "25.0" "24.0" "23.0" "22.0.0" "21.0.0" "20.0.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_INCOPY

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="InCopy"
    ADOBE_CC_SAP_CODE="AICY"
    ADOBE_CC_CURRENT_BASE_VERSION="21.3"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("20.0" "19.0" "18.0" "17.0" "16.0" "15.0" "14.0" "13.0" "12.0.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_INDESIGN

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="InDesign"
    ADOBE_CC_SAP_CODE="IDSN"
    ADOBE_CC_CURRENT_BASE_VERSION="21.3"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("20.0" "19.0" "18.0" "17.0" "16.0" "15.0" "14.0" "13.0" "12.0.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_LIGHTROOM

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Lightroom"
    ADOBE_CC_SAP_CODE="LRCC"
    ADOBE_CC_CURRENT_BASE_VERSION="9.2"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("8.0" "7.0" "1.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_LIGHTROOM_CLASSIC

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Lightroom Classic"
    ADOBE_CC_SAP_CODE="LTRM"
    ADOBE_CC_CURRENT_BASE_VERSION="15.2.1"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("14.0" "13" "8.3" "7.0" "2.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_MEDIA_ENCODER

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Media Encoder"
    ADOBE_CC_SAP_CODE="AME"
    ADOBE_CC_CURRENT_BASE_VERSION="26.0.2"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("25.0" "24.0" "23.0" "22.0" "15.0" "14.0" "13.0" "12.0.0" "11.0.0" "10.3.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_PHOTOSHOP

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Photoshop"
    ADOBE_CC_SAP_CODE="PHSP"
    ADOBE_CC_CURRENT_BASE_VERSION="27.0"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("26.0" "25.0" "24.0" "23.0" "22.0" "21.0" "20.0" "19.0" "18.0" "17.0")
    ADOBE_CC_PLATFORM="osx10-64"
    ADOBE_CC_PLATFORM_CANDIDATES=("osx10-64")
    ADOBE_CC_UNINSTALL_SUCCESS=0
    ADOBE_CC_UNINSTALL_ATTEMPTS=0
    ADOBE_CC_LAST_EXIT_STATUS=0
    ADOBE_CC_INSTALLED_APP_PATH="$(ADOBE_CC_FIND_APP_PATH "${ADOBE_CC_APP_NAME}")"

    if [[ -z "${ADOBE_CC_INSTALLED_APP_PATH}" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC ${ADOBE_CC_APP_NAME} app bundle was not found under \"${ADOBE_CC_PARENT_DIR_PATH}\" or \"/Applications\"."
        echo "$(date +%Y.%m.%d_%T) - INFO:  Skipping Adobe CC ${ADOBE_CC_APP_NAME} uninstall attempts because the target app appears to be absent."
        return 0
    fi

    echo "$(date +%Y.%m.%d_%T) - INFO:  Found Adobe CC ${ADOBE_CC_APP_NAME} app bundle: ${ADOBE_CC_INSTALLED_APP_PATH}"

    # On Apple silicon, retry with arm64 platform token first, then Intel token.
    if [[ "$(/usr/bin/uname -m)" == "arm64" ]]; then
        ADOBE_CC_PLATFORM_CANDIDATES=("osx10-arm64" "osx10-64")
    fi

    # Optional override if you need to force a specific platform token.
    if [[ -n "${ADOBE_CC_PLATFORM_OVERRIDE:-}" ]]; then
        ADOBE_CC_PLATFORM_CANDIDATES=("${ADOBE_CC_PLATFORM_OVERRIDE}")
        echo "$(date +%Y.%m.%d_%T) - INFO:  Using ADOBE_CC_PLATFORM_OVERRIDE=${ADOBE_CC_PLATFORM_OVERRIDE}"
    fi

    function UNINSTALL_PHOTOSHOP_BASE_VERSION
    {
        local ADOBE_CC_TARGET_BASE_VERSION="$1"
        local ADOBE_CC_PLATFORM_CANDIDATE
        local ADOBE_CC_CMD_EXIT_STATUS

        for ADOBE_CC_PLATFORM_CANDIDATE in "${ADOBE_CC_PLATFORM_CANDIDATES[@]}"; do
            ADOBE_CC_UNINSTALL_ATTEMPTS=$((ADOBE_CC_UNINSTALL_ATTEMPTS + 1))
            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_TARGET_BASE_VERSION} on PLATFORM:${ADOBE_CC_PLATFORM_CANDIDATE}"
            echo "$(date +%Y.%m.%d_%T) - CMD:\t${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_TARGET_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM_CANDIDATE} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}" --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}" --baseVersion="${ADOBE_CC_TARGET_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM_CANDIDATE}" --deleteUserPreferences=false
            ADOBE_CC_CMD_EXIT_STATUS=$?
            ADOBE_CC_LAST_EXIT_STATUS="${ADOBE_CC_CMD_EXIT_STATUS}"

            if [[ "${ADOBE_CC_CMD_EXIT_STATUS}" -eq 0 ]]; then
                ADOBE_CC_UNINSTALL_SUCCESS=1
                return 0
            fi

            if [[ "${ADOBE_CC_CMD_EXIT_STATUS}" -eq 135 ]]; then
                echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe returned Exit Code 135 for BASE VERSION:${ADOBE_CC_TARGET_BASE_VERSION} PLATFORM:${ADOBE_CC_PLATFORM_CANDIDATE}. Retrying with next candidate if available."
            else
                echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe uninstall returned Exit Code:${ADOBE_CC_CMD_EXIT_STATUS} for BASE VERSION:${ADOBE_CC_TARGET_BASE_VERSION} PLATFORM:${ADOBE_CC_PLATFORM_CANDIDATE}."
            fi
        done

        return "${ADOBE_CC_LAST_EXIT_STATUS}"
    }
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        UNINSTALL_PHOTOSHOP_BASE_VERSION "${ADOBE_CC_CURRENT_BASE_VERSION}"

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do
            UNINSTALL_PHOTOSHOP_BASE_VERSION "${ADOBE_CC_PREVIOUS_BASE_VERSION}"
        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do
            UNINSTALL_PHOTOSHOP_BASE_VERSION "${ADOBE_CC_PREVIOUS_BASE_VERSION}"
        done

    fi

    EXIT_STATUS="${ADOBE_CC_LAST_EXIT_STATUS}"

    if [[ "${ADOBE_CC_UNINSTALL_SUCCESS}" -eq 0 ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  No Photoshop uninstall command succeeded after ${ADOBE_CC_UNINSTALL_ATTEMPTS} attempts."
        echo "$(date +%Y.%m.%d_%T) - INFO:  Validate installed Photoshop base version and platform token."
        echo "$(date +%Y.%m.%d_%T) - INFO:  Try checking Adobe installer logs under /Library/Logs/Adobe/Installers/ for the exact failure reason."
    fi

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation returned Exit Code 135 for all attempted Photoshop base/platform combinations"
    fi

    unset -f UNINSTALL_PHOTOSHOP_BASE_VERSION

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_PRELUDE

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Prelude"
    ADOBE_CC_SAP_CODE="PRLD"
    ADOBE_CC_CURRENT_BASE_VERSION="22.0"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("9.0" "8.0" "7.0.0" "6.0.0" "5.0.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_PREMIERE_PRO

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Premiere Pro"
    ADOBE_CC_SAP_CODE="PPRO"
    ADOBE_CC_CURRENT_BASE_VERSION="26.0.2"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("25.0" "24.0" "23.0" "22.0" "15.0" "14.0" "13.0" "12.0.0" "11.0.0" "10.3.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_PREMIERE_RUSH

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Premiere Rush"
    ADOBE_CC_SAP_CODE="RUSH"
    ADOBE_CC_CURRENT_BASE_VERSION="2.10"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("2.0" "1.5" "1.2" "1.0" "1.2.12")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_SUBSTANCE_DESIGNER

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Substance Designer"
    ADOBE_CC_SAP_CODE="SBSTD"
    ADOBE_CC_CURRENT_BASE_VERSION="16.0"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("15.0.0" "14.0.0" "11.2.0" "10.2" "9.3.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_SUBSTANCE_PAINTER

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Substance Painter"
    ADOBE_CC_SAP_CODE="SBSTP"
    ADOBE_CC_CURRENT_BASE_VERSION="12.0.2"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("11.0.0" "10.0" "7.2.0" "6.2" "5.3.2")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_SUBSTANCE_SAMPLER

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Substance Sampler"
    ADOBE_CC_SAP_CODE="SBSTA"
    ADOBE_CC_CURRENT_BASE_VERSION="5.1.3"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("4.0.0" "3.0.0" "1.1.2")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_SUBSTANCE_STAGER

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="Substance Stager"
    ADOBE_CC_SAP_CODE="STGR"
    ADOBE_CC_CURRENT_BASE_VERSION="3.1.8"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("2.0.0" "1.0.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

function UNINSTALL_XD

{

	/bin/echo "-----------------------------------------------------------------"
	/bin/echo "$(date +%Y.%m.%d_%T) - FUNC:  ${FUNCNAME[0]}"
	/bin/echo ""

    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC application removal scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"

    ADOBE_CC_APP_NAME="XD"
    ADOBE_CC_SAP_CODE="SPRK"
    ADOBE_CC_CURRENT_BASE_VERSION="18.0.12"
    ADOBE_CC_PREVIOUS_BASE_VERSIONS=("1.0.12" "0.6.2" "0.5.0")
    ADOBE_CC_PLATFORM="osx10-64"
    
	if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "ALL" ]] && [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" != "PREVIOUS" ]]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  The Adobe CC version scope unknown or missing, please try again. ${REMOVE_ADOBE_CC_APP_VERS_SCOPE}"
    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "ALL" ]]; then

        # Remove current Adobe CC application base version
        echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_CURRENT_BASE_VERSION}"
        echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_CURRENT_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
        "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_CURRENT_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    if [[ "${REMOVE_ADOBE_CC_APP_VERS_SCOPE}" = "PREVIOUS" ]]; then

        # Remove previous Adobe CC application base versions
        for	ADOBE_CC_PREVIOUS_BASE_VERSION in "${ADOBE_CC_PREVIOUS_BASE_VERSIONS[@]}"; do

            echo "$(date +%Y.%m.%d_%T) - INFO:  Trying to remove Adobe CC ${ADOBE_CC_APP_NAME} with SAP CODE:${ADOBE_CC_SAP_CODE} and BASE VERSION:${ADOBE_CC_PREVIOUS_BASE_VERSION}"
            echo "$(date +%Y.%m.%d_%T) - CMD:	${ADOBE_CC_SETUP_PATH}  --uninstall=1 --sapCode=${ADOBE_CC_SAP_CODE}  --baseVersion=${ADOBE_CC_PREVIOUS_BASE_VERSION} --platform=${ADOBE_CC_PLATFORM} --deleteUserPreferences=false"
            "${ADOBE_CC_SETUP_PATH}"  --uninstall=1 --sapCode="${ADOBE_CC_SAP_CODE}"  --baseVersion="${ADOBE_CC_PREVIOUS_BASE_VERSION}" --platform="${ADOBE_CC_PLATFORM}" --deleteUserPreferences=false

        done

    fi

    EXIT_STATUS=$?

    if [ "${EXIT_STATUS}" -eq 1 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is General error"
    elif [ "${EXIT_STATUS}" -eq 2 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Misuse of shell builtins"
    elif [ "${EXIT_STATUS}" -eq 126 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is ommand invoked cannot execute"
    elif [ "${EXIT_STATUS}" -eq 128 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Exit Status is Invalid argument"
    elif [ "${EXIT_STATUS}" -eq 135 ]; then
        echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Uninstallation failed due to unknown reason"
        exit 0
    fi

}

#////////////////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////////////////

##################################
# Main

/bin/echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC Application Uninstaller script revision: ${ADOBE_CC_SCRIPT_REVISION}"

case "${REMOVE_ADOBE_CC_APP_NAME_SCOPE}" in

    ALL)
        UNINSTALL_AFTER_EFFECTS
        UNINSTALL_ANIMATE
        UNINSTALL_AUDITION
        UNINSTALL_BRIDGE
        UNINSTALL_CHARACTER_ANIMATOR
        UNINSTALL_DIMENSION
        UNINSTALL_DREAMWEAVER
        UNINSTALL_ILLUSTRATOR
        UNINSTALL_INCOPY
        UNINSTALL_INDESIGN
        UNINSTALL_LIGHTROOM
        UNINSTALL_LIGHTROOM_CLASSIC
        UNINSTALL_MEDIA_ENCODER
        UNINSTALL_PHOTOSHOP
        UNINSTALL_PRELUDE
        UNINSTALL_PREMIERE_PRO
        UNINSTALL_PREMIERE_RUSH
        UNINSTALL_SUBSTANCE_DESIGNER
        UNINSTALL_SUBSTANCE_PAINTER
        UNINSTALL_SUBSTANCE_SAMPLER
        UNINSTALL_SUBSTANCE_STAGER
        UNINSTALL_XD
        ;;

    AFTER_EFFECTS)
        UNINSTALL_AFTER_EFFECTS
        ;;

    ANIMATE)
        UNINSTALL_ANIMATE
        ;;

    AUDITION)
        UNINSTALL_AUDITION
        ;;

    BRIDGE)
        UNINSTALL_BRIDGE
        ;;

    CHARACTER_ANIMATOR)
        UNINSTALL_CHARACTER_ANIMATOR
        ;;

    DIMENSION)
        UNINSTALL_DIMENSION
        ;;

    DREAMWEAVER)
        UNINSTALL_DREAMWEAVER
        ;;
    ILLUSTRATOR)
        UNINSTALL_ILLUSTRATOR
        ;;

    INCOPY)
        UNINSTALL_INCOPY
        ;;
    
    INDESIGN)
        UNINSTALL_INDESIGN
        ;;

    LIGHTROOM)
        UNINSTALL_LIGHTROOM
        ;;

    LIGHTROOM_CLASSIC)
        UNINSTALL_LIGHTROOM_CLASSIC
        ;;

    MEDIA_ENCODER)
        UNINSTALL_MEDIA_ENCODER
        ;;

    PHOTOSHOP)
        UNINSTALL_PHOTOSHOP
        ;;

    PRELUDE)
        UNINSTALL_PRELUDE
        ;;

    PREMIERE_PRO)
        UNINSTALL_PREMIERE_PRO
        ;;

    PREMIERE_RUSH)
        UNINSTALL_PREMIERE_RUSH
        ;;
    
    SUBSTANCE_DESIGNER)
        UNINSTALL_SUBSTANCE_DESIGNER
        ;; 

    SUBSTANCE_PAINTER)
        UNINSTALL_SUBSTANCE_PAINTER
        ;;

    SUBSTANCE_SAMPLER)
        UNINSTALL_SUBSTANCE_SAMPLER
        ;;

    SUBSTANCE_STAGER)
        UNINSTALL_SUBSTANCE_STAGER
        ;;
    
    XD)
        UNINSTALL_XD
        ;;

    *)
        echo "$(date +%Y.%m.%d_%T) - INFO:  Unknown or missing Adobe CC application name scope: ${REMOVE_ADOBE_CC_APP_NAME_SCOPE}"
        ;;
    esac

/bin/sleep 10

# Check if Adobe CC parent directory is empty, if so, remove it
if [ -z "$(ls -A "${ADOBE_CC_PARENT_DIR_PATH}")" ]; then
    echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC parent directory, \"${ADOBE_CC_PARENT_DIR_PATH}\" is empty, will try removing empty directory."
    echo "$(date +%Y.%m.%d_%T) - CMD:	/bin/rm -rf \"${ADOBE_CC_PARENT_DIR_PATH}\""
    /bin/rm -rf "${ADOBE_CC_PARENT_DIR_PATH}"
else
   echo "$(date +%Y.%m.%d_%T) - INFO:  Adobe CC parent directory, \"${ADOBE_CC_PARENT_DIR_PATH}\" is NOT empty, exiting script."
fi

exit $?
