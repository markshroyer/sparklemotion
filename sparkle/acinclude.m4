# AX_CHECK_CFLAGS(ADDITIONAL-CFLAGS, ACTION-IF-FOUND, ACTION-IF-NOT-FOUND)
#
# checks whether the $(CC) compiler accepts the ADDITIONAL-CFLAGS
# if so, they are added to the CFLAGS
AC_DEFUN([AX_CHECK_CFLAGS],
[
  AC_MSG_CHECKING([whether compiler accepts "$1"])
  cat > conftest.c <<_ACEOF
  int main(){
    return 0;
  }
_ACEOF
  if $CC $CFLAGS -o conftest.o conftest.c [$1] > /dev/null 2>&1
  then
    AC_MSG_RESULT([yes])
    CFLAGS="${CFLAGS} [$1]"
    [$2]
  else
    AC_MSG_RESULT([no])
   [$3]
  fi
])dnl AX_CHECK_CFLAGS

# AX_CHECK_DTC_OVERLAY ([ACTION-IF-TRUE], [ACTION-IF-FALSE])
# --------------------------------------------------------
# Tests whether the DTC compiler supports building Device Tree overlays.
AC_DEFUN([AX_CHECK_DTC_OVERLAY],
[
  AC_MSG_CHECKING([whether dtc supports overlays])
  cat > conftest.dts <<_ACEOF
/dts-v1/;
/plugin/;

/ {
    compatible = "foo,device";
    part-number = "foo";
    version = "00A0";

    fragment@0 {
        target = <&ocp>;
        __overlay__ {
            bar_label: bar {
                foo,some-values = < 0x01 0x02 0x03 0x04 >;
            };
        };
    };
};
_ACEOF
  if dtc -I dts -O dtb -o conftest.dtbo -XXX conftest.dts >/dev/null 2>&1
  then
    AC_MSG_RESULT([yes])
    $1
  else
    AC_MSG_RESULT([no])
    $2
  fi
])dnl AX_TRY_DTC_OVERLAY
