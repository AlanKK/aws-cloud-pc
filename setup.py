#!/usr/bin/env python
from distutils.core import setup
import setuptools
setup(name='amiuploader',
      version='1.0.0',
      description="Upload a locally saved vmdk to AWS s3, convert it to an AMI image, and rename/copy "
                  "image to all specified regions",
      author='Douglas Rohde',
      author_email='drohde@sciencelogic.com',
      packages=['amiimporter'],
      keywords='ami upload vmdk vcenter ovf AWS',
      url='todo',
      license="MIT",
      install_requires=[
          'awscli',
          'pysphere',
      ],
      scripts=['bin/amiupload'],
      classifiers=[
          # How mature is this project? Common values are
          #   3 - Alpha
          #   4 - Beta
          #   5 - Production/Stable
          'Development Status :: 4 - Beta',

          # Indicate who your project is intended for
          'Intended Audience :: Developers, Sys Admins',
          'Topic :: Other/Nonlisted Topic :: AMI Upload tools',

          # Pick your license as you wish (should match "license" above)
          "License :: MIT License",

          # Specify the Python versions you support here. In particular, ensure
          # that you indicate whether you support Python 2, Python 3 or both.
          'Programming Language :: Python :: 2.7',

      ]

      )
