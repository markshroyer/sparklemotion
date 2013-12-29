AC_PREREQ([2.69])

AC_INIT([sparkle],[0.0.1],[code@markshroyer.com])
AC_SUBST([INTERFACE_VERSION], [0:0:0])

AC_CONFIG_SRCDIR([include/sparkle/sparkle.h])

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([foreign -Wall -Werror])

AC_USE_SYSTEM_EXTENSIONS

AC_PROG_CC_C99
AM_PROG_CC_C_O

AC_CONFIG_HEADERS([config.h])

LT_PREREQ([2.4])

AC_CANONICAL_HOST
LT_INIT

# Save PYTHON_PREFIX so it isn't overwritten by AM_PATH_PYTHON
user_python_prefix="$PYTHON_PREFIX"

# Determine whether to include the Python wrapper
AM_PATH_PYTHON([2.7],,[""])
AM_CONDITIONAL([HAVE_PYTHON], [test "$PYTHON" != ""])

# Find pasm (it might be named pasm2 instead)
AC_PATH_PROG([PASM], [pasm])
AC_PATH_PROG([PASM], [pasm2])
AC_ARG_VAR([PASM], [TI PRU Assembler])
AS_IF([test -x $PASM], [], [AC_MSG_FAILURE([

pasm not found
--------------

TI's PRU Assembler (PASM) is required for building the PRU firmware which
lies at the heart of libsparkle.  Please obtain it from the following
location (as part of the AM335x PRU package):

https://github.com/beagleboard/am335x_pru_package
])])

AC_PATH_PROG([DTC], [dtc], [/usr/bin/dtc])
AC_ARG_VAR([DTC], [the Device Tree compiler])
AS_IF([test -x $DTC], [], [AC_MSG_FAILURE([

dtc not found
-------------

The Device Tree Compiler is required in order to build a device tree
overlay which will configure output pins for direct control by the PRU.  A
version specifically patched with support for overlays is required.  This
can be obtained by running the following script:

https://raw.github.com/RobertCNelson/tools/master/pkgs/dtc.sh

Alternatively, you can disable Device Tree overlay generation by running
configure with the --disable-dtbo option.
])])

# Specify device tree compiler -- we need a patched one which accepts the
# -@ option for compiling overlays
AX_CHECK_DTC_OVERLAY([], [AC_MSG_FAILURE([

dtc does not support overlays
-----------------------------

A Device Tree compiler was found, but the version installed on this system
does not support the -@ option for building overlays.  A suitably patched
version can be installed by running the following script:

https://raw.github.com/RobertCNelson/tools/master/pkgs/dtc.sh

(If you have more than one instance of dtc installed on this system, be
sure to specify the correct one by setting the \$DTC environment variable.)

Alternatively, you can disable Device Tree overlay generation by running
configure with the --disable-dtbo option.
])])

AX_CHECK_CFLAGS([-Wall -Werror])
AX_CHECK_CFLAGS([-pedantic])

AC_CONFIG_FILES([Makefile
                 src/Makefile
                 include/Makefile])

AC_OUTPUT

printf "\n"
printf "    _______________________\n"
printf "  =(__    ___      __     _)=\n"
printf "    |                     |\n"
printf "    |                     |\n"
printf "    |                     |\r"
printf "    |   ${PACKAGE_NAME} v${PACKAGE_VERSION}\n"
printf "    |                     |\n"
printf "    |__    ___   __    ___|\n"
printf "  =(_______________________)=\n"
printf "\n"
printf "Install prefix:      $prefix\n"
printf "Host:                $host\n"
printf "Compiler:            ${CC}\n"
printf "DTC:                 ${DTC}\n"
printf "PASM:                ${PASM}\n"
printf "CFLAGS:              ${CFLAGS}\n"
printf "LIBS:                ${LIBS}\n"
printf "Shared library:      $enable_shared\n"
printf "Python interpreter:  $PYTHON\n"
printf "\n"
