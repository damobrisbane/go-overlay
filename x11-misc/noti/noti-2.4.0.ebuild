# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GOLANG_PKG_IMPORTPATH="github.com/variadico"
GOLANG_PKG_BUILDPATH="/cmd/noti"
GOLANG_PKG_ARCHIVEPREFIX="v"

inherit golang-single

DESCRIPTION="Display a notification when a terminal process finishes"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm x86"

RESTRICT+=" test"

RDEPEND="x11-libs/libnotify
	app-accessibility/espeak"

src_install() {
	golang-single_src_install
	dodoc -r docs/*
}
