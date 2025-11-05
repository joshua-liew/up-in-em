#!/bin/bash

export FRAD_REPO_DIR=$HOME/.local/share/freeradius-server
# Add according to the FHS
export FRAD_DIR=/usr/local
export FRAD_LOCALSTATE_DIR=/var
export FRAD_LOG_DIR=${FRAD_LOCALSTATE_DIR}/log/freeradius
export FRAD_RUN_DIR=/run/freeradius
# Custom configuration: add to the config directory
export FRAD_CONFIG_DIR=${CONFIG_DIR}/freeradius
# From ./configure --help:
# Fine tuning of the installation directories:
#  --bindir=DIR            user executables [EPREFIX/bin]
#  --sbindir=DIR           system admin executables [EPREFIX/sbin]
#  --libexecdir=DIR        program executables [EPREFIX/libexec]
#  --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
#  --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
#  --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
#  --runstatedir=DIR       modifiable per-process data [LOCALSTATEDIR/run]
#  --libdir=DIR            object code libraries [EPREFIX/lib]
#  --includedir=DIR        C header files [PREFIX/include]
#  --oldincludedir=DIR     C header files for non-gcc [/usr/include]
#  --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
#  --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
#  --infodir=DIR           info documentation [DATAROOTDIR/info]
#  --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
#  --mandir=DIR            man documentation [DATAROOTDIR/man]
#  --docdir=DIR            documentation root [DATAROOTDIR/doc/freeradius]
#  --htmldir=DIR           html documentation [DOCDIR]
#  --dvidir=DIR            dvi documentation [DOCDIR]
#  --pdfdir=DIR            pdf documentation [DOCDIR]
#  --psdir=DIR             ps documentation [DOCDIR]
#  ...
#  Optional Packages:
#  --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
#  --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
#  --with-docdir=DIR       directory for documentation DATADIR/doc/freeradius
#  --with-logdir=DIR       directory for logfiles LOCALSTATEDIR/log/radius
#  --with-radacctdir=DIR   directory for detail files LOGDIR/radacct
#  --with-raddbdir=DIR     directory for config files SYSCONFDIR/raddb
#  --with-dictdir=DIR      directory for dictionary files DATAROOTDIR/freeradius
