#   Copyright 2018 Edoardo Pasca
cmake_minimum_required (VERSION 3.0)

project(ReconstructionPython)
#https://stackoverflow.com/questions/13298504/using-cmake-with-setup-py

# The version number.

set (CIL_VERSION $ENV{CIL_VERSION} CACHE INTERNAL "Core Imaging Library version" FORCE)

# conda orchestrated build
message("CIL_VERSION ${CIL_VERSION}")
#include (GenerateExportHeader)

find_package(PythonInterp REQUIRED)
if (PYTHONINTERP_FOUND)
  message ("Current Python " ${PYTHON_VERSION_STRING} " found " ${PYTHON_EXECUTABLE})
  if (PYTHON_VERSION_MAJOR EQUAL "3")
    set (BOOST_PYTHON "python3")
	set (BOOST_NUMPY "numpy3")
  else()
    set (BOOST_PYTHON "python")
	set (BOOST_NUMPY "numpy")
  endif()
endif()

find_package(Boost
	COMPONENTS ${BOOST_PYTHON} ${BOOST_NUMPY})
	
if (Boost_FOUND)
else()
  #if (PYTHON_VERSION_MAJOR EQUAL "3")
    set (BOOST_PYTHON "python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}")
	set (BOOST_NUMPY "numpy${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}")
  #else()
   # set (BOOST_PYTHON "python")
   # set (BOOST_NUMPY "numpy")
  #endif()
endif()

find_package(Boost REQUIRED COMPONENTS ${BOOST_PYTHON} ${BOOST_NUMPY})

find_library(cilseg REQUIRED)

find_package(OpenMP)

if (Boost_FOUND)
   message("Boost version " ${Boost_VERSION})
   message("Boost include dir " ${Boost_INCLUDE_DIRS})
   message("Boost library dir " ${Boost_LIBRARY_DIRS})
   message("Boost libraries " ${Boost_LIBRARIES})
endif()
	
## Build the regularizers package as a library
message("Creating Reconstruction Wrapper")

message("CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}")

set(CMAKE_BUILD_TYPE "Release")

if(WIN32)
  set (FLAGS "/DWIN32 /EHsc /DBOOST_ALL_NO_LIB /openmp /DCCPiCore_EXPORTS /DCCPiReconstructionIterative_EXPORTS")
  set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:MSVCRT.lib")
  
  set (EXTRA_LIBRARIES 
        ${Boost_LIBRARIES}
		${cilseg}
		)
		
  message("library lib: ${LIBRARY_LIB}")
  
elseif(UNIX)
   set (FLAGS "-fopenmp -O2 -funsigned-char -Wall  -Wl,--no-undefined  -DCCPiReconstructionIterative_EXPORTS -std=c++0x")  
   #set (EXTRA_OMP_LIB "gomp")
   set (EXTRA_LIBRARIES 
		${Boost_LIBRARIES}
		#		${EXTRA_OMP_LIB}
		)
endif()


if (WIN32)
  list(GET Boost_LIBRARIES 0 place )
  get_filename_component(BOOST_PYTHON_LIB ${place} NAME_WE )
  list(GET Boost_LIBRARIES 1 place )
  get_filename_component(BOOST_NUMPY_LIB ${place} NAME_WE )
else()
  # on linux the library looks like libboost_numpy3.so:
  # we need to get rid of the lib at the beginning
  list(GET Boost_LIBRARIES 0 place )
  get_filename_component(place2 ${place} NAME_WE )
  string(REGEX REPLACE "^lib(.*)" "\\1" BOOST_PYTHON_LIB "${place2}")
  
  list(GET Boost_LIBRARIES 1 place )
  get_filename_component(place2 ${place} NAME_WE )
  string(REGEX REPLACE "^lib(.*)" "\\1" BOOST_NUMPY_LIB "${place2}")
endif()

message ("found " ${BOOST_PYTHON_LIB})
message ("found " ${BOOST_NUMPY_LIB})





configure_file("setup.py.in" "setup.py")


#add_executable(regularizer_test ${CMAKE_CURRENT_SOURCE_DIR}/test/test_regularizer.cpp)

#target_link_libraries (regularizer_test LINK_PUBLIC regularizers_lib)
