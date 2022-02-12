#!/bin/bash
#
# Build script for universal Python 3 framework

MUNKIPKG_DIR=$(dirname "$0")
REQUIREMENTS="${MUNKIPKG_DIR}/requirements.txt"
PYTHON_VERSION=3.9.7
MACOS_VERSION=11
MUNKIPKG_INSTALL_DIR="${MUNKIPKG_DIR}/payload/usr/local/munkipkg"

# Sanity checks.
GIT=$(which git)
WHICH_GIT_RESULT="$?"
if [ "${WHICH_GIT_RESULT}" != "0" ]; then
    echo "Could not find git in command path. Maybe it's not installed?" 1>&2
    echo "You can get a Git package here:" 1>&2
    echo "    https://git-scm.com/download/mac"
    exit 1
fi
if [ ! -d "${MUNKIPKG_DIR}/payload" ]; then
    echo "Does not look like you are running this script from a munkipkg git repo." 1>&2
    exit 1
fi
if [ ! -f "${REQUIREMENTS}" ]; then
    echo "Missing requirements file at ${REQUIREMENTS}." 1>&2
    exit 1
fi

# clone our relocatable-python tool
PYTHONTOOLDIR="/tmp/relocatable-python-git"
if [ -d "${PYTHONTOOLDIR}" ]; then
    rm -rf "${PYTHONTOOLDIR}"
fi
echo "Cloning relocatable-python tool from github..."
git clone https://github.com/gregneagle/relocatable-python.git "${PYTHONTOOLDIR}"
CLONE_RESULT="$?"
if [ "${CLONE_RESULT}" != "0" ]; then
    echo "Error cloning relocatable-python tool repo: ${CLONE_RESULT}" 1>&2
    exit 1
fi

# remove existing Python.framework if present
if [ -d "${MUNKIPKG_INSTALL_DIR}/Python.framework" ]; then
    rm -rf "${MUNKIPKG_INSTALL_DIR}//Python.framework"
fi

# build the framework
"${PYTHONTOOLDIR}/make_relocatable_python_framework.py" \
    --python-version "${PYTHON_VERSION}" \
    --os-version "${MACOS_VERSION}" \
    --upgrade-pip \
    --pip-requirements "${REQUIREMENTS}" \
    --destination "${MUNKIPKG_INSTALL_DIR}"