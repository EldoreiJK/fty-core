#!/bin/sh

# Copyright (C) 2014 Eaton
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#   
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author(s): Tomas Halman <TomasHalman@eaton.com>
#
# Description: installs basic components we need

# NOTE: This script may be standalone, so we do not depend it on scriptlib.sh
SCRIPTDIR=$(dirname $0)
CHECKOUTDIR=$(realpath $SCRIPTDIR/../..)

[ -z "$LANG" ] && LANG=C
[ -z "$LANGUAGE" ] && LANGUAGE=C
[ -z "$LC_ALL" ] && LC_ALL=C
[ -z "$TZ" ] && TZ=UTC
export LANG LANGUAGE LC_ALL TZ

update_system() {
    # if debian
    curl http://obs.roz.lab.etn.com:82/Pool:/master/Debian_8.0/Release.key | apt-key add -
    # curl http://obs.mbt.lab.etn.com:82/Pool:/master/Debian_8.0/Release.key | apt-key add -
    apt-get clean all
    apt-get update
    # try to deny installation of some hugely useless packages
    # tex-docs for example are huge (850Mb) and useless on a test container
    for P in \
        docutils-doc libssl-doc python-docutils \
        texlive-fonts-recommended-doc \
        texlive-latex-base-doc \
        texlive-latex-extra-doc \
        texlive-latex-recommended-doc \
        texlive-pictures-doc \
        texlive-pstricks-doc \
    ; do
        apt-mark hold "$P" >&2
        echo "$P  purge"
    done | dpkg --set-selections
    apt-get -f -y --force-yes --fix-missing install
    apt-get -f -y --force-yes install devscripts sudo doxygen curl git python-mysqldb \
        cppcheck msmtp libtool
    mk-build-deps --tool 'apt-get --yes --force-yes' --install $CHECKOUTDIR/obs/core.dsc
    # and just to be sure about these space-hungry beasts
    apt-get remove --purge \
        docutils-doc libssl-doc python-docutils \
        texlive-fonts-recommended-doc texlive-latex-base-doc texlive-latex-extra-doc \
        texlive-latex-recommended-doc texlive-pictures-doc texlive-pstricks-doc
}

update_system
