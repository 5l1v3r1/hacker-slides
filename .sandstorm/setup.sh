#!/bin/bash
set -euo pipefail
# This script is run in the VM once when you first run `vagrant-spk up`.  It is
# useful for installing system-global dependencies.  It is run exactly once
# over the lifetime of the VM.
#
# This is the ideal place to do things like:
#
#    export DEBIAN_FRONTEND=noninteractive
#    apt-get install -y nginx nodejs nodejs-legacy python2.7 mysql-server
#
# If the packages you're installing here need some configuration adjustments,
# this is also a good place to do that:
#
#    sed --in-place='' \
#            --expression 's/^user www-data/#user www-data/' \
#            --expression 's#^pid /run/nginx.pid#pid /var/run/nginx.pid#' \
#            --expression 's/^\s*error_log.*/error_log stderr;/' \
#            --expression 's/^\s*access_log.*/access_log off;/' \
#            /etc/nginx/nginx.conf

# By default, this script does nothing.  You'll have to modify it as
# appropriate for your application.
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python3 python3-flask \
    build-essential python3-dev python3-pip autoconf pkg-config libtool git

# Install capnproto from source, since Sandstorm currently depends on unreleased capnproto features.
if [ ! -e /usr/local/bin/capnp ]; then
    [ -d capnproto ] || git clone https://github.com/sandstorm-io/capnproto
    pushd capnproto/c++
    autoreconf -i && ./configure && make -j2 && sudo make install
    popd
fi

# Install pycapnp from PyPI, which should use the system libcapnp we just installed
sudo pip3 install pycapnp

# Remove python3-dev, since it puts 55MB of static libraries in usr/lib/python3.4
# that we don't need.
apt-get -y remove python3-dev
apt-get -y autoremove
