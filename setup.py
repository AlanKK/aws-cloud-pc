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
      url='https://github.com/ScienceLogic/amiuploader/archive/1.0.0.zip',
      license="MIT",
      install_requires=[
          'awscli',
          'pysphere',
      ],
      scripts=['bin/amiupload'],
      classifiers=[
          'Development Status :: 4 - Beta',
          'Intended Audience :: System Administrators',
          'Topic :: Other/Nonlisted Topic',
          "License :: OSI Approved :: MIT License",
          'Programming Language :: Python :: 2.7',
      ]

      )
