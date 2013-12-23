#!/usr/bin/env python

from distutils.core import setup, Extension

sparkle_ext = Extension(
    '_sparkle',
    ['_sparkle.c', 'sparkle.c'],
    include_dirs=['/usr/local/include'],
    library_dirs=['/usr/local/lib'],
    libraries=['prussdrv', 'pthread'],
    extra_link_args=['-shared'],
    )

setup(
    name='Sparkle',
    version='0.1',
    author='Mark Shroyer',
    author_email='code@markshroyer.com',
    license='BSD',
    py_modules=['sparkle'],
    ext_modules=[sparkle_ext],
    )
