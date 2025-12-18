#!/bin/bash
# Copyright Red Hat
#
# quickmock.sh - Run a quick mock build from HEAD using the in-tree spec file
#
# This file is part of the snapshot manager project.
#
# SPDX-License-Identifier: Apache-2.0
RPMBUILDDIR=~/rpmbuild
MOCKROOT="fedora-$(rpm --eval '%{fedora}')-x86_64"
DIST="$(rpm --eval '%{dist}')"

echo Building SRPM from HEAD...
VERSION=$(python3 -c 'import snapm; print(snapm.__version__);')
git archive -o ${RPMBUILDDIR}/SOURCES/snapm-$VERSION.tar.gz --prefix snapm-$VERSION/ HEAD
rm -f ${RPMBUILDDIR}/SPECS/snapm.spec
cp -fn snapm.spec ${RPMBUILDDIR}/SPECS
rpmbuild -bs ${RPMBUILDDIR}/SPECS/snapm.spec

SRPMPATH="${RPMBUILDDIR}/SRPMS/snapm-${VERSION}-1${DIST}.src.rpm"
if [ ! -e "$SRPMPATH" ]; then
    echo Failed to build SRPM $SRPMPATH
    exit 1
fi

echo Building RPMs for mock root ${MOCKROOT}...
mock -r $MOCKROOT $SRPMPATH
