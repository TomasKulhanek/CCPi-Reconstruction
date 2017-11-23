#!/usr/bin/env python

import setuptools
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

import os
import numpy
import platform	
import sys

cil_version=os.environ['CIL_VERSION']
if  cil_version == '':
    print("Please set the environmental variable CIL_VERSION")
    sys.exit(1)

library_include_path = ""
try:
    library_include_path = os.environ['LIBRARY_INC']
except:
    if platform.system() == 'Windows':
        pass
    else:
        try:
           library_include_path = os.environ['PREFIX']+'/include'
        except:
           pass
    pass
<<<<<<< HEAD
extra_compile_args = ['-fopenmp','-O2', '-funsigned-char', '-Wall']
extra_libraries = []
extra_include_dirs = []
=======

extra_include_dirs = [numpy.get_include()]
>>>>>>> 2cae1156fe0554b3ee560cb15f3c432be0a83abf
extra_library_dirs = []
extra_compile_args = []
extra_link_args = []
extra_libraries = []

if platform.system() == 'Windows':
   extra_compile_args += ['/DWIN32','/EHsc','/DBOOST_ALL_NO_LIB', '/openmp']   
   extra_include_dirs += ["..\\src\\","..\\src\\Algorithms","..\\src\\Readers", "."]
   extra_include_dirs += [library_include_path]
   extra_library_dirs += [r'C:\Apps\Miniconda2\envs\cil\Library\lib']
   if sys.version_info.major == 3 :   
       extra_libraries += ['boost_python3-vc140-mt-1_64', 'boost_numpy3-vc140-mt-1_64']
   else:
       extra_libraries += ['boost_python-vc90-mt-1_64', 'boost_numpy-vc90-mt-1_64']   
else:
   extra_include_dirs += ['/apps/anaconda/2.4/envs/cil-py3/include/','/apps/anaconda/2.4/envs/cil-py3/include/python3.5m']
   extra_include_dirs += ["../src/","../src/Algorithms","../src/Readers", ".", numpy.get_include()]
   extra_include_dirs += [library_include_path]
   extra_compile_args += ['-fopenmp','-O2', '-funsigned-char', '-Wall','-Wl,--no-undefined']   
   if sys.version_info.major == 3 :
       extra_libraries += ['boost_python3', 'boost_numpy3','gomp']
   else:
       extra_libraries += ['boost_python', 'boost_numpy','gomp']


setup(
  name='ccpi-reconstruction',
	description='This is a CCPi Core Imaging Library package for Iterative Reconstruction codes',
	version=cil_version,
    cmdclass = {'build_ext': build_ext},
    ext_modules = [Extension("ccpi.reconstruction.parallelbeam",
                             sources=[  "src/diamond_module.cpp",
                                        "src/diamond_wrapper.cpp",
										"../src/mpi.cpp", 
										"../src/utils.cpp",
										"../src/instruments.cpp",
										"../src/results.cpp",
										"../src/voxels.cpp",
										"../src/Algorithms/cgls.cpp",
										"../src/Algorithms/mlem.cpp",
										"../src/Algorithms/sirt.cpp",
										"../src/total_v.cpp",
										"../src/parallel.cpp",
										"../src/cone.cpp",
										"../src/diamond.cpp",
										"../src/Readers/xtek.cpp",
										"../src/Algorithms/tv_reg.cpp",
										"../src/tv_core.cpp",
										"../src/p2D.cpp",
										"../src/c2D.cpp",
										"../src/Readers/tiff.cpp",
										"../src/timer.cpp",
										"../src/tikhonov.cpp",
										"../src/ui_calls.cpp"],
                             include_dirs=extra_include_dirs, library_dirs=extra_library_dirs, extra_compile_args=extra_compile_args, libraries=extra_libraries, extra_link_args=extra_link_args ),
                             Extension("ccpi.reconstruction.conebeam",
                             sources=[  "src/conebeam_module.cpp",
<<<<<<< HEAD
                                        "../src/mpi.cpp", 
                                        "../src/utils.cpp",
                                        "../src/instruments.cpp",
                                        "../src/results.cpp",
                                        "../src/voxels.cpp",
                                        "../src/Algorithms/cgls.cpp",
                                        "../src/Algorithms/mlem.cpp",
                                        "../src/Algorithms/sirt.cpp",
                                        "../src/total_v.cpp",
                                        "../src/parallel.cpp",
                                        "../src/cone.cpp",
                                        "../src/diamond.cpp",
                                        "../src/Readers/xtek.cpp",
                                        "../src/Algorithms/tv_reg.cpp",
                                        "../src/tv_core.cpp",
                                        "../src/p2D.cpp",
                                        "../src/c2D.cpp",
                                        "../src/Readers/tiff.cpp",
                                        "../src/timer.cpp",
                                        "../src/tikhonov.cpp",
                                        "../src/ui_calls.cpp"],
                             include_dirs=extra_include_dirs, library_dirs=extra_library_dirs, extra_compile_args=extra_compile_args, libraries=extra_libraries )]
	#packages = {'ccpi','ccpi.reconstruction'}
=======
                                        "src/conebeam_wrapper.cpp",
										"../src/mpi.cpp", 
										"../src/utils.cpp",
										"../src/instruments.cpp",
										"../src/results.cpp",
										"../src/voxels.cpp",
										"../src/Algorithms/cgls.cpp",
										"../src/Algorithms/mlem.cpp",
										"../src/Algorithms/sirt.cpp",
										"../src/total_v.cpp",
										"../src/parallel.cpp",
										"../src/cone.cpp",
										"../src/diamond.cpp",
										"../src/Readers/xtek.cpp",
										"../src/Algorithms/tv_reg.cpp",
										"../src/tv_core.cpp",
										"../src/p2D.cpp",
										"../src/c2D.cpp",
										"../src/Readers/tiff.cpp",
										"../src/timer.cpp",
										"../src/tikhonov.cpp",
										"../src/ui_calls.cpp"],
                             include_dirs=extra_include_dirs, library_dirs=extra_library_dirs, extra_compile_args=extra_compile_args, libraries=extra_libraries )                             ],
	zip_safe = False,
	packages = {'ccpi','ccpi.reconstruction'}
>>>>>>> 2cae1156fe0554b3ee560cb15f3c432be0a83abf
)