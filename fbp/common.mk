################################################################################
#
# Copyright 1993-2006 NVIDIA Corporation.  All rights reserved.
#
# NOTICE TO USER:   
#
# This source code is subject to NVIDIA ownership rights under U.S. and 
# international Copyright laws.  
#
# NVIDIA MAKES NO REPRESENTATION ABOUT THE SUITABILITY OF THIS SOURCE 
# CODE FOR ANY PURPOSE.  IT IS PROVIDED "AS IS" WITHOUT EXPRESS OR 
# IMPLIED WARRANTY OF ANY KIND.  NVIDIA DISCLAIMS ALL WARRANTIES WITH 
# REGARD TO THIS SOURCE CODE, INCLUDING ALL IMPLIED WARRANTIES OF 
# MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A PARTICULAR PURPOSE.   
# IN NO EVENT SHALL NVIDIA BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL, 
# OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS 
# OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE 
# OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE 
# OR PERFORMANCE OF THIS SOURCE CODE.  
#
# U.S. Government End Users.  This source code is a "commercial item" as 
# that term is defined at 48 C.F.R. 2.101 (OCT 1995), consisting  of 
# "commercial computer software" and "commercial computer software 
# documentation" as such terms are used in 48 C.F.R. 12.212 (SEPT 1995) 
# and is provided to the U.S. Government only as a commercial end item.  
# Consistent with 48 C.F.R.12.212 and 48 C.F.R. 227.7202-1 through 
# 227.7202-4 (JUNE 1995), all U.S. Government End Users acquire the 
# source code with only those rights set forth herein.
#
################################################################################
#
# Common build script
#
################################################################################

.SUFFIXES : .cu .cu_dbg.o .c_dbg.o .cpp_dbg.o .cu_rel.o .c_rel.o .cpp_rel.o .cubin .ptx

# Add new SM Versions here as devices with new Compute Capability are released
SM_VERSIONS := sm_10 sm_11 sm_12 sm_13 sm_20

# -------------------------------------------------------------------
# Override by setting in the top-level Makefile.
# These defaults will usually fail on your system.
CUDA_INSTALL_PATH     ?= /usr/local/cuda
CUDA_SDK_INSTALL_PATH ?= /usr/local/cuda/NVIDIA_GPU_Computing_SDK
INTEL_INSTALL_PATH    ?= /usr/local/Compiler
# -------------------------------------------------------------------

ifdef cuda-install
	CUDA_INSTALL_PATH := $(cuda-install)
endif

# detect OS
OSUPPER = $(shell uname -s 2>/dev/null | tr [:lower:] [:upper:])
OSLOWER = $(shell uname -s 2>/dev/null | tr [:upper:] [:lower:])
# 'linux' is output for Linux system, 'darwin' for OS X
DARWIN = $(strip $(findstring DARWIN, $(OSUPPER)))

# detect if 32 bit or 64 bit system
HP_64 =	$(shell uname -m | grep 64)

ifeq "$(strip $(HP_64))" ""
        CUDALIB   := $(CUDA_INSTALL_PATH)/lib
	CUTILNAME := cutil_i386
	IPP_INSTALL_PATH ?= $(INTEL_INSTALL_PATH)/ipp/ia32
else
        CUDALIB   := $(CUDA_INSTALL_PATH)/lib64
	CUTILNAME := cutil_x86_64
	IPP_INSTALL_PATH ?= $(INTEL_INSTALL_PATH)/ipp/em64t
endif

LIB     += -L$(CUDALIB) 

# Basic directory setup for SDK
# (override directories only if they are not already defined)
SRCDIR     ?= 
ROOTDIR	   ?= $(CUDA_SDK_INSTALL_PATH)/C
ROOTBINDIR ?= bin
BINDIR     ?= $(ROOTBINDIR)/$(OSLOWER)
ROOTOBJDIR ?= obj
LIBDIR     := $(ROOTDIR)/lib
COMMONDIR  := $(ROOTDIR)/common

# Compilers
ifeq "$(strip $(HP_64))" ""
   NVCC    := $(CUDA_INSTALL_PATH)/bin/nvcc 
else
   NVCC    := $(CUDA_INSTALL_PATH)/bin/nvcc 
endif

# All intel
CXX  := icpc
CC   := icc
LINK := icpc -fPIC

# GNU C++ and link, intel C
# CXX        := g++
# CC         := icc
# LINK       := g++ -fPIC

# All GNU
# CXX        := g++
# CC         := gcc
# LINK       := g++ -fPIC

# Includes
INCLUDES += -I. -I$(CUDA_INSTALL_PATH)/include -I$(COMMONDIR)/inc
INCLUDES += -I$(IPP_INSTALL_PATH)/include

# architecture flag for cubin build
CUBIN_ARCH_FLAG :=

# Warning flags
CXXWARN_FLAGS := \
#	-W -Wall \
	-Wimplicit \
	-Wswitch \
	-Wformat \
	-Wchar-subscripts \
	-Wparentheses \
	-Wmultichar \
	-Wtrigraphs \
	-Wpointer-arith \
	-Wcast-align \
	-Wreturn-type \
	-Wno-unused-function \
	$(SPACE)

CWARN_FLAGS := $(CXXWARN_FLAGS) \
	-Wstrict-prototypes \
	-Wmissing-prototypes \
	-Wmissing-declarations \
	-Wnested-externs \
	-Wmain \
	$(SPACE)

# Compiler-specific flags
NVCCFLAGS := 
CXXFLAGS  := $(CXXWARN_FLAGS)
CFLAGS    := $(CWARN_FLAGS)

# Common flags
COMMONFLAGS += $(INCLUDES) -DUNIX

# Debug/release configuration
ifeq ($(dbg),1)
	COMMONFLAGS += -g
	NVCCFLAGS   += -D_DEBUG
	CXXFLAGS    += -D_DEBUG
	CFLAGS      += -D_DEBUG
	BINSUBDIR   := debug
#	LIBSUFFIX   := D
	LIBSUFFIX   :=
else 
	COMMONFLAGS += -O2 
	BINSUBDIR   := release
	LIBSUFFIX   :=
	NVCCFLAGS   += --compiler-options -fno-strict-aliasing
	CXXFLAGS    += -fno-strict-aliasing
	CFLAGS      += -fno-strict-aliasing
endif

# append optional arch/SM version flags (such as -arch sm_11)
#NVCCFLAGS += $(SMVERSIONFLAGS)

# architecture flag for cubin build
CUBIN_ARCH_FLAG :=

# OpenGL is used or not (if it is used, then it is necessary to include GLEW)
ifeq ($(USEGLLIB),1)

	ifneq ($(DARWIN),)
		OPENGLLIB := -L/System/Library/Frameworks/OpenGL.framework/Libraries -lGL -lGLU $(COMMONDIR)/lib/$(OSLOWER)/libGLEW.a
	else
		OPENGLLIB := -lGL -lGLU -lX11 -lXi -lXmu

		ifeq "$(strip $(HP_64))" ""
			OPENGLLIB += -lGLEW -L/usr/X11R6/lib
		else
			OPENGLLIB += -lGLEW_x86_64 -L/usr/X11R6/lib64
		endif
	endif

	CUBIN_ARCH_FLAG := -m64
endif

ifeq ($(USEGLUT),1)
	ifneq ($(DARWIN),)
		OPENGLLIB += -framework GLUT
	else
		OPENGLLIB += -lglut
	endif
endif

ifeq ($(USEPARAMGL),1)
	PARAMGLLIB := -lparamgl$(LIBSUFFIX)
endif

ifeq ($(USERENDERCHECKGL),1)
	RENDERCHECKGLLIB := -lrendercheckgl$(LIBSUFFIX)
endif

ifeq ($(USECUDPP), 1)
	ifeq "$(strip $(HP_64))" ""
		CUDPPLIB := -lcudpp
	else
		CUDPPLIB := -lcudpp64
	endif

	CUDPPLIB := $(CUDPPLIB)$(LIBSUFFIX)

	ifeq ($(emu), 1)
		CUDPPLIB := $(CUDPPLIB)_emu
	endif
endif

# Libs
ifeq "$(strip $(HP_64))" ""
   # 32-bit
   LIB := -L$(CUDA_INSTALL_PATH)/lib -L$(LIBDIR) -L$(COMMONDIR)/lib/$(OSLOWER)
   LIB += -L$(INTEL_INSTALL_PATH)/lib/ia32

   # For compilation on babbage using shared objs
   LIB += -L$(IPP_INSTALL_PATH)/sharedlib
   LIB += -lippcore -lipps -lippvm -lippcv -lippi -lippch
   # Original libs
   LIB += -lippsu8 -lippiu8 -lippcvu8 -lippchu8 -lippvmu8 -lippvcu8 -lippscu8 -lippchs8
   LIB += -liomp5 -lpthread 

else
   # 64-bit
   LIB := -L$(CUDA_INSTALL_PATH)/lib64 -L$(LIBDIR) -L$(COMMONDIR)/lib/$(OSLOWER) 
   LIB += -L$(IPP_INSTALL_PATH)/sharedlib
   LIB += -L$(INTEL_INSTALL_PATH)/lib/intel64
   LIB += -lippcoreem64t 
   LIB += -lippsu8 -lippiu8 -lippcvu8 -lippchu8 -lippvmu8 -lippvcu8
#   LIB += -lippscu8
   LIB += -liomp5 -lpthread
endif

# If dynamically linking to CUDA and CUDART, we exclude the libraries from the LIB
ifeq ($(USECUDADYNLIB),1)
     LIB += ${OPENGLLIB} $(PARAMGLLIB) $(RENDERCHECKGLLIB) $(CUDPPLIB) -ldl -rdynamic 
else
# static linking, we will statically link against CUDA and CUDART
  ifeq ($(USEDRVAPI),1)
     LIB += -lcuda   ${OPENGLLIB} $(PARAMGLLIB) $(RENDERCHECKGLLIB) $(CUDPPLIB) 
  else
     LIB += -lcudart ${OPENGLLIB} $(PARAMGLLIB) $(RENDERCHECKGLLIB) $(CUDPPLIB)
  endif
endif

ifeq ($(USECUFFT),1)
  ifeq ($(emu),1)
    LIB += -lcufftemu
  else
    LIB += -lcufft
  endif
endif

ifeq ($(USECUBLAS),1)
  ifeq ($(emu),1)
    LIB += -lcublasemu
  else
    LIB += -lcublas
  endif
endif

# Lib/exe configuration
ifneq ($(STATIC_LIB),)
	TARGETDIR := $(LIBDIR)
	TARGET   := $(subst .a,$(LIBSUFFIX).a,$(LIBDIR)/$(STATIC_LIB))
	LINKLINE  = ar rucv $(TARGET) $(OBJS) 
else
	# Ensure libcutil has been compiled in the SDK (for timer functions)
	ifneq ($(OMIT_CUTIL_LIB),1)
		LIB += -l$(CUTILNAME)$(LIBSUFFIX)
	endif
	# Device emulation configuration
	ifeq ($(emu), 1)
		NVCCFLAGS   += -deviceemu
		CUDACCFLAGS += 
		BINSUBDIR   := emu$(BINSUBDIR)
		# consistency, makes developing easier
		CXXFLAGS		+= -D__DEVICE_EMULATION__
		CFLAGS			+= -D__DEVICE_EMULATION__
	endif
	TARGETDIR := $(BINDIR)/$(BINSUBDIR)
	TARGET    := $(TARGETDIR)/$(EXECUTABLE)
	LINKLINE  = $(LINK) -o $(TARGET) $(OBJS) $(LIB)
endif

# check if verbose 
ifeq ($(verbose), 1)
	VERBOSE :=
else
	VERBOSE := @
endif

################################################################################
# Check for input flags and set compiler flags appropriately
################################################################################
ifeq ($(fastmath), 1)
	NVCCFLAGS += -use_fast_math
endif

ifeq ($(keep), 1)
	NVCCFLAGS += -keep
	NVCC_KEEP_CLEAN := *.i* *.cubin *.cu.c *.cudafe* *.fatbin.c *.ptx
endif

ifdef maxregisters
	NVCCFLAGS += -maxrregcount $(maxregisters)
endif

# Add cudacc flags
NVCCFLAGS += $(CUDACCFLAGS)

# Add common flags
NVCCFLAGS += $(COMMONFLAGS)
CXXFLAGS  += $(COMMONFLAGS)
CFLAGS    += $(COMMONFLAGS)

ifeq ($(nvcc_warn_verbose),1)
	NVCCFLAGS += $(addprefix --compiler-options ,$(CXXWARN_FLAGS)) 
	NVCCFLAGS += --compiler-options -fno-strict-aliasing
endif

################################################################################
# Set up object files
################################################################################
OBJDIR := $(ROOTOBJDIR)/$(BINSUBDIR)
OBJS +=  $(patsubst %.cpp,$(OBJDIR)/%.cpp.o,$(notdir $(CCFILES)))
OBJS +=  $(patsubst %.c,$(OBJDIR)/%.c.o,$(notdir $(CFILES)))
OBJS +=  $(patsubst %.cu,$(OBJDIR)/%.cu.o,$(notdir $(CUFILES)))

################################################################################
# Set up cubin output files
################################################################################
CUBINDIR := $(SRCDIR)data
CUBINS +=  $(patsubst %.cu,$(CUBINDIR)/%.cubin,$(notdir $(CUBINFILES)))

################################################################################
# Set up PTX output files
################################################################################
PTXDIR := $(SRCDIR)data
PTXBINS +=  $(patsubst %.cu,$(PTXDIR)/%.ptx,$(notdir $(PTXFILES)))

################################################################################
# Rules
################################################################################
$(OBJDIR)/%.c.o : $(SRCDIR)%.c $(C_DEPS)
	$(VERBOSE)$(CC) $(CFLAGS) -o $@ -c $<

$(OBJDIR)/%.cpp.o : $(SRCDIR)%.cpp $(C_DEPS)
	$(VERBOSE)$(CXX) $(CXXFLAGS) -o $@ -c $<

$(OBJDIR)/%.cu.o : $(SRCDIR)%.cu $(CU_DEPS)
	$(VERBOSE)$(NVCC) $(NVCCFLAGS) $(SMVERSIONFLAGS) -o $@ -c $<

$(CUBINDIR)/%.cubin : $(SRCDIR)%.cu cubindirectory
	$(VERBOSE)$(NVCC) $(CUBIN_ARCH_FLAG) $(NVCCFLAGS) $(SMVERSIONFLAGS) -o $@ -cubin $<

$(PTXDIR)/%.ptx : $(SRCDIR)%.cu ptxdirectory
	$(VERBOSE)$(NVCC) $(CUBIN_ARCH_FLAG) $(NVCCFLAGS) $(SMVERSIONFLAGS) -o $@ -ptx $<

#
# The following definition is a template that gets instantiated for each SM
# version (sm_10, sm_13, etc.) stored in SMVERSIONS.  It does 2 things:
# 1. It adds to OBJS a .cu_sm_XX.o for each .cu file it finds in CUFILES_sm_XX.
# 2. It generates a rule for building .cu_sm_XX.o files from the corresponding 
#    .cu file.
#
# The intended use for this is to allow Makefiles that use common.mk to compile
# files to different Compute Capability targets (aka SM arch version).  To do
# so, in the Makefile, list files for each SM arch separately, like so:
#
# CUFILES_sm_10 := mycudakernel_sm10.cu app.cu
# CUFILES_sm_12 := anothercudakernel_sm12.cu
#
define SMVERSION_template
OBJS += $(patsubst %.cu,$(OBJDIR)/%.cu_$(1).o,$(notdir $(CUFILES_$(1))))
$(OBJDIR)/%.cu_$(1).o : $(SRCDIR)%.cu $(CU_DEPS)
	$(VERBOSE)$(NVCC) -o $$@ -c $$< $(NVCCFLAGS) -arch $(1)
endef

# This line invokes the above template for each arch version stored in
# SM_VERSIONS.  The call funtion invokes the template, and the eval
# function interprets it as make commands.
$(foreach smver,$(SM_VERSIONS),$(eval $(call SMVERSION_template,$(smver))))

$(TARGET): makedirectories $(OBJS) $(CUBINS) $(PTXBINS) Makefile
	$(VERBOSE)$(LINKLINE)

cubindirectory:
	$(VERBOSE)mkdir -p $(CUBINDIR)

ptxdirectory:
	$(VERBOSE)mkdir -p $(PTXDIR)

makedirectories:
	$(VERBOSE)mkdir -p $(LIBDIR)
	$(VERBOSE)mkdir -p $(OBJDIR)
	$(VERBOSE)mkdir -p $(TARGETDIR)


tidy :
	$(VERBOSE)find . | egrep "#" | xargs rm -f
	$(VERBOSE)find . | egrep "\~" | xargs rm -f

clean : tidy
	$(VERBOSE)rm -f $(OBJS)
	$(VERBOSE)rm -f $(CUBINS)
	$(VERBOSE)rm -f $(PTXBINS)
	$(VERBOSE)rm -f $(TARGET)
	$(VERBOSE)rm -f $(NVCC_KEEP_CLEAN)

clobber : clean
	$(VERBOSE)rm -rf $(ROOTOBJDIR)