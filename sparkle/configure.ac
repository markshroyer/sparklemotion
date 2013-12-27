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
AC_MSG_CHECKING([whether to build Python interface])
AC_ARG_WITH([python],
        [AS_HELP_STRING([--with-python@<:@=PATH@:>@],
                [Select Python interpreter for extension module])],
        [AS_IF([test x"$withval" = x"yes"],
                [AM_PATH_PYTHON(,, [""])],
                [PYTHON="$withval"])],
        [])
AM_CONDITIONAL([HAVE_PYTHON], [test "$PYTHON" != ""])
if test "$PYTHON" = ""; then
    AC_MSG_RESULT([no])
else
    AC_MSG_RESULT([yes])
    if test x"$user_python_prefix" != x""; then
        AC_SUBST(PYTHON_PREFIX_ARG, ["--prefix=\"$user_python_prefix\""])
    fi
fi
AC_ARG_VAR([PYTHON_PREFIX], [Python extension module installation prefix])

# Specify device tree compiler -- we need a patched one which accepts the
# -@ option for compiling overlays
AX_CHECK_DTC_OVERLAY([], [])

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
