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
printf "CFLAGS:              ${CFLAGS}\n"
printf "LIBS:                ${LIBS}\n"
printf "Shared library:      $enable_shared\n"
printf "Python interpreter:  $PYTHON\n"
printf "\n"
