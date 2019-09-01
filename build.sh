#!/bin/bash

source="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

usage () {
	echo "# usage: ./build.sh.sh (component-name)"
	echo "# (optional) valid component names are: uhd, gnuradio, gr-gsm, libosmocore, gr-osmosdr, kalibrate"
	exit 1
}

installIfMissing () {
	dpkg -s $@ > /dev/null
	if [ $? -ne 0 ]; then
		echo "# - missing $@, installing dependency"
		sudo apt-get install $@ -y
	fi
}

sayAndDo () {
	echo $@
	eval $@
	if [ $? -ne 0 ]; then
		echo "# ERROR: command failed!"
		exit 1
	fi
}


COMPONENT="all"
if [ ! -z "$1" ]; then
	COMPONENT="$1"
	echo "# single component specified"
	if [ "$COMPONENT" == "uhd" ] || [ "$COMPONENT" == "gnuradio" ] || [ "$COMPONENT" == "gr-gsm" ] || [ "$COMPONENT" == "libosmocore" ] || [ "$COMPONENT" == "gr-osmosdr" ] || [ "$COMPONENT" == "kalibrate" ]; then
		echo "# - found, building and installing $COMPONENT"
	else
		echo "# - ERROR : invalid component ($COMPONENT)"
		usage
	fi
fi

echo "# checking for a compatible build host"
if hash lsb_release 2>/dev/null; then
	ubuntu=`lsb_release -r -s`
	if [ $ubuntu != "18.04" ]; then
		echo "# - WARNING : build is currently only tested on Ubuntu 18.04."
	else
		echo "# - fully supported host detected: Ubuntu 18.04"
	fi
else
	echo "# - ERROR : Sorry, build currently only supports Ubuntu as the host OS. Please open an issue for your desired host."
	echo "# - exiting"
	exit 1
fi
echo "#"

echo "# adding additional tools"
installIfMissing vim
installIfMissing socat
installIfMissing gdb		# VS stuff
installIfMissing hddtemp
installIfMissing lm-sensors
echo "# - done"
echo


if [ "$COMPONENT" == "all" ] || [ "$COMPONENT" == "uhd" ]; then
	echo "#####################################################################"
	echo "# uhd - building and installing"
	echo "# checking build dependencies"

	installIfMissing	build-essential
	installIfMissing	cmake
	installIfMissing	doxygen
	installIfMissing	git
	installIfMissing	libboost-all-dev
	installIfMissing	libusb-1.0-0-dev
	installIfMissing	python-docutils
	installIfMissing	python3-mako

	sayAndDo git clone https://github.com/EttusResearch/uhd
	sayAndDo cd uhd
	# sayAndDo git tag -l
	# sayAndDo git checkout v3.14.0.0
	sayAndDo cd host
	sayAndDo mkdir build
	sayAndDo cd build
	sayAndDo cmake ../
	sayAndDo make -j$(nproc)
	# sayAndDo make test
	sayAndDo sudo make install
	sayAndDo sudo ldconfig
	sayAndDo sudo /usr/local/lib/uhd/utils/uhd_images_downloader.py
	sayAndDo cd $source
	echo "# - done"
	echo
fi


if [ "$COMPONENT" == "all" ] || [ "$COMPONENT" == "gnuradio" ]; then
	echo "#####################################################################"
	echo "# gnuradio - building and installing"
	echo "# checking build dependencies"
	installIfMissing	cmake
	installIfMissing	doxygen
	installIfMissing	g++
	installIfMissing	git
	installIfMissing	libboost-all-dev
	installIfMissing	libcomedi-dev
	installIfMissing	libfftw3-dev
	installIfMissing	libgmp-dev
	installIfMissing	libgsl-dev
	installIfMissing	liblog4cpp5-dev
	installIfMissing	libqt5opengl5-dev
	installIfMissing	libqwt-qt5-dev
	installIfMissing	libsdl1.2-dev
	installIfMissing	libzmq3-dev
	installIfMissing	python3-zmq
	installIfMissing	python3-click
	installIfMissing	python3-click-plugins
	installIfMissing	python3-lxml
	installIfMissing	python3-mako
	installIfMissing	python3-numpy
	installIfMissing	python3-pyqt5
	installIfMissing	python3-sphinx
	installIfMissing	python3-yaml
	installIfMissing	python3-scipy
	installIfMissing	swig

	sayAndDo git clone --recursive https://github.com/gnuradio/gnuradio.git
	sayAndDo cd gnuradio
	# sayAndDo git tag -l
	# sayAndDo git checkout maint-3.8 
	sayAndDo git checkout v3.8.0.0 
	sayAndDo mkdir build
	sayAndDo cd build
	sayAndDo cmake ../
	sayAndDo make -j$(nproc)
	# sayAndDo make test
	sayAndDo sudo make install
	sayAndDo sudo ldconfig
	sayAndDo cd $source
	echo "# - done"
	echo
fi

if [ "$COMPONENT" == "all" ] || [ "$COMPONENT" == "libosmocore" ]; then
	echo "#####################################################################"
	echo "# libosmocore - building and installing"
	echo "# checking build dependencies"
	installIfMissing	autoconf
	installIfMissing	automake
	installIfMissing	build-essential
	installIfMissing	gcc
	installIfMissing	git-core
	installIfMissing	libgnutls28-dev
	installIfMissing	libpcsclite-dev
	installIfMissing	libtalloc-dev
	installIfMissing	libtool
	installIfMissing	make
	installIfMissing	pkg-config
	installIfMissing	shtool

	sayAndDo git clone git://git.osmocom.org/libosmocore.git
	sayAndDo cd libosmocore
	# sayAndDo git tag -l
	# sayAndDo git checkout 
	sayAndDo autoreconf -i
	sayAndDo ./configure
	sayAndDo make -j$(nproc)
	sayAndDo sudo make install
	sayAndDo sudo ldconfig -i
	sayAndDo cd $source
	echo "# - done"
	echo
fi

if [ "$COMPONENT" == "all" ] || [ "$COMPONENT" == "gr-osmosdr" ]; then
	echo "#####################################################################"
	echo "# gr-osmosdr - building and installing"
	echo "# checking build dependencies"
	installIfMissing	doxygen
	
	sayAndDo git clone https://github.com/velichkov/gr-osmosdr.git
	sayAndDo cd gr-osmosdr
	sayAndDo git branch -a
	sayAndDo git checkout maint-3.8 
	sayAndDo mkdir build
	sayAndDo cd build
	sayAndDo cmake ..
	sayAndDo make -j$(nproc)
	sayAndDo sudo make install
	sayAndDo sudo ldconfig
	sayAndDo cd $source
	echo "# - done"
	echo
fi

if [ "$COMPONENT" == "all" ] || [ "$COMPONENT" == "gr-gsm" ]; then
	echo "#####################################################################"
	echo "# gr-gsm - building and installing"
	echo "# checking build dependencies"
	installIfMissing	cmake
	installIfMissing	autoconf
	installIfMissing	libtool
	installIfMissing	pkg-config
	installIfMissing	build-essential
	installIfMissing	python-docutils
	installIfMissing	libcppunit-dev
	installIfMissing	swig
	installIfMissing	doxygen
	installIfMissing	liblog4cpp5-dev
	installIfMissing	python-scipy
	installIfMissing	python-gtk2

	sayAndDo git clone https://github.com/velichkov/gr-gsm.git
	sayAndDo cd gr-gsm
	sayAndDo git branch -a
	sayAndDo git checkout maint-3.8
	sayAndDo mkdir build
	sayAndDo cd build
	sayAndDo cmake ..
	sayAndDo make -j$(nproc)
	sayAndDo sudo make install
	sayAndDo sudo ldconfig
	sayAndDo cd $source
	echo "# - done"
	echo
fi

if [ "$COMPONENT" == "all" ] || [ "$COMPONENT" == "kalibrate" ]; then
	echo "#####################################################################"
	echo "# kalibrate - building and installing"
	echo "# checking build dependencies"

	sayAndDo git clone https://github.com/prkrmx/kalibrate.git
	sayAndDo cd kalibrate
	sayAndDo autoreconf -i
	sayAndDo ./configure
	sayAndDo make -j$(nproc)
	sayAndDo sudo make install
	sayAndDo sudo ldconfig
	sayAndDo cd $source
	echo "# - done"
	echo
fi
