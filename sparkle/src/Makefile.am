AM_CPPFLAGS = -I$(top_srcdir)/include

lib_LTLIBRARIES = libsparkle.la
libsparkle_la_SOURCES = sparkle.c
libsparkle_la_LDFLAGS = -version-info @INTERFACE_VERSION@
libsparkle_includedir = $(includedir)/sparkle

bin_PROGRAMS = demo

demo_SOURCES = demo.c
demo_LDADD = libsparkle.la

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = sparkle.pc
