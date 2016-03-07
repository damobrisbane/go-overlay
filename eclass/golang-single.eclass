# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: golang-single.eclass
# @MAINTAINER:
# Mauro Toffanin <toffanin.mauro@gmail.com>
# @AUTHOR:
# Mauro Toffanin <toffanin.mauro@gmail.com>
# @BLURB: An eclass for GoLang packages not installed inside GOPATH/GOBIN.
# @DESCRIPTION:
# This eclass allows to install arbitrary packages written in GoLang which
# don't support being installed inside the Go environment.
# This mostly includes traditional packages (C/C++/GUI) embedding tools written
# in GoLang, and GoLang packages that need to be compiled with GCC instead of
# the standard Go interpreter.
#
# @EXAMPLE:
# Typical ebuild using golang-single.eclass:
#
# @CODE
# EAPI=5
#
# GOLANG_PKG_IMPORTPATH="github.com/captObvious"
# GOLANG_PKG_ARCHIVESUFFIX=".zip"
# GOLANG_PKG_HAVE_TEST
# inherit golang-single qt4-r2
#
# DESCRIPTION="Foo bar application"
# HOMEPAGE="http://example.org/foo/"
#
# LICENSE="MIT"
# KEYWORDS="~amd64 ~x86"
# SLOT="0"
# IUSE="debug doc qt4"
#
# CDEPEND="
#   qt4? (
#       dev-qt/qtcore:4
#       dev-qt/qtgui:4
#   )"
# RDEPEND="${CDEPEND}
#   !media-gfx/bar"
# DEPEND="${CDEPEND}
#   doc? ( app-doc/doxygen )"
#
# DOCS=(AUTHORS ChangeLog README "Read me.txt" TODO)
#
# PATCHES=(
#   "${FILESDIR}/${P}-qt4.patch" # bug 123458
#   "${FILESDIR}/${P}-as-needed.patch"
# )
#
# src_install() {
#   use doc && HTML_DOCS=("${BUILD_DIR}/apidocs/html/")
#   autotools-utils_src_install
#   if use examples; then
#       dobin "${BUILD_DIR}"/foo_example{1,2,3} \\
#           || die 'dobin examples failed'
#   fi
# }
#
# @CODE


inherit eutils multiprocessing golang-utils

RESTRICT+=" mirror strip"

QA_FLAGS_IGNORED="usr/bin/.*
	usr/sbin/.*"

EXPORT_FUNCTIONS src_prepare src_unpack src_configure src_compile src_install src_test


# @ECLASS-VARIABLE: GOLANG_PKG_NAME
# @DESCRIPTION:
# Sets the GoLang name for the generated package.
# GOLANG_PKG_NAME="${PN}"
GOLANG_PKG_NAME="${GOLANG_PKG_NAME:-${PN}}"

# @ECLASS-VARIABLE: GOLANG_PKG_VERSION
# @DESCRIPTION:
# Sets the GoLang version for the generated package.
# GOLANG_PKG_VERSION="${PV}"
GOLANG_PKG_VERSION="${GOLANG_PKG_VERSION:-${PV/_pre/.pre}}"

# @ECLASS-VARIABLE: GOLANG_PKG_IMPORTPATH
# @DESCRIPTION:
# Sets the remote import path for the generated package.
# GOLANG_PKG_IMPORTPATH="github.com/captObvious/"
GOLANG_PKG_IMPORTPATH="${GOLANG_PKG_IMPORTPATH:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_IMPORTPATH_ALIAS
# @DESCRIPTION:
# Sets an alias of the remote import path for the generated package.
# GOLANG_PKG_IMPORTPATH_ALIAS="privaterepo.com/captObvious/"
GOLANG_PKG_IMPORTPATH_ALIAS="${GOLANG_PKG_IMPORTPATH_ALIAS:="${GOLANG_PKG_IMPORTPATH}"}"

# @ECLASS-VARIABLE: GOLANG_PKG_ARCHIVEPREFIX
# @DESCRIPTION:
# Sets the archive prefix for the file URI of the package.
# Most projects hosted on GitHub's mirrors provide archives with prefix as
# 'v' or 'source-', other hosted services offer different archive formats.
# This eclass defaults to an empty prefix.
GOLANG_PKG_ARCHIVEPREFIX="${GOLANG_PKG_ARCHIVEPREFIX:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_ARCHIVESUFFIX
# @DESCRIPTION:
# Sets the archive suffix for the file URI of the package.
# Most projects hosted on GitHub's mirrors provide archives with suffix as
# '.tar.gz' or '.zip', other hosted services offer different archive formats.
# This eclass defaults to '.tar.gz'.
GOLANG_PKG_ARCHIVESUFFIX="${GOLANG_PKG_ARCHIVESUFFIX:=".tar.gz"}"

# @ECLASS-VARIABLE: GOLANG_PKG_OUTPUT_NAME
# @DESCRIPTION:
# Specifies the output file name of the package.
# If not set, it derives from the name of the package, such as $GOLANG_PKG_NAME.
# This eclass defaults to $PN.
GOLANG_PKG_OUTPUT_NAME="${GOLANG_PKG_OUTPUT_NAME:="${PN}"}"

# @ECLASS-VARIABLE: GOLANG_PKG_BUILDPATH
# @DESCRIPTION:
# Specifies a go source file to be compiled as a single main package.
# This eclass defaults to an empty value.
# This eclass defaults to "/..." when the user declares GOLANG_PKG_IS_MULTIPLE=1
GOLANG_PKG_BUILDPATH="${GOLANG_PKG_BUILDPATH:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_INSTALLPATH
# @DESCRIPTION:
# Sets the root path into which a binary, or a list of binaries, will be
# installed (e.x.: ${GOLANG_PKG_INSTALLPATH}/bin).
# This eclass defaults to "/usr"
GOLANG_PKG_INSTALLPATH="${GOLANG_PKG_INSTALLPATH:="/usr"}"

# @ECLASS-VARIABLE: GOLANG_PKG_INSTALLSUFFIX
# @DESCRIPTION:
# Sets a suffix to use in the name of the package installation directory.
# This eclass defaults to an empty install suffix.
GOLANG_PKG_INSTALLSUFFIX="${GOLANG_PKG_INSTALLSUFFIX:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_IS_MULTIPLE
# @DESCRIPTION:
# Set to enable the building of multiple packages from a single import path.

# @ECLASS-VARIABLE: GOLANG_PKG_HAVE_TEST
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set to enable the execution of automated testing.

# @ECLASS-VARIABLE: GOLANG_PKG_HAVE_TEST_RACE
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set to enable the execution of automated testing with support for
# data race detection.

# @ECLASS-VARIABLE: GOLANG_PKG_USE_CGO
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set to enable the compilation of the package with CGO.

# @ECLASS-VARIABLE: GOLANG_PKG_USE_GENERATE
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set to run commands described by directives within existing golang files.

# @ECLASS-VARIABLE: GOLANG_PKG_DEPEND_ON_GO_SUBSLOT
# @DESCRIPTION:
# Set to ensure the package does depend on the dev-lang/go subslot value.
# Possible values: {yes,no}
# This eclass defaults to "no"
GOLANG_PKG_DEPEND_ON_GO_SUBSLOT=${GOLANG_PKG_DEPEND_ON_GO_SUBSLOT:="no"}

# @ECLASS-VARIABLE: GOLANG_PKG_LDFLAGS
# @DESCRIPTION:
# Sets the linker arguments to pass to 5l, 6l, or 8l.
# This eclass defaults to an empty list.
GOLANG_PKG_LDFLAGS="${GOLANG_PKG_LDFLAGS:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_TAGS
# @DESCRIPTION:
# Sets the list of build tags during the build.
# This eclass defaults to an empty list.
GOLANG_PKG_TAGS="${GOLANG_PKG_TAGS:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_VENDOR
# @DESCRIPTION:
# Sets additional standard Go workspaces to be appended to the environment
# variable GOPATH, as described in http://golang.org/doc/code.html.
# This eclass defaults to an empty list.
GOLANG_PKG_VENDOR="${GOLANG_PKG_VENDOR:-}"

# @ECLASS-VARIABLE: GOLANG_PKG_STATIK
# @DESCRIPTION:
# Sets the arguments to pass to dev-go/statik.
# This eclass defaults to an empty list.
GOLANG_PKG_STATIK="${GOLANG_PKG_STATIK:-}"


# @ECLASS-VARIABLE: GO
# @DEFAULT_UNSET
# @DESCRIPTION:
# The absolute path to the current GoLang interpreter.
#
# This variable is set automatically after calling golang_setup().
#
# Default value:
# @CODE
# /usr/bin/go
# @CODE

# @ECLASS-VARIABLE: EGO
# @DEFAULT_UNSET
# @DESCRIPTION:
# The executable name of the current GoLang interpreter.
#
# This variable is set automatically after calling golang_setup().
#
# Default value:
# @CODE
# go
# @CODE

# @ECLASS-VARIABLE: PATCHES
# @DEFAULT_UNSET
# @DESCRIPTION:
# Array variable containing all the patches to be applied. This variable
# is expected to be defined in the global scope of ebuilds. Make sure to
# specify the full path. This variable is used in src_prepare phase.
#
# Example:
# @CODE
#	PATCHES=(
#		"${FILESDIR}/mypatch.patch"
#		"${FILESDIR}/mypatch2.patch"
#	)
# @CODE

# @FUNCTION: create_sourcedir
# @INTERNAL
# @DESCRIPTION:
# Prepares the source path declared by S.
_create_sourcedir() {
	debug-print-function ${FUNCNAME} "${@}"

	mkdir -p "${S%/*}" || die
}


# @FUNCTION: _factorize_dependency_entities
# @INTERNAL
# @DESCRIPTION:
# Factorizes the dependency declaration in specific tokens such as the import
# path, the import path alias, the host name, the author name, the project name,
# and the revision tag.
_factorize_dependency_entities() {
	debug-print-function ${FUNCNAME} "${@}"

	local -A dependency=()
	local key_list=(importpathalias importpath host project_name author_name revision)

	# Strips all the white spaces from the supplied argument.
	local raw_dependency="${1//\ /}"

	# Determines the alias of the import path (if present).
	dependency[importpathalias]="${raw_dependency##*->}"

	# Strips the import path alias from the supplied argument.
	raw_dependency="${raw_dependency%%->*}"

	# Determines the import path.
	dependency[importpath]="${raw_dependency%:*}"

	# When the importpath alias is not specified, then this eclass sets the
	# alias as equal to the import path minus the project name.
	if [[ "${raw_dependency}" == "${dependency[importpathalias]}" ]]; then
		dependency[importpathalias]="${dependency[importpath]%/*}"
	fi

	# Determines the host.
	dependency[host]="${dependency[importpath]%%/*}"

	# Determines the project name.
	dependency[project_name]="${dependency[importpath]##*/}"

	# Determines the author name.
	dependency[author_name]="${dependency[importpath]#*/}"
	dependency[author_name]="${dependency[author_name]%/*}"

	# Determines the revision.
	dependency[revision]="${raw_dependency#*:}"

	# Exports all the dependency tokens as an associated list.
	for key in ${key_list[@]}; do
		echo "${key} ${dependency[${key}]}"
	done
}


# Silences repoman warnings.
case "${EAPI:-0}" in
	6)
		case "${GOLANG_PKG_DEPEND_ON_GO_SUBSLOT:-yes}" in
			yes)
				GO_DEPEND="dev-lang/go:0="
				;;
			*)
				GO_DEPEND="dev-lang/go:*"
				;;
		esac
		;;
	*)
		die "EAPI=${EAPI} is not supported by golang-single.eclass"
		;;
esac
DEPEND+=" ${GO_DEPEND}"

# Adds gccgo as a compile-time dependency when GOLANG_PKG_USE_CGO is set.
[[ -n ${GOLANG_PKG_USE_CGO} ]] && DEPEND+=" >=sys-devel/gcc-4.8.4[go]"

# Adds dev-go/statik as a compile-time dependency when GOLANG_PKG_STATIK is set.
[[ -n ${GOLANG_PKG_STATIK} ]] && DEPEND+=" dev-go/statik"

# Validates GOLANG_PKG_IMPORTPATH.
if [[ -z ${GOLANG_PKG_IMPORTPATH} ]]; then
	eerror "The remote import path for this package has not been declared"
	die "Mandatory variable GOLANG_PKG_IMPORTPATH is unset"
fi

# Forces a multiple package build when user specifies GOLANG_PKG_IS_MULTIPLE=1.
if [[ -n ${GOLANG_PKG_IS_MULTIPLE} && -z ${GOLANG_PKG_BUILDPATH} ]]; then
	GOLANG_PKG_BUILDPATH="/..."
fi

# Validates use of GOLANG_PKG_BUILDPATH combined with GOLANG_PKG_IS_MULTIPLE
# FIX: makes sure user isn't overriding GOLANG_PKG_BUILDPATH with inane values.
if [[ -n ${GOLANG_PKG_IS_MULTIPLE} && ${GOLANG_PKG_BUILDPATH##*/} != "..." ]]; then
	ewarn "Ebuild ${CATEGORY}/${PF} specifies GOLANG_PKG_IS_MULTIPLE=1,"
	ewarn "but then GOLANG_PKG_BUILDPATH is overridden with \"${GOLANG_PKG_BUILDPATH}\"."
	ewarn "Please, fix it by appending \"/...\" to your GOLANG_PKG_BUILDPATH."
	ewarn "If in doubt, remove GOLANG_PKG_BUILDPATH entirely."
fi

# Even though xz-utils are in @system, they must still be added to DEPEND; see
# http://archives.gentoo.org/gentoo-dev/msg_a0d4833eb314d1be5d5802a3b710e0a4.xml
if [[ ${GOLANG_PKG_ARCHIVESUFFIX/.*} == "xz" ]]; then
	DEPEND+=" app-arch/xz-utils"
fi

# Enables USE 'test' when required by GOLANG_PKG_HAVE_TEST.
if [[ -n ${GOLANG_PKG_HAVE_TEST} ]]; then
	IUSE+=" test"
fi

# This eclass uses GOLANG_PKG_IMPORTPATH to populate SRC_URI.
SRC_URI="https://${GOLANG_PKG_IMPORTPATH}/${GOLANG_PKG_NAME}/archive/${GOLANG_PKG_ARCHIVEPREFIX}${GOLANG_PKG_VERSION}${GOLANG_PKG_ARCHIVESUFFIX} -> ${P}${GOLANG_PKG_ARCHIVESUFFIX}"

# This eclass uses GOLANG_PKG_IMPORTPATH associative array to populate SRC_URI
# with the required snapshots of the supplied GoLang dependencies.
if [[ ${#GOLANG_PKG_DEPENDENCIES[@]} -gt 0 ]]; then

	for i in ${!GOLANG_PKG_DEPENDENCIES[@]} ; do

		# Collects all the tokens of the dependency.
		local -A DEPENDENCY=()
		while read -d $'\n' key value; do
			[[ -z ${key} ]] && continue
			DEPENDENCY[$key]="${value}"
		done <<-EOF
			$( _factorize_dependency_entities "${GOLANG_PKG_DEPENDENCIES[$i]}" )
		EOF

		# Debug
		debug-print "${FUNCNAME}: DEPENDENCY = ${GOLANG_PKG_DEPENDENCIES[$i]}"
		debug-print "${FUNCNAME}: importpath = ${DEPENDENCY[importpath]}"
		debug-print "${FUNCNAME}: revision   = ${DEPENDENCY[revision]}"

		# Downloads the archive.
		case ${DEPENDENCY[importpath]} in
			github*)
				SRC_URI+=" https://${DEPENDENCY[importpath]}/archive/${DEPENDENCY[revision]}${GOLANG_PKG_ARCHIVESUFFIX} -> ${DEPENDENCY[importpath]//\//-}-${DEPENDENCY[revision]}${GOLANG_PKG_ARCHIVESUFFIX}"
				;;
			bitbucket*)
				SRC_URI+=" https://${DEPENDENCY[importpath]}/get/${DEPENDENCY[revision]}.zip -> ${DEPENDENCY[importpath]//\//-}-${DEPENDENCY[revision]}.zip"
				;;
			code.google*)
				SRC_URI+=" https://${DEPENDENCY[project_name]}.googlecode.com/archive/${DEPENDENCY[revision]}.tar.gz -> ${DEPENDENCY[importpath]//\//-}-${DEPENDENCY[revision]}.tar.gz"
				;;
			*) die "This eclass doesn't support '${DEPENDENCY[importpath]}'" ;;
		esac

	done
fi


# Defines SOURCE directory.
S="${WORKDIR}/gopath/src/${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME}"


# @FUNCTION: golang_setup
# @DESCRIPTION:
# Determines where is the GoLang implementation and then set-up the
# GoLang build environment.
golang_setup() {
	debug-print-function ${FUNCNAME} "${@}"

	# NOTE: Keep /usr/bin/go as index [0] and never overwrite it,
	#       always append other binary paths after the index [0]
	local GOLANG_BINS=(
		/usr/bin/go
		/usr/bin/gofmt
	)

	[[ -n ${GOLANG_PKG_STATIK} ]] && GOLANG_BINS+=(/usr/bin/statik)

	# Reset GoLang environment variables
	unset EGO
	unset EGOFMT
	unset ESTATIK
	unset GO
	unset GOPATH
	unset GOBIN

	# Determine is the GoLang interpreter is working
	local IS_EXECUTABLE=1
	for binary in "${GOLANG_BINS[@]}"; do
		debug-print "${FUNCNAME}: Checking ... ${binary}"

		[[ -x "${EPREFIX}/${binary}" ]] && continue
		IS_EXECUTABLE=0
		ewarn "It seems that the binary '${binary}' is not executable."
	done

	# dev-lang/go isn't installed or one of its binaries aren't executable.
	# Either way, the Gentoo box is screwed; no need to set up the GoLang environment
	[[ ${IS_EXECUTABLE} == 0 ]] && exit

	# dev-lang/go is available and working.
	# Exports GO/EGO/EGOFMT global variables.
	export GO="${GOLANG_BINS[0]}"
	export EGO="${GOLANG_BINS[0]##*/}"
	export EGOFMT="${GOLANG_BINS[1]}"

	# dev-go/statik is available and working.
	# Exports ESTATIK global variable.
	[[ -n ${GOLANG_PKG_STATIK} ]] && export ESTATIK="${GOLANG_BINS[2]##*/}"

	debug-print "${FUNCNAME}: GO = ${GO}"
	debug-print "${FUNCNAME}: EGO = ${EGO}"
	debug-print "${FUNCNAME}: EGOFMT = ${EGOFMT}"
	debug-print "${FUNCNAME}: ESTATIK = ${ESTATIK}"

	# Determines go interpreter version.
	GOLANG_VERSION="$( ${GO} version )"
	GOLANG_VERSION="${GOLANG_VERSION/go\ version\ go}"
	export GOLANG_VERSION="${GOLANG_VERSION%\ *}"
	einfo "Found GoLang version: ${GOLANG_VERSION}"

	# Determines statik interpreter version.
	# TODO: add version detection when statik will provide a -version option.
	if [[ -n ${GOLANG_PKG_STATIK} ]]; then
		local STATIK_VERSION=""
		einfo "Found statik version: ${STATIK_VERSION}"
	fi

	# Sets the build environment inside Portage's WORKDIR.
	ebegin "Setting up GoLang build environment"

		# Prepares CGO_ENABLED.
		CGO_ENABLED=0
		[[ -z ${GOLANG_PKG_USE_CGO} ]] || CGO_ENABLED=1

		# Prepares gopath / gobin directories inside WORKDIR.
		local _GOPATH="${WORKDIR}/gopath"
		local _GOBIN="${WORKDIR}/gobin"
		mkdir -p "${_GOBIN}" || die
		mkdir -p "${_GOPATH}"/src || die

		# Exports special env variable EGO_SRC.
		export EGO_SRC="${_GOPATH}/src"

		# Exports GoLang env variables.
		export GOPATH="$_GOPATH"
		export GOBIN="$_GOBIN"
		export CGO_ENABLED

		debug-print "${FUNCNAME}: GOPATH = ${GOPATH}"
		debug-print "${FUNCNAME}: GOBIN = ${GOBIN}"
		debug-print "${FUNCNAME}: EGO_SRC = ${EGO_SRC}"
		debug-print "${FUNCNAME}: CGO_ENABLED = ${CGO_ENABLED}"
	eend
}


# @FUNCTION: golang-single_src_unpack
# @DESCRIPTION:
# Unpack the source archive.
golang-single_src_unpack() {
	debug-print-function ${FUNCNAME} "${@}"

	default

	# Create S by moving main GoLang package from WORKDIR into GOPATH.
	_create_sourcedir
	mv "${GOLANG_PKG_NAME}-${GOLANG_PKG_VERSION}" "${S}"/ || die
}

# @FUNCTION: golang-single_src_prepare
# @DESCRIPTION:
# Prepare source code.
golang-single_src_prepare() {
	debug-print-function ${FUNCNAME} "${@}"

	# Sets up GoLang build environment.
	golang_setup


	pushd "${WORKDIR}" > /dev/null
		einfo "Preparing GoLang build environment in ${GOPATH}/src"

		# If the ebuild declares some GoLang dependencies, then they need to be
		# correctly installed into the sand-boxed GoLang build environment which
		# was set up automatically during pkg_setup() phase.
		if [[ ${#GOLANG_PKG_DEPENDENCIES[@]} -gt 0 ]]; then

			for i in ${!GOLANG_PKG_DEPENDENCIES[@]} ; do

				# Collects all the tokens of the dependency.
				local -A DEPENDENCY=()
				while read -d $'\n' key value; do
					[[ -z ${key} ]] && continue
					DEPENDENCY[$key]="${value}"
				done <<-EOF
					$( _factorize_dependency_entities "${GOLANG_PKG_DEPENDENCIES[$i]}" )
				EOF

				# Debug
				debug-print "${FUNCNAME}: DEPENDENCY      = ${GOLANG_PKG_DEPENDENCIES[$i]}"
				debug-print "${FUNCNAME}: importpath      = ${DEPENDENCY[importpath]}"
				debug-print "${FUNCNAME}: importpathalias = ${DEPENDENCY[importpathalias]}"
				debug-print "${FUNCNAME}: host            = ${DEPENDENCY[host]}"
				debug-print "${FUNCNAME}: author          = ${DEPENDENCY[author_name]}"
				debug-print "${FUNCNAME}: project         = ${DEPENDENCY[project_name]}"
				debug-print "${FUNCNAME}: revision        = ${DEPENDENCY[revision]}"

				local message="Importing ${DEPENDENCY[importpath]}"
				local destdir

				# Prepares GOPATH structure.
				case ${DEPENDENCY[importpathalias]} in
					gopkg.in*)
						message+=" as ${DEPENDENCY[importpathalias]}"
						destdir="${DEPENDENCY[importpathalias]}"

						# Creates the import path in GOPATH.
						mkdir -p "${GOPATH}/src/${DEPENDENCY[importpathalias]%/*}" || die
						#einfo "\n${GOPATH}/src/${DEPENDENCY[importpathalias]%/*}"
						;;
					*)
						[[ "${DEPENDENCY[importpath]}" != "${DEPENDENCY[importpathalias]}/${DEPENDENCY[project_name]}" ]] && message+=" as ${DEPENDENCY[importpathalias]}/${DEPENDENCY[project_name]}"
						destdir="${DEPENDENCY[importpathalias]}/${DEPENDENCY[project_name]}"

						# Creates the import path in GOPATH.
						mkdir -p "${GOPATH}/src/${DEPENDENCY[importpathalias]}" || die
						#einfo "\n${GOPATH}/src/${DEPENDENCY[importpathalias]}"
						;;
				esac

				# Moves sources from WORKDIR into GOPATH.
				case ${DEPENDENCY[host]} in
					github*)
						ebegin "${message}"
							mv ${DEPENDENCY[project_name]}-${DEPENDENCY[revision]}* "${GOPATH}"/src/${destdir} || die
						eend

						# FIX: sometimes the source code inside an importpath alias
						#      (such as gopkg.in/mylib.v1) invokes imports from
						#      the original import path instead of using the alias,
						#      thus we need a symbolic link between the alias and
						#      the original import path to avoid compilation issues.
						#      Example: gopkg.in/Shopify/sarama.v1 erroneously
						#      invokes imports from github.com/shopify/sarama
						if [[ ${destdir} != ${DEPENDENCY[importpath]} ]]; then
							golang_fix_importpath_alias ${destdir} ${DEPENDENCY[importpath]}
						fi
						;;
					bitbucket*)
						#einfo "path: ${DEPENDENCY[author_name]}-${DEPENDENCY[project_name]}-${DEPENDENCY[revision]}"
						ebegin "${message}"
							mv ${DEPENDENCY[author_name]}-${DEPENDENCY[project_name]}-${DEPENDENCY[revision]}* "${GOPATH}"/src/${destdir} || die
						eend
						;;
					code.google*)
						ebegin "${message}"
							mv ${DEPENDENCY[project_name]}-${DEPENDENCY[revision]}* "${GOPATH}"/src/${destdir} || die
						eend
						;;
					*) die "Function 'golang-single_src_prepare' doesn't support '${DEPENDENCY[importpath]}'" ;;
				esac
			done

		fi

	popd > /dev/null


	# Auto-detects the presence of Go's vendored
	# dependencies inside $S/vendor.
	local VENDOR="${S}/vendor"
	if [[ -d "${VENDOR}" ]]; then
		golang_add_vendor "${VENDOR}"
	fi

	# Auto-detects the presence of Go's vendored
	# dependencies inside $S/*/vendor
	if [[ -n ${GOLANG_PKG_BUILDPATH} && ${GOLANG_PKG_BUILDPATH##*/} != "..." ]]; then
		while read -d $' ' path; do
			# Trims leading slash (if any).
			path="${path/\//}"

			# Extracts the root path.
			path="${path%%/*}"

			# Ignores $path when it's empty or a string of white spaces.
			[[ -n $path ]] || continue

			local vendor="${S}/${path}/vendor"
			if [[ -d "${vendor}" ]]; then
				golang_add_vendor "${vendor}"
			fi
		done <<< "$( echo ${GOLANG_PKG_BUILDPATH}) "
	fi


	# Auto-detects the presence of Godep's workspace
	# (see github.com/tools/godep for more infos).
	VENDOR="${S}/Godeps/_workspace"
	if [[ -d "${VENDOR}" ]]; then
		GOLANG_PKG_VENDOR+=" ${VENDOR}"
	fi


	# Evaluates PATCHES array and allows user defined patches.
	[[ ${PATCHES[@]} ]] && epatch "${PATCHES[@]}"
	epatch_user
}


# @FUNCTION: golang-single_src_configure
# @DESCRIPTION:
# Configure the package.
golang-single_src_configure() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${EGO} ]] || die "No GoLang implementation set (golang_setup not called?)."

	# Defines the level of verbosity.
	local EGO_VERBOSE="-v"
	[[ -z ${PORTAGE_VERBOSE} ]] || EGO_VERBOSE+=" -x"

	# GoLang doesn't have a configure phase,
	# so instead this eclass prints the output of 'go env'.
	local -a GOLANG_ENV=()
	while read line; do
		GOLANG_ENV+=("${line}")
	done <<-EOF
		$( ${GO} env )
	EOF

	# Prints an error when 'go env' output is missing.
	if [[ ${#GOLANG_ENV[@]} -eq 1 ]]; then
		eerror "Your GoLang environment should be more verbose"
	fi

	# Prints GoLang environment summary.
	einfo " ${EGO} env"
	for env in "${GOLANG_ENV[@]}"; do
		einfo " - ${env}"
	done


	# Removes GoLang object files from package source directories (pkg/)
	# and temporary directories (_obj/ _test*/).
	local EGO_SUBPACKAGES="${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME}"
	case $( get_version_component_range 1-2 ${GOLANG_VERSION} ) in
		1.4*) ;;
		*)
			EGO_SUBPACKAGES+="/..."
			;;
	esac
	einfo "${EGO} clean -i ${EGO_VERBOSE} ${EGO_SUBPACKAGES}"
	${EGO} clean -i \
		${EGO_VERBOSE} \
		"${EGO_SUBPACKAGES}" \
		|| die

	# Removes GoLang objects files from all the dependencies too.
	if [[ ${#GOLANG_PKG_DEPENDENCIES[@]} -gt 0 ]]; then

		for i in ${!GOLANG_PKG_DEPENDENCIES[@]} ; do

			# Collects all the tokens of the dependency.
			local -A DEPENDENCY=()
			while read -d $'\n' key value; do
				[[ -z ${key} ]] && continue
				DEPENDENCY[$key]="${value}"
			done <<-EOF
				$( _factorize_dependency_entities "${GOLANG_PKG_DEPENDENCIES[$i]}" )
			EOF

			# Debug
			debug-print "${FUNCNAME}: DEPENDENCY = ${GOLANG_PKG_DEPENDENCIES[$i]}"
			debug-print "${FUNCNAME}: importpath = ${DEPENDENCY[importpath]}"

			# Cleans object files of the dependency.
			einfo "${EGO} clean -i ${EGO_VERBOSE} ${DEPENDENCY[importpath]}"
			${EGO} clean \
				-i ${EGO_VERBOSE} \
				"${DEPENDENCY[importpath]}" \
				|| die
		done
	fi

	# Before to compile Godep's dependencies it's wise to wipe out
	# all pre-built object files from Godep's package source directories.
	if [[ -d "${S}"/Godeps/_workspace/pkg ]]; then
		ebegin "Cleaning up pre-built object files in Godep workspace"
			rm -r "${S}"/Godeps/_workspace/pkg || die
		eend
	fi
	if [[ -d "${S}"/Godeps/_workspace/bin ]]; then
		ebegin "Cleaning up executables in Godep workspace"
			rm -r "${S}"/Godeps/_workspace/bin || die
		eend
	fi


	# Executes 'go generate'.
	# NOTE: generate should never run automatically. It must be run explicitly.
	if [[ -n ${GOLANG_PKG_USE_GENERATE} ]]; then
		einfo "${EGO} generate ${EGO_VERBOSE} ./..."
		${EGO} generate \
			${EGO_VERBOSE} \
			./... \
			|| die
	fi


	# Executes 'statik' when explicitly asked.
	if [[ -n ${GOLANG_PKG_STATIK} ]]; then
		ebegin "${ESTATIK} $GOLANG_PKG_STATIK"
			${ESTATIK} $GOLANG_PKG_STATIK || die
		eend
	fi
}


# @FUNCTION: golang-single_src_compile
# @DESCRIPTION:
# Compiles the package.
golang-single_src_compile() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${EGO} ]] || die "No GoLang implementation set (golang_setup not called?)."

	# Populates env variable GOPATH with vendored workspaces (if present).
	if [[ -n ${GOLANG_PKG_VENDOR} || "1" == ${GO15VENDOREXPERIMENT} ]]; then
		einfo "Using vendored dependencies from:"

		# Prints Go's vendored directory.
		if [[ "1" == ${GO15VENDOREXPERIMENT} ]]; then
			einfo "- vendor"
		fi
	fi

	# Prints user defined vendored directories.
	if [[ -n ${GOLANG_PKG_VENDOR} ]]; then
		for path in "${GOLANG_PKG_VENDOR[@]}"; do
			[ -d ${path} ] || continue

			debug-print "$FUNCNAME: GOPATH: Adding vendor path ${path}"
			ebegin "- ${path//${WORKDIR}\//}"
				GOPATH="${GOPATH}:$( echo ${path} )"
			eend
		done

		export GOPATH
	fi

	# Defines the install suffix.
	local EGO_INSTALLSUFFIX
	[[ -z ${GOLANG_PKG_INSTALLSUFFIX} ]] || EGO_INSTALLSUFFIX="-installsuffix=${GOLANG_PKG_INSTALLSUFFIX}"

	# Defines the level of verbosity.
	local EGO_VERBOSE="-v"
	[[ -z ${PORTAGE_VERBOSE} ]] || EGO_VERBOSE+=" -x"

	# Defines the number of builds that can be run in parallel.
	local EGO_PARALLEL="-p $(makeopts_jobs)"

	# Defines extra options.
	local EGO_EXTRA_OPTIONS="-a"

	# Prepares build flags for the go toolchain.
	local EGO_BUILD_FLAGS="$( echo ${EGO_VERBOSE} ) $( echo ${EGO_PARALLEL} ) $( echo ${EGO_EXTRA_OPTIONS} )"
	[[ -n ${EGO_INSTALLSUFFIX} ]] && EGO_BUILD_FLAGS+=" $( echo ${EGO_INSTALLSUFFIX} )"

	# Defines the output binary name of the package.
	# If the package is a multiple package then this eclass doesn't specify
	# the output name.
	[[ -z ${GOLANG_PKG_BUILDPATH} ]] && EGO_BUILD_FLAGS+=" -o ${GOBIN}/${GOLANG_PKG_OUTPUT_NAME}"

	# Builds the package.
	einfo "Compiling package(s):"
	if [[ -n ${GOLANG_PKG_BUILDPATH} && ${GOLANG_PKG_BUILDPATH##*/} != "..." ]]; then

		# NOTE: This eclass trims all leading and trailing white spaces from the
		#       input of the following 'while read' loop, then appends an extra
		#       trailing space; this is necessary to avoid undefined behaviours
		#       within the loop when GOLANG_PKG_BUILDPATH is populated with only
		#       a single element.
		while read -d $' ' cmd; do
			# Ignores $cmd when it's empty or a string of white spaces
			#einfo "cmd: |$cmd| cmd: |${cmd##*/}|"
			[[ -n $cmd ]] || continue

			golang_do_build \
				${EGO_BUILD_FLAGS} \
				-o "${GOBIN}/${cmd##*/}" \
				"${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME}${cmd}"
		done <<< "$( echo ${GOLANG_PKG_BUILDPATH}) "
	else
		golang_do_build \
			${EGO_BUILD_FLAGS} \
			"${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME}${GOLANG_PKG_BUILDPATH}"
	fi
}


# @FUNCTION: golang-single_src_install
# @DESCRIPTION:
# Installs binaries and documents from DOCS or HTML_DOCS arrays.
golang-single_src_install() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${EGO} ]] || die "No GoLang implementation set (golang_setup not called?)."

	# Defines the install suffix.
	local EGO_INSTALLSUFFIX
	[[ -z ${GOLANG_PKG_INSTALLSUFFIX} ]] || EGO_INSTALLSUFFIX="-installsuffix=${GOLANG_PKG_INSTALLSUFFIX}"

	# Defines the level of verbosity.
	local EGO_VERBOSE="-v"
	[[ -z ${PORTAGE_VERBOSE} ]] || EGO_VERBOSE+=" -x"

	# Defines the number of builds that can be run in parallel.
	local EGO_PARALLEL="-p $(makeopts_jobs)"

	# Defines extra options.
	local EGO_EXTRA_OPTIONS

	# Prepares build flags for the go toolchain.
	local EGO_BUILD_FLAGS="$( echo ${EGO_VERBOSE} ) $( echo ${EGO_PARALLEL} ) $( echo ${EGO_EXTRA_OPTIONS} )"
	[[ -n ${EGO_INSTALLSUFFIX} ]] && EGO_BUILD_FLAGS+=" $( echo ${EGO_INSTALLSUFFIX} )"

	# Defines sub-packages.
	local EGO_SUBPACKAGES="${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME}${GOLANG_PKG_BUILDPATH}"

	# Executes the pre-install phase (go install).
	if [[ -n ${GOLANG_PKG_IS_MULTIPLE} ]]; then
		einfo "${EGO} install -ldflags '$GOLANG_PKG_LDFLAGS' -tags '$GOLANG_PKG_TAGS' ${EGO_BUILD_FLAGS}"
		${EGO} install \
			-ldflags "-s -w $( echo ${GOLANG_PKG_LDFLAGS} )" \
			-tags "$( echo ${GOLANG_PKG_TAGS} )" \
			${EGO_BUILD_FLAGS} \
			"${EGO_SUBPACKAGES}" \
			|| die
	fi

	# Installs binaries.
	into ${GOLANG_PKG_INSTALLPATH}
	for bin in "${GOBIN}"/* ; do
		dobin ${bin}
	done

	# Installs documentation.
	einstalldocs
}


# @FUNCTION: golang-single_src_test
# @DESCRIPTION:
# Runs the unit tests for the main package.
golang-single_src_test() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${EGO} ]] || die "No GoLang implementation set (golang_setup not called?)."

	# Appends S and GOBIN to exported main paths.
	# FIX: this is necessary for unit tests that need to invoke bins from
	#       $GOBIN or from within $S/bin.
	export PATH="${S}/bin:${GOBIN}:${PATH}"

	# Defines the level of verbosity.
	local EGO_VERBOSE="-v"
	[[ -z ${PORTAGE_VERBOSE} ]] || EGO_VERBOSE+=" -x"

	# Defines the number of builds that can be run in parallel.
	local EGO_PARALLEL="-p $(makeopts_jobs)"

	# Defines extra options.
	local EGO_EXTRA_OPTIONS="-a"

	# Enables data race detection.
	local EGO_RACE
	[[ -n ${GOLANG_PKG_HAVE_TEST_RACE} ]] && EGO_RACE=" -race"

	# Prepares build flags for the go toolchain.
	local EGO_BUILD_FLAGS="$( echo ${EGO_VERBOSE} ) $( echo ${EGO_PARALLEL} ) $( echo ${EGO_EXTRA_OPTIONS} )"
	[[ -n ${EGO_RACE} ]] && EGO_BUILD_FLAGS+=" $( echo ${EGO_RACE} )"

	# Defines sub-packages.
	local EGO_SUBPACKAGES="${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME}${GOLANG_PKG_BUILDPATH}"
	[[ -n ${GOLANG_PKG_IS_MULTIPLE} ]] || EGO_SUBPACKAGES="./..."

	# Runs the unit tests.
	einfo "${EGO} test ${EGO_BUILD_FLAGS} ${EGO_SUBPACKAGES}"
	${EGO} test \
		${EGO_BUILD_FLAGS} \
		"${EGO_SUBPACKAGES}" \
		|| die
}
