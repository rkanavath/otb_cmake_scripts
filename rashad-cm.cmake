#rashad-cm.cmake - custom cmake scripts for travis build
#before running this script you need to set the below env variables
#export CC=/usr/local/bin/clang
#export CXX=/usr/local/bin/clang++
#export CMAKE_CMD=/usr/local/bin/cmake
#export XDK_DIR=/tmp/OTB-xdk-Linux64

set(ENV{LC_ALL} C)

set(CTEST_SITE "travis-ci.org")
set(CTEST_DASHBOARD_TRACK Continuous)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_DASHBOARD_ROOT "/home/travis/build")
#set(CTEST_DASHBOARD_ROOT "/tmp/temp")
set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/orfeotoolbox/OTB")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/orfeotoolbox/build")
set(CMAKE_MAKE_PROGRAM /tmp/ninja)
set(CMAKE_COMMAND "$ENV{CMAKE_CMD}")
set(CTEST_CMAKE_GENERATOR "Ninja")

set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
set(CTEST_DROP_SITE_CDASH TRUE)

set(CTEST_USE_LAUNCHERS TRUE)

execute_process(COMMAND "${CMAKE_COMMAND}" -E chdir ${CTEST_SOURCE_DIRECTORY} git rev-parse --abbrev-ref HEAD OUTPUT_VARIABLE GIT_BRANCH RESULT_VARIABLE rv)
if(NOT rv EQUAL 0)
  message(FATAL_ERROR "cannot find git branch")
  set(GIT_BRANCH "develop")
endif()

set(CTEST_BUILD_NAME "travis-${GIT_BRANCH}")

#set(CTEST_TEST_ARGS INCLUDE_LABEL "")

#write CMakeCache.txt
file(WRITE ${CTEST_BINARY_DIRECTORY}/CMakeCache.txt "
SITE:STRING=${CTEST_SITE}
BUILDNAME:STRING=${CTEST_BUILD_NAME}
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
DART_TESTING_TIMEOUT:STRING=${CTEST_TEST_TIMEOUT}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized  -Wno-unused-variable -Wno-gnu
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-gnu -Wno-overloaded-virtual -Wno-cpp -Wno-unused-parameter
CMAKE_PREFIX_PATH:PATH=$ENV{XDK_DIR}
CMAKE_MAKE_PROGRAM:FILEPATH=/tmp/ninja
CMAKE_INSTALL_PREFIX=${CTEST_DASHBOARD_ROOT}/orfeotoolbox/install
BUILD_TESTING:BOOL=ON
DOTB_BUILD_DEFAULT_MODULES:BOOL=OFF
OTBGroup_ThirdParty:BOOL=ON
OTB_USE_6S:BOOL=OFF
OTB_USE_SIFTFAST:BOOL=OFF
BUILD_EXAMPLES:BOOL=OFF
#OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/otb-data
")

#disable tests
set(dashboard_no_test TRUE)

#empty binary directory
ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

#call ctest_start
ctest_start(${CTEST_DASHBOARD_TRACK} TRACK ${CTEST_DASHBOARD_TRACK})

#run configure
ctest_configure()

#read custom files
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})

#build OTB
#ctest_build()

#run test if asked explicitly
if(NOT dashboard_no_test)
    ctest_test(${CTEST_TEST_ARGS})
endif()

#submit to dashboard
ctest_submit()
